import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../core/widgets/liquid_glass.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/utils/mime_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/macro_bar.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../features/dashboard/providers/dashboard_provider.dart';
import '../../../providers/gemini_provider.dart';
import '../../../providers/mascot_provider.dart';
import '../../../providers/mascot_quirk_provider.dart';
import '../../../core/widgets/spark_mascot.dart';
import '../../../providers/food_knowledge_provider.dart';
import '../../../services/food_knowledge_service.dart';
import '../../../services/user_context_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/snackbar_service.dart';
import '../../../services/analytics_service.dart';
import '../widgets/recent_meals_strip.dart';
import 'barcode_scan_screen.dart';
import '../../../services/food_database_service.dart';

class LogMealScreen extends ConsumerStatefulWidget {
  const LogMealScreen({super.key});

  @override
  ConsumerState<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends ConsumerState<LogMealScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _textController = TextEditingController();
  bool _isAnalyzing = false;
  bool _isSaving = false;
  Map<String, dynamic>? _analysisResult;
  Uint8List? _lastImageBytes; // stored for display after analysis
  String _mealType = _defaultMealType();
  String _lastAiSource = 'unknown'; // set after each analysis call

  static String _defaultMealType() {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'breakfast';
    if (hour < 14) return 'lunch';
    if (hour < 19) return 'dinner';
    return 'snack';
  }

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) return;
      const names = ['camera', 'text', 'search', 'scan'];
      AnalyticsService.instance.tabSwitch(names[_tabs.index], screen: 'log_meal');
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _textController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildUserContext() {
    return UserContextService.buildMinimalContextSync(
      targets: ref.read(nutritionTargetsProvider),
      nutrition: ref.read(dailyNutritionProvider),
      mealType: _mealType,
    );
  }

  Future<void> _pickAndAnalyzePhoto(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (file == null || !mounted) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    AnalyticsService.instance.track('meal_analysis_started', props: {
      'input_type': 'photo',
      'source': source == ImageSource.camera ? 'camera' : 'gallery',
    });
    final sw = Stopwatch()..start();

    try {
      // Detect MIME type from the picked file
      final mimeType = file.mimeType ?? mimeTypeFromPath(file.path);

      // Compress image before sending to Gemini
      Uint8List imageBytes;
      if (kIsWeb) {
        // flutter_image_compress doesn't support web file paths (blob URLs)
        imageBytes = await file.readAsBytes();
      } else {
        final compressed = await FlutterImageCompress.compressWithFile(
          file.path,
          minWidth: 512,
          minHeight: 512,
          quality: 75,
        );
        if (compressed == null || !mounted) {
          setState(() => _isAnalyzing = false);
          return;
        }
        imageBytes = Uint8List.fromList(compressed);
      }

      // Store for display in the result card
      setState(() => _lastImageBytes = imageBytes);

      final ai = ref.read(aiProvider);

      // RAG: build grounding context from food knowledge base
      final kb = ref.read(foodKnowledgeProvider);
      final grounding = kb.isLoaded
          ? kb.buildGroundingContext('meal food Indian dish', maxResults: 12)
          : null;

      final result = await ai.analyzeMealPhoto(
        imageBytes: imageBytes,
        userContext: _buildUserContext(),
        mimeType: mimeType,
        groundingContext: grounding,
      );

      sw.stop();
      _lastAiSource = ai.lastSource.name;
      final totals = result['totals'] as Map? ?? {};
      AnalyticsService.instance.track('meal_analysis_done', props: {
        'input_type': 'photo',
        'ai_source': _lastAiSource,
        'duration_ms': sw.elapsedMilliseconds,
        'calories': totals['calories'] ?? 0,
        'items': (result['items'] as List? ?? []).length,
      });

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisResult = result;
        });
      }
    } catch (e) {
      sw.stop();
      AnalyticsService.instance.track('meal_analysis_error', props: {
        'input_type': 'photo',
        'error': e.toString().substring(0, e.toString().length.clamp(0, 200)),
      });
      debugPrint('Photo analysis error: $e');
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not analyze photo. Please try again.'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  Future<void> _analyzeText() async {
    if (_textController.text.trim().isEmpty) return;
    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
      _lastImageBytes = null; // text analysis has no photo
    });

    AnalyticsService.instance.track('meal_analysis_started', props: {'input_type': 'text'});
    final sw = Stopwatch()..start();

    try {
      final ai = ref.read(aiProvider);

      // RAG: retrieve relevant food entries for grounding
      final kb = ref.read(foodKnowledgeProvider);
      final grounding = kb.isLoaded
          ? kb.buildGroundingContext(_textController.text.trim())
          : null;

      final result = await ai.analyzeMealText(
        description: _textController.text.trim(),
        userContext: _buildUserContext(),
        groundingContext: grounding,
      );

      sw.stop();
      _lastAiSource = ai.lastSource.name;
      final totals = result['totals'] as Map? ?? {};
      AnalyticsService.instance.track('meal_analysis_done', props: {
        'input_type': 'text',
        'ai_source': _lastAiSource,
        'duration_ms': sw.elapsedMilliseconds,
        'calories': totals['calories'] ?? 0,
        'items': (result['items'] as List? ?? []).length,
        'description_len': _textController.text.trim().length,
      });

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisResult = result;
        });
      }
    } catch (e) {
      sw.stop();
      AnalyticsService.instance.track('meal_analysis_error', props: {
        'input_type': 'text',
        'error': e.toString().substring(0, e.toString().length.clamp(0, 200)),
      });
      debugPrint('Text analysis error: $e');
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Analysis failed. Please try again.'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveMeal() async {
    final result = _analysisResult;
    if (result == null) return;

    setState(() => _isSaving = true);

    try {
      final totals = result['totals'] as Map? ?? {};
      final items = result['items'] as List? ?? [];
      final db = ref.read(databaseProvider);

      // Determine meal name from items or default
      final mealName = items.isNotEmpty
          ? (items.first as Map)['name'] as String? ?? _mealType
          : _mealType;

      final loggedAt = DateTime.now();
      final localId = await db.insertMeal(MealLogsCompanion(
        name: Value(mealName),
        mealType: Value(_mealType),
        calories: Value((totals['calories'] ?? 0).toDouble()),
        proteinG: Value((totals['protein_g'] ?? 0).toDouble()),
        carbsG: Value((totals['carbs_g'] ?? 0).toDouble()),
        fatG: Value((totals['fat_g'] ?? 0).toDouble()),
        fiberG: Value((totals['fiber_g'] ?? 0).toDouble()),
        itemsJson: Value(jsonEncode(items)),
        healthScore: Value((result['health_score'] as int?) ?? 7),
        aiFeedback: Value((result['feedback'] as String?) ?? ''),
        loggedAt: Value(loggedAt),
      ));

      // Sync to Firestore — when push succeeds, write the cloud doc ID back
      // onto the local row so future deletes can target it directly.
      final uid = AuthService.uid;
      if (uid != null) {
        FirestoreService.addMealLog(uid, {
          'name': mealName,
          'mealType': _mealType,
          'calories': (totals['calories'] ?? 0).toDouble(),
          'proteinG': (totals['protein_g'] ?? 0).toDouble(),
          'carbsG': (totals['carbs_g'] ?? 0).toDouble(),
          'fatG': (totals['fat_g'] ?? 0).toDouble(),
          'loggedAt': loggedAt.toIso8601String(),
        }).then((cloudId) {
          if (cloudId.isNotEmpty) db.setMealCloudId(localId, cloudId);
        }).catchError((Object e) {
          debugPrint('[Firestore] meal sync failed: $e');
        });
      }

      // Rich analytics — fetch today's pre-log totals so the event carries
      // before/after/remaining/goal-reached for every macro. Lets a funnel
      // slice by "which meals actually closed the daily protein gap", etc.
      final priorMeals = await db.watchTodaysMeals().first;
      double priorCal = 0, priorP = 0, priorC = 0, priorF = 0, priorFib = 0;
      for (final m in priorMeals) {
        // Drop THIS just-inserted meal from the before-totals.
        if (m.id == localId) continue;
        priorCal += m.calories;
        priorP += m.proteinG;
        priorC += m.carbsG;
        priorF += m.fatG;
        priorFib += m.fiberG;
      }
      final addedCal = (totals['calories'] as num?)?.toDouble() ?? 0;
      final addedP = (totals['protein_g'] as num?)?.toDouble() ?? 0;
      final addedC = (totals['carbs_g'] as num?)?.toDouble() ?? 0;
      final addedF = (totals['fat_g'] as num?)?.toDouble() ?? 0;
      final addedFib = (totals['fiber_g'] as num?)?.toDouble() ?? 0;
      final totalCal = priorCal + addedCal;
      final totalP = priorP + addedP;
      final totalC = priorC + addedC;
      final totalF = priorF + addedF;
      final targets = ref.read(nutritionTargetsProvider);
      double pct(double have, double target) =>
          target <= 0 ? 0 : (have / target) * 100;
      AnalyticsService.instance.track('meal_logged', props: {
        'meal_type': _mealType,
        'source': 'photo_or_text',
        // This meal
        'calories': addedCal,
        'protein_g': addedP,
        'carbs_g': addedC,
        'fat_g': addedF,
        'fiber_g': addedFib,
        'health_score': result['health_score'] ?? 0,
        'ai_source': _lastAiSource,
        'item_count': items.length,
        // Before
        'total_before_cal': priorCal.round(),
        'total_before_protein': priorP.round(),
        'total_before_carbs': priorC.round(),
        'total_before_fat': priorF.round(),
        'total_before_fiber': priorFib.round(),
        // After
        'total_after_cal': totalCal.round(),
        'total_after_protein': totalP.round(),
        'total_after_carbs': totalC.round(),
        'total_after_fat': totalF.round(),
        // Remaining
        'remaining_cal': (targets.calories - totalCal).round(),
        'remaining_protein': (targets.proteinG - totalP).round(),
        'remaining_carbs': (targets.carbsG - totalC).round(),
        'remaining_fat': (targets.fatG - totalF).round(),
        // Goals
        'goal_cal': targets.calories.round(),
        'goal_protein': targets.proteinG.round(),
        'goal_carbs': targets.carbsG.round(),
        'goal_fat': targets.fatG.round(),
        // % of goal
        'pct_cal': pct(totalCal, targets.calories).round(),
        'pct_protein': pct(totalP, targets.proteinG).round(),
        'pct_carbs': pct(totalC, targets.carbsG).round(),
        'pct_fat': pct(totalF, targets.fatG).round(),
        // Status flags
        'meal_index_today': priorMeals.length, // ordinal of this meal today
        'cal_goal_reached': totalCal >= targets.calories,
        'protein_goal_reached': totalP >= targets.proteinG,
        'over_cal_cap': totalCal > targets.calories,
      });

      // Mascot celebrates — visible next time the user opens AI Coach.
      // Lighter quirk for meals (happens many times a day) vs workouts.
      ref.read(mascotMoodProvider.notifier).celebrate();
      ref.read(mascotQuirkProvider.notifier).play(MascotQuirk.noticeSomething);

      // Award XP
      await ref.read(gamificationProvider.notifier).awardXp(
        15,
        checkStreak: true,
        reason: 'meal_logged',
      );

      if (mounted) {
        HapticFeedback.mediumImpact();
        SnackbarService.success('Meal saved! +15 XP ⚡');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save meal: ${e.toString()}'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: LiquidAppBar(
        title: const Text('Log Meal'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              // Meal type selector
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                  vertical: 6,
                ),
                child: Row(
                  children: ['breakfast', 'lunch', 'dinner', 'snack'].map((t) {
                    final selected = _mealType == t;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          AnalyticsService.instance.tap('meal_type_selected', screen: 'log_meal', props: {'meal_type': t});
                          setState(() => _mealType = t);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: selected ? colors.lime : colors.surfaceCard,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: selected
                                  ? colors.lime
                                  : colors.surfaceCardBorder,
                            ),
                          ),
                          child: Text(
                            t[0].toUpperCase() + t.substring(1),
                            textAlign: TextAlign.center,
                            style: AppTypography.overline.copyWith(
                              color: selected
                                  ? colors.textInverse
                                  : colors.textTertiary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              TabBar(
                controller: _tabs,
                indicatorColor: colors.lime,
                indicatorWeight: 2,
                labelColor: colors.lime,
                unselectedLabelColor: colors.textTertiary,
                labelStyle: AppTypography.overline,
                tabs: const [
                  Tab(text: 'CAMERA'),
                  Tab(text: 'TEXT'),
                  Tab(text: 'SEARCH'),
                  Tab(text: 'SCAN'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          RecentMealsStrip(
            onSelect: (meal) {
              // Re-log the previous meal directly — no AI analysis needed
              setState(() {
                _analysisResult = {
                  'name': meal.name,
                  'calories': meal.calories,
                  'protein_g': meal.proteinG,
                  'carbs_g': meal.carbsG,
                  'fat_g': meal.fatG,
                  'fiber_g': meal.fiberG,
                  'health_score': meal.healthScore,
                  'feedback': 'Re-logged from recent meals.',
                  'items': [],
                };
              });
              _saveMeal();
            },
          ),
          Expanded(
            child: TabBarView(
        controller: _tabs,
        children: [
          _CameraTab(
            isAnalyzing: _isAnalyzing,
            isSaving: _isSaving,
            result: _analysisResult,
            imageBytes: _lastImageBytes,
            targets: ref.watch(nutritionTargetsProvider),
            onPickPhoto: _pickAndAnalyzePhoto,
            onSave: _saveMeal,
          ),
          _TextTab(
            controller: _textController,
            isAnalyzing: _isAnalyzing,
            isSaving: _isSaving,
            result: _analysisResult,
            targets: ref.watch(nutritionTargetsProvider),
            onAnalyze: _analyzeText,
            onSave: _saveMeal,
          ),
          _SearchTab(),
          _ScanTab(
            isSaving: _isSaving,
            targets: ref.watch(nutritionTargetsProvider),
            onSaveResult: _saveFromScan,
          ),
        ],
      ),
          ),
        ],
      ),
    );
  }

  /// Called by [_ScanTab] when a food item has been scanned and is ready to log.
  Future<void> _saveFromScan(Map<String, dynamic> result) async {
    _analysisResult = result;
    await _saveMeal();
  }
}

class _CameraTab extends StatelessWidget {
  final bool isAnalyzing;
  final bool isSaving;
  final Map<String, dynamic>? result;
  final Uint8List? imageBytes;
  final NutritionTargets targets;
  final Future<void> Function(ImageSource) onPickPhoto;
  final Future<void> Function() onSave;

  const _CameraTab({
    required this.isAnalyzing,
    required this.isSaving,
    required this.result,
    required this.imageBytes,
    required this.targets,
    required this.onPickPhoto,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        children: [
          // Camera actions
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: '📸  Take Photo',
                  onPressed: () => onPickPhoto(ImageSource.camera),
                  variant: AppButtonVariant.ghost,
                  height: 56,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: '🖼️  Choose Photo',
                  onPressed: () => onPickPhoto(ImageSource.gallery),
                  variant: AppButtonVariant.secondary,
                  height: 56,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          if (isAnalyzing) ...[
            // Cinematic scan: laser sweeps top-to-bottom across the photo
            // while Gemini analyses. Falls back to plain spinner if no photo.
            if (imageBytes != null)
              _PhotoScanLaser(imageBytes: imageBytes!)
            else
              _AnalyzingIndicator(),
          ] else if (result != null) ...[
            _AnalysisResultCard(
              result: result!,
              imageBytes: imageBytes,
              targets: targets,
              isSaving: isSaving,
              onSave: onSave,
            ),
          ] else ...[
            // Placeholder with mascot — gives the empty state a heartbeat.
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: colors.surfaceCardBorder),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SparkMascot.reactive(size: 64),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Snap a meal — I\'ll do the math',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Identifies ingredients & calculates macros',
                      style: AppTypography.caption.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TextTab extends StatelessWidget {
  final TextEditingController controller;
  final bool isAnalyzing;
  final bool isSaving;
  final Map<String, dynamic>? result;
  final NutritionTargets targets;
  final VoidCallback onAnalyze;
  final Future<void> Function() onSave;

  const _TextTab({
    required this.controller,
    required this.isAnalyzing,
    required this.isSaving,
    required this.result,
    required this.targets,
    required this.onAnalyze,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Describe your meal',
            style: AppTypography.bodyMedium.copyWith(color: context.colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            style: AppTypography.body,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'e.g. 2 scrambled eggs, 2 slices whole wheat toast with butter, black coffee',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: isAnalyzing ? 'Analyzing...' : '🤖  Analyze with AI',
            isLoading: isAnalyzing,
            onPressed: isAnalyzing ? null : onAnalyze,
          ),
          if (result != null) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            _AnalysisResultCard(
              result: result!,
              imageBytes: null,
              targets: targets,
              isSaving: isSaving,
              onSave: onSave,
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends ConsumerState<_SearchTab> {
  final _ctrl = TextEditingController();
  List<FoodSearchResult> _results = [];
  double _servings = 1.0;
  FoodEntry? _selected;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Ensure knowledge base is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(foodKnowledgeLoadProvider);
    });
  }

  void _search(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _selected = null;
      });
      return;
    }
    final kb = ref.read(foodKnowledgeProvider);
    setState(() {
      _results = kb.search(query, limit: 25);
      _selected = null;
    });
  }

  Future<void> _saveFood() async {
    if (_selected == null) return;
    setState(() => _isSaving = true);

    final food = _selected!;
    final cal = food.cal * _servings;
    final prot = food.protein * _servings;
    final carbs = food.carbs * _servings;
    final fat = food.fat * _servings;

    final db = ref.read(databaseProvider);
    final loggedAt = DateTime.now();
    final localId = await db.insertMeal(MealLogsCompanion(
      name: Value(food.name),
      mealType: Value(_guessMealType()),
      calories: Value(cal),
      proteinG: Value(prot),
      carbsG: Value(carbs),
      fatG: Value(fat),
      itemsJson: Value(jsonEncode([
        {'name': food.name, 'calories': cal, 'protein_g': prot, 'carbs_g': carbs, 'fat_g': fat}
      ])),
      loggedAt: Value(loggedAt),
    ));

    // Firestore sync — write the cloud doc ID back onto the local row.
    final uid = AuthService.uid;
    if (uid != null) {
      FirestoreService.addMealLog(uid, {
        'name': food.name,
        'mealType': _guessMealType(),
        'calories': cal,
        'proteinG': prot,
        'carbsG': carbs,
        'fatG': fat,
        'loggedAt': loggedAt.toIso8601String(),
      }).then((cloudId) {
        if (cloudId.isNotEmpty) db.setMealCloudId(localId, cloudId);
      }).catchError((Object e) {
        debugPrint('[Firestore] quick meal sync failed: $e');
      });
    }

    await ref.read(gamificationProvider.notifier).awardXp(
      10,
      checkStreak: true,
      reason: 'meal_logged',
    );

    AnalyticsService.instance.track('meal_logged', props: {
      'meal_type': _guessMealType(),
      'calories': cal,
      'protein_g': prot,
      'carbs_g': carbs,
      'fat_g': fat,
      'ai_source': 'search',
      'item_count': 1,
    });

    if (mounted) {
      setState(() => _isSaving = false);
      HapticFeedback.mediumImpact();
      SnackbarService.success('${food.name} logged! +10 XP ⚡');
      Navigator.pop(context);
    }
  }

  String _guessMealType() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'breakfast';
    if (hour < 15) return 'lunch';
    if (hour < 20) return 'dinner';
    return 'snack';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final kbLoad = ref.watch(foodKnowledgeLoadProvider);
    final totalFoods = ref.read(foodKnowledgeProvider).allFoods.length;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        children: [
          TextField(
            controller: _ctrl,
            style: AppTypography.body,
            onChanged: _search,
            decoration: InputDecoration(
              hintText: 'Search food database...',
              prefixIcon: Icon(Icons.search, color: colors.textTertiary, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (_selected != null) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selected!.name,
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (_selected!.dietary != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _selected!.dietary == 'veg'
                                ? colors.success.withValues(alpha: 0.1)
                                : colors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            _selected!.dietary == 'veg' ? '🟢 Veg' : '🔴 Non-veg',
                            style: AppTypography.overline.copyWith(
                              color: _selected!.dietary == 'veg'
                                  ? colors.success
                                  : colors.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Per ${_selected!.serving}',
                    style: AppTypography.caption.copyWith(color: colors.textTertiary),
                  ),
                  if (_selected!.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _selected!.description!,
                      style: AppTypography.caption.copyWith(color: colors.textTertiary),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _MacroChip('Cal', (_selected!.cal * _servings).toStringAsFixed(0), colors.warning),
                      _MacroChip('P', '${(_selected!.protein * _servings).toStringAsFixed(1)}g', AppColorsExtension.macroProtein),
                      _MacroChip('C', '${(_selected!.carbs * _servings).toStringAsFixed(1)}g', AppColorsExtension.macroCarbs),
                      _MacroChip('F', '${(_selected!.fat * _servings).toStringAsFixed(1)}g', AppColorsExtension.macroFat),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Text('Servings:', style: AppTypography.bodyMedium),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: colors.textTertiary),
                        onPressed: _servings > 0.5
                            ? () => setState(() => _servings -= 0.5)
                            : null,
                      ),
                      Text(
                        _servings.toStringAsFixed(1),
                        style: AppTypography.h3.copyWith(color: colors.lime),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline, color: colors.lime),
                        onPressed: () => setState(() => _servings += 0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: _isSaving ? 'Saving...' : 'Log Food (+10 XP)',
                      onPressed: _isSaving ? null : _saveFood,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_results.isEmpty && _ctrl.text.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No results found',
              style: AppTypography.bodyMedium.copyWith(color: colors.textTertiary),
            ),
          ] else if (_results.isEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            kbLoad.when(
              data: (_) => Text(
                'Search $totalFoods foods (Indian + common)',
                style: AppTypography.caption.copyWith(color: colors.textTertiary),
              ),
              loading: () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: colors.lime),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Loading food database...',
                    style: AppTypography.caption.copyWith(color: colors.textTertiary),
                  ),
                ],
              ),
              error: (_, __) => Text(
                'Search common foods',
                style: AppTypography.caption.copyWith(color: colors.textTertiary),
              ),
            ),
          ],

          if (_results.isNotEmpty && _selected == null)
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (_, i) {
                  final food = _results[i].food;
                  final score = _results[i].score;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    leading: food.dietary != null
                        ? Text(
                            food.dietary == 'veg' ? '🟢' : '🔴',
                            style: const TextStyle(fontSize: 14),
                          )
                        : null,
                    title: Text(food.name, style: AppTypography.bodyMedium),
                    subtitle: Text(
                      '${food.cal.toStringAsFixed(0)} kcal · P${food.protein}g · C${food.carbs}g · F${food.fat}g  (${food.serving})',
                      style: AppTypography.caption.copyWith(color: colors.textTertiary),
                    ),
                    trailing: score > AppConstants.foodMatchScoreThreshold
                        ? Icon(Icons.verified, color: colors.lime, size: 16)
                        : null,
                    onTap: () => setState(() {
                      _selected = food;
                      _servings = 1.0;
                    }),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MacroChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: color)),
        Text(label, style: AppTypography.overline.copyWith(color: context.colors.textTertiary)),
      ],
    );
  }
}

class _AnalyzingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      backgroundColor: colors.limeGlow,
      borderColor: colors.lime.withValues(alpha: 0.3),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colors.lime,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            'AI is analyzing your meal...',
            style: AppTypography.bodyMedium.copyWith(color: colors.lime),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

/// Signature scan animation — lime laser line sweeps top→bottom across the
/// uploaded photo while AI thinks. Plus a faint scanline grid overlay for
/// "tron" effect. Drops a status caption below.
///
/// Roughly 1.6s per sweep, repeats. Stops once analysis returns and the
/// parent swaps in [_AnalysisResultCard].
class _PhotoScanLaser extends StatefulWidget {
  final Uint8List imageBytes;
  const _PhotoScanLaser({required this.imageBytes});

  @override
  State<_PhotoScanLaser> createState() => _PhotoScanLaserState();
}

class _PhotoScanLaserState extends State<_PhotoScanLaser>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              // Photo
              Image.memory(
                widget.imageBytes,
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
              ),
              // Slight darkening so the laser pops
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.18),
                ),
              ),
              // Laser sweep
              AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) {
                  final t = _ctrl.value; // 0..1
                  // Sweep down 0..1, then fade out the trailing tip
                  return Positioned.fill(
                    child: CustomPaint(
                      painter: _LaserPainter(
                        progress: t,
                        color: colors.lime,
                      ),
                    ),
                  );
                },
              ),
              // Top-left "scanning" badge
              Positioned(
                top: 10, left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: colors.lime.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          color: colors.lime, shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colors.lime.withValues(alpha: 0.9),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                          .fade(begin: 1, end: 0.4, duration: 600.ms),
                      const SizedBox(width: 6),
                      Text(
                        'SCANNING',
                        style: AppTypography.overline.copyWith(
                          color: colors.lime,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Corner brackets — viewfinder-style, hint at AI vision
              Positioned.fill(
                child: CustomPaint(
                  painter: _CornerBracketsPainter(color: colors.lime),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Status caption
        Row(
          children: [
            SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                color: colors.lime,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Identifying ingredients & calculating macros…',
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 250.ms);
  }
}

/// Paints a horizontal laser line + soft glow that sweeps down the photo.
class _LaserPainter extends CustomPainter {
  final double progress;
  final Color color;
  _LaserPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Sweep lives in [0, 1.1] band so it disappears off the bottom
    // before snapping back to the top — feels continuous.
    final eased = Curves.easeInOut.transform(progress);
    final y = eased * size.height;

    // Trail gradient: brighter at the line, fading upward.
    final trailRect = Rect.fromLTWH(
      0,
      (y - 80).clamp(0, size.height),
      size.width,
      80,
    );
    final trailPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.18),
        ],
      ).createShader(trailRect);
    canvas.drawRect(trailRect, trailPaint);

    // The laser line itself with a soft glow.
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRect(Rect.fromLTWH(0, y - 1, size.width, 3), glowPaint);

    final corePaint = Paint()..color = color.withValues(alpha: 0.95);
    canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1.5), corePaint);
  }

  @override
  bool shouldRepaint(covariant _LaserPainter old) =>
      old.progress != progress || old.color != color;
}

/// Static viewfinder-style corner brackets — adds "AI vision" cue.
class _CornerBracketsPainter extends CustomPainter {
  final Color color;
  _CornerBracketsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const len = 18.0;
    const inset = 8.0;
    // top-left
    canvas.drawLine(Offset(inset, inset), Offset(inset + len, inset), paint);
    canvas.drawLine(Offset(inset, inset), Offset(inset, inset + len), paint);
    // top-right
    canvas.drawLine(Offset(size.width - inset, inset),
        Offset(size.width - inset - len, inset), paint);
    canvas.drawLine(Offset(size.width - inset, inset),
        Offset(size.width - inset, inset + len), paint);
    // bottom-left
    canvas.drawLine(Offset(inset, size.height - inset),
        Offset(inset + len, size.height - inset), paint);
    canvas.drawLine(Offset(inset, size.height - inset),
        Offset(inset, size.height - inset - len), paint);
    // bottom-right
    canvas.drawLine(Offset(size.width - inset, size.height - inset),
        Offset(size.width - inset - len, size.height - inset), paint);
    canvas.drawLine(Offset(size.width - inset, size.height - inset),
        Offset(size.width - inset, size.height - inset - len), paint);
  }

  @override
  bool shouldRepaint(_CornerBracketsPainter old) => old.color != color;
}

class _AnalysisResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  final Uint8List? imageBytes;
  final NutritionTargets targets;
  final bool isSaving;
  final Future<void> Function() onSave;

  const _AnalysisResultCard({
    required this.result,
    required this.imageBytes,
    required this.targets,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = (result['items'] as List?) ?? [];
    final totals = result['totals'] as Map? ?? {};
    final score = (result['health_score'] as num?)?.toInt() ?? 0;
    final feedback = result['feedback'] as String? ?? '';
    final scoreClr = _scoreColor(score, colors);
    final mealName = result['meal_name'] as String? ?? '';
    final ingredients = (result['ingredients'] as List?)?.cast<String>() ?? [];
    final availability = (result['availability'] as List?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [];
    final bestPrice = result['best_price'];
    final currency = result['currency'] as String? ?? 'PKR';
    final bestArea = availability.isNotEmpty
        ? (availability.first['area'] as String? ?? '')
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Photo thumbnail ────────────────────────────────────────
        if (imageBytes != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Image.memory(
              imageBytes!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // ── Header row: status + score ─────────────────────────────
        Row(
          children: [
            const Text('✅', style: TextStyle(fontSize: 18)),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'AI Analysis Complete',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.success,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: scoreClr.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: scoreClr.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Score: $score/10',
                style: AppTypography.caption.copyWith(
                  color: scoreClr,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        // ── Meal name ──────────────────────────────────────────────
        if (mealName.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            mealName,
            style: AppTypography.h2.copyWith(fontWeight: FontWeight.w800),
          ),
        ],

        const SizedBox(height: AppSpacing.md),

        // ── Ingredients ────────────────────────────────────────────
        if (ingredients.isNotEmpty) ...[
          AppCard(
            backgroundColor: colors.bgSecondary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INGREDIENTS',
                  style: AppTypography.overline.copyWith(color: colors.textTertiary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ingredients.map((ing) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: colors.surfaceCardBorder),
                    ),
                    child: Text(
                      ing,
                      style: AppTypography.caption.copyWith(color: colors.textSecondary),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // ── Availability & Pricing ─────────────────────────────────
        if (availability.isNotEmpty) ...[
          AppCard(
            backgroundColor: colors.bgSecondary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'AVAILABILITY & PRICE',
                      style: AppTypography.overline.copyWith(color: colors.textTertiary),
                    ),
                    const Spacer(),
                    Text(
                      currency,
                      style: AppTypography.overline.copyWith(color: colors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ...availability.map((a) {
                  final area = a['area'] as String? ?? '';
                  final minP = (a['min_price'] as num?)?.toInt() ?? 0;
                  final maxP = (a['max_price'] as num?)?.toInt() ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Text('📍', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            area,
                            style: AppTypography.body.copyWith(color: colors.textSecondary),
                          ),
                        ),
                        Text(
                          'Rs $minP – $maxP',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (bestPrice != null && bestArea.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: colors.lime.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: colors.lime.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Text('💰', style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Best price: Rs $bestPrice at $bestArea',
                            style: AppTypography.caption.copyWith(
                              color: colors.lime,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // ── Items detected ─────────────────────────────────────────
        if (items.isNotEmpty) ...[
          Text(
            'ITEMS DETECTED',
            style: AppTypography.overline.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (item as Map)['name'] as String? ?? '',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${item['quantity_g']}g',
                          style: AppTypography.caption.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${item['calories']} kcal',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.warning,
                    ),
                  ),
                ],
              ),
            ),
          )),
          const SizedBox(height: AppSpacing.sm),
        ],

        // ── Totals macro bars ──────────────────────────────────────
        AppCard(
          backgroundColor: colors.bgTertiary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTALS',
                style: AppTypography.overline.copyWith(color: colors.textTertiary),
              ),
              const SizedBox(height: AppSpacing.md),
              MacroBar(
                label: 'Protein',
                consumed: (totals['protein_g'] ?? 0).toDouble(),
                target: targets.proteinG,
                color: AppColors.macroProtein,
              ),
              const SizedBox(height: AppSpacing.sm),
              MacroBar(
                label: 'Carbs',
                consumed: (totals['carbs_g'] ?? 0).toDouble(),
                target: targets.carbsG,
                color: AppColors.macroCarbs,
              ),
              const SizedBox(height: AppSpacing.sm),
              MacroBar(
                label: 'Fat',
                consumed: (totals['fat_g'] ?? 0).toDouble(),
                target: targets.fatG,
                color: AppColors.macroFat,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── AI feedback ────────────────────────────────────────────
        AppCard(
          backgroundColor: colors.infoBg,
          borderColor: colors.info.withValues(alpha: 0.3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🤖', style: TextStyle(fontSize: 18)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  feedback,
                  style: AppTypography.body.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sectionGap),

        AppButton(
          label: isSaving ? 'Saving...' : '✅  Save Meal (+15 XP)',
          isLoading: isSaving,
          onPressed: isSaving ? null : onSave,
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Color _scoreColor(int score, AppColorsExtension colors) {
    if (score >= 8) return colors.success;
    if (score >= 6) return colors.lime;
    if (score >= 4) return colors.warning;
    return colors.error;
  }
}

// ── Scan Tab ──────────────────────────────────────────────────────────────────

class _ScanTab extends StatefulWidget {
  final bool isSaving;
  final NutritionTargets targets;
  final Future<void> Function(Map<String, dynamic> result) onSaveResult;

  const _ScanTab({
    required this.isSaving,
    required this.targets,
    required this.onSaveResult,
  });

  @override
  State<_ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<_ScanTab> {
  bool _isLooking = false;
  FoodItem? _item;
  double _servingGrams = 100;
  String? _error;

  Map<String, dynamic> _toResult(FoodItem item, double grams) {
    final scaled = item.scaledTo(grams);
    return scaled.toResultMap();
  }

  Future<void> _openScanner(BuildContext context) async {
    final barcode = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const BarcodeScanScreen(),
        fullscreenDialog: true,
      ),
    );
    if (barcode == null || !mounted) return;

    setState(() {
      _isLooking = true;
      _item = null;
      _error = null;
    });

    final item = await FoodDatabaseService.instance.fetchByBarcode(barcode);

    if (!mounted) return;
    if (item == null) {
      setState(() {
        _isLooking = false;
        _error = 'Product not found in database.\nTry the TEXT tab to describe it.';
      });
      AnalyticsService.instance.track('barcode_scan_not_found',
          props: {'barcode': barcode});
      return;
    }

    setState(() {
      _isLooking = false;
      _item = item;
      _servingGrams = 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Scan button
          AppButton(
            label: '📷  Scan Barcode',
            onPressed: _isLooking ? null : () => _openScanner(context),
            height: 56,
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          if (_isLooking) ...[
            _AnalyzingIndicator(),
          ] else if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: colors.error.withAlpha(80)),
              ),
              child: Column(
                children: [
                  const Text('😕', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _error!,
                    style: AppTypography.body.copyWith(
                      color: colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else if (_item != null) ...[
            _ScannedItemCard(
              item: _item!,
              servingGrams: _servingGrams,
              isSaving: widget.isSaving,
              onServingChanged: (v) => setState(() => _servingGrams = v),
              onSave: () => widget.onSaveResult(_toResult(_item!, _servingGrams)),
            ),
          ] else ...[
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: colors.surfaceCardBorder),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔲', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Scan a food barcode',
                      style: AppTypography.bodyMedium
                          .copyWith(color: colors.textTertiary),
                    ),
                    Text(
                      'Powered by Open Food Facts',
                      style: AppTypography.caption
                          .copyWith(color: colors.textTertiary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScannedItemCard extends StatelessWidget {
  final FoodItem item;
  final double servingGrams;
  final bool isSaving;
  final void Function(double) onServingChanged;
  final VoidCallback onSave;

  const _ScannedItemCard({
    required this.item,
    required this.servingGrams,
    required this.isSaving,
    required this.onServingChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scaled = item.scaledTo(servingGrams);
    final servingOptions = [50.0, 100.0, 150.0, 200.0, 250.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          item.name,
          style: AppTypography.h3,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.md),

        // Serving size chips
        Text(
          'SERVING SIZE',
          style: AppTypography.overline.copyWith(color: colors.textTertiary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          children: servingOptions.map((g) {
            final selected = servingGrams == g;
            return GestureDetector(
              onTap: () => onServingChanged(g),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? colors.limeGlow : colors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: selected ? colors.lime : colors.surfaceCardBorder,
                  ),
                ),
                child: Text(
                  '${g.toInt()} g',
                  style: AppTypography.caption.copyWith(
                    color: selected ? colors.lime : colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: AppSpacing.md),

        // Macro summary row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _MacroChip('CAL', scaled.caloriesPer100g.toStringAsFixed(0), const Color(0xFFFBBF24)),
            _MacroChip('PROT', '${scaled.proteinPer100g.toStringAsFixed(1)}g', colors.cyan),
            _MacroChip('CARBS', '${scaled.carbsPer100g.toStringAsFixed(1)}g', colors.lime),
            _MacroChip('FAT', '${scaled.fatPer100g.toStringAsFixed(1)}g', colors.error),
          ],
        ),

        const SizedBox(height: AppSpacing.sectionGap),

        AppButton(
          label: isSaving
              ? 'Saving...'
              : '✅  Log ${servingGrams.toInt()} g (+15 XP)',
          isLoading: isSaving,
          onPressed: isSaving ? null : onSave,
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

