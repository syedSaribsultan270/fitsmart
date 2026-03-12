import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/utils/mime_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_extension.dart';
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
import '../../../providers/food_knowledge_provider.dart';
import '../../../services/food_knowledge_service.dart';
import '../../../services/user_context_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/snackbar_service.dart';

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
  String _mealType = _defaultMealType();

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
    _tabs = TabController(length: 3, vsync: this);
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

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisResult = result;
        });
      }
    } catch (e) {
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
    });

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
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisResult = result;
        });
      }
    } catch (e) {
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

      await db.insertMeal(MealLogsCompanion(
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
        loggedAt: Value(DateTime.now()),
      ));

      // Sync to Firestore (fire-and-forget)
      final uid = AuthService.uid;
      if (uid != null) {
        FirestoreService.addMealLog(uid, {
          'name': mealName,
          'mealType': _mealType,
          'calories': (totals['calories'] ?? 0).toDouble(),
          'proteinG': (totals['protein_g'] ?? 0).toDouble(),
          'carbsG': (totals['carbs_g'] ?? 0).toDouble(),
          'fatG': (totals['fat_g'] ?? 0).toDouble(),
          'loggedAt': DateTime.now().toIso8601String(),
        }).catchError((e) { debugPrint('[Firestore] meal sync failed: $e'); return ''; });
      }

      // Award XP
      await ref.read(gamificationProvider.notifier).awardXp(
        15,
        checkStreak: true,
      );

      if (mounted) {
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
      appBar: AppBar(
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
                        onTap: () => setState(() => _mealType = t),
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
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _CameraTab(
            isAnalyzing: _isAnalyzing,
            isSaving: _isSaving,
            result: _analysisResult,
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
        ],
      ),
    );
  }
}

class _CameraTab extends StatelessWidget {
  final bool isAnalyzing;
  final bool isSaving;
  final Map<String, dynamic>? result;
  final NutritionTargets targets;
  final Future<void> Function(ImageSource) onPickPhoto;
  final Future<void> Function() onSave;

  const _CameraTab({
    required this.isAnalyzing,
    required this.isSaving,
    required this.result,
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
            _AnalyzingIndicator(),
          ] else if (result != null) ...[
            _AnalysisResultCard(
              result: result!,
              targets: targets,
              isSaving: isSaving,
              onSave: onSave,
            ),
          ] else ...[
            // Placeholder
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: colors.surfaceCardBorder,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('📷', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Take a photo of your meal',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                    Text(
                      'AI will identify & calculate macros',
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
    await db.insertMeal(MealLogsCompanion(
      name: Value(food.name),
      mealType: Value(_guessMealType()),
      calories: Value(cal),
      proteinG: Value(prot),
      carbsG: Value(carbs),
      fatG: Value(fat),
      itemsJson: Value(jsonEncode([
        {'name': food.name, 'calories': cal, 'protein_g': prot, 'carbs_g': carbs, 'fat_g': fat}
      ])),
      loggedAt: Value(DateTime.now()),
    ));

    // Firestore sync
    final uid = AuthService.uid;
    if (uid != null) {
      FirestoreService.addMealLog(uid, {
        'name': food.name,
        'mealType': _guessMealType(),
        'calories': cal,
        'proteinG': prot,
        'carbsG': carbs,
        'fatG': fat,
        'loggedAt': DateTime.now().toIso8601String(),
      }).catchError((e) { debugPrint('[Firestore] quick meal sync failed: $e'); return ''; });
    }

    await ref.read(gamificationProvider.notifier).awardXp(10, checkStreak: true);

    if (mounted) {
      setState(() => _isSaving = false);
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
                    trailing: score > 0.89
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

class _AnalysisResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  final NutritionTargets targets;
  final bool isSaving;
  final Future<void> Function() onSave;

  const _AnalysisResultCard({
    required this.result,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: AppSpacing.md),

        // Items list
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

        // Totals
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

        // AI feedback
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
