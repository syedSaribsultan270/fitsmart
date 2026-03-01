import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/macro_bar.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../features/dashboard/providers/dashboard_provider.dart';
import '../../../providers/gemini_provider.dart';
import '../../../services/gemini_client.dart';
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
    final targets = ref.read(nutritionTargetsProvider);
    final nutrition = ref.read(dailyNutritionProvider);
    return {
      'target_calories': targets.calories,
      'target_protein_g': targets.proteinG,
      'consumed_calories_today': nutrition.consumedCalories,
      'consumed_protein_today': nutrition.consumedProtein,
      'meal_type': _mealType,
    };
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
      // Compress image before sending to Gemini
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

      final gemini = ref.read(geminiClientProvider);
      final result = await gemini.analyzeMealPhoto(
        imageBytes: compressed,
        userContext: _buildUserContext(),
      );

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisResult = result;
        });
      }
    } on GeminiException catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to analyze photo. Please try again.'),
            backgroundColor: AppColors.error,
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
      final gemini = ref.read(geminiClientProvider);
      final result = await gemini.analyzeMealText(
        description: _textController.text.trim(),
        userContext: _buildUserContext(),
      );
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisResult = result;
        });
      }
    } on GeminiException catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analysis failed. Please try again.'),
            backgroundColor: AppColors.error,
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
        }).catchError((_) => '');
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
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
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
                            color: selected ? AppColors.lime : AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: selected
                                  ? AppColors.lime
                                  : AppColors.surfaceCardBorder,
                            ),
                          ),
                          child: Text(
                            t[0].toUpperCase() + t.substring(1),
                            textAlign: TextAlign.center,
                            style: AppTypography.overline.copyWith(
                              color: selected
                                  ? AppColors.textInverse
                                  : AppColors.textTertiary,
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
                indicatorColor: AppColors.lime,
                indicatorWeight: 2,
                labelColor: AppColors.lime,
                unselectedLabelColor: AppColors.textTertiary,
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
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColors.surfaceCardBorder,
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
                        color: AppColors.textTertiary,
                      ),
                    ),
                    Text(
                      'AI will identify & calculate macros',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
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
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
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
  List<Map<String, dynamic>> _allFoods = [];
  List<Map<String, dynamic>> _results = [];
  double _servings = 1.0;
  Map<String, dynamic>? _selected;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadFoodDb();
  }

  Future<void> _loadFoodDb() async {
    final data = await DefaultAssetBundle.of(context)
        .loadString('assets/data/common_foods.json');
    final list = (jsonDecode(data) as List).cast<Map<String, dynamic>>();
    setState(() => _allFoods = list);
  }

  void _search(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _selected = null;
      });
      return;
    }
    final q = query.toLowerCase();
    setState(() {
      _results = _allFoods
          .where((f) => (f['name'] as String).toLowerCase().contains(q))
          .take(20)
          .toList();
      _selected = null;
    });
  }

  Future<void> _saveFood() async {
    if (_selected == null) return;
    setState(() => _isSaving = true);

    final food = _selected!;
    final cal = (food['cal'] as num).toDouble() * _servings;
    final prot = (food['p'] as num).toDouble() * _servings;
    final carbs = (food['c'] as num).toDouble() * _servings;
    final fat = (food['f'] as num).toDouble() * _servings;

    final db = ref.read(databaseProvider);
    await db.insertMeal(MealLogsCompanion(
      name: Value(food['name'] as String),
      mealType: Value(_guessMealType()),
      calories: Value(cal),
      proteinG: Value(prot),
      carbsG: Value(carbs),
      fatG: Value(fat),
      itemsJson: Value(jsonEncode([
        {'name': food['name'], 'calories': cal, 'protein_g': prot, 'carbs_g': carbs, 'fat_g': fat}
      ])),
      loggedAt: Value(DateTime.now()),
    ));

    // Firestore sync
    final uid = AuthService.uid;
    if (uid != null) {
      FirestoreService.addMealLog(uid, {
        'name': food['name'],
        'mealType': _guessMealType(),
        'calories': cal,
        'proteinG': prot,
        'carbsG': carbs,
        'fatG': fat,
        'loggedAt': DateTime.now().toIso8601String(),
      }).catchError((_) => '');
    }

    await ref.read(gamificationProvider.notifier).awardXp(10, checkStreak: true);

    if (mounted) {
      setState(() => _isSaving = false);
      SnackbarService.success('${food['name']} logged! +10 XP ⚡');
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
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        children: [
          TextField(
            controller: _ctrl,
            style: AppTypography.body,
            onChanged: _search,
            decoration: const InputDecoration(
              hintText: 'Search food database...',
              prefixIcon: Icon(Icons.search, color: AppColors.textTertiary, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (_selected != null) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selected!['name'] as String,
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Per ${_selected!['serving']}',
                    style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _MacroChip('Cal', ((_selected!['cal'] as num) * _servings).toStringAsFixed(0), AppColors.warning),
                      _MacroChip('P', '${((_selected!['p'] as num) * _servings).toStringAsFixed(1)}g', AppColors.macroProtein),
                      _MacroChip('C', '${((_selected!['c'] as num) * _servings).toStringAsFixed(1)}g', AppColors.macroCarbs),
                      _MacroChip('F', '${((_selected!['f'] as num) * _servings).toStringAsFixed(1)}g', AppColors.macroFat),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Text('Servings:', style: AppTypography.bodyMedium),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.textTertiary),
                        onPressed: _servings > 0.5
                            ? () => setState(() => _servings -= 0.5)
                            : null,
                      ),
                      Text(
                        _servings.toStringAsFixed(1),
                        style: AppTypography.h3.copyWith(color: AppColors.lime),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.lime),
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
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
            ),
          ] else if (_results.isEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Search ${_allFoods.length} common foods',
              style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
            ),
          ],

          if (_results.isNotEmpty && _selected == null)
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (_, i) {
                  final food = _results[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    title: Text(food['name'] as String, style: AppTypography.bodyMedium),
                    subtitle: Text(
                      '${food['cal']} kcal · P${food['p']}g · C${food['c']}g · F${food['f']}g  (${food['serving']})',
                      style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                    ),
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
        Text(label, style: AppTypography.overline.copyWith(color: AppColors.textTertiary)),
      ],
    );
  }
}

class _AnalyzingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.limeGlow,
      borderColor: AppColors.lime.withValues(alpha: 0.3),
      child: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.lime,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            'AI is analyzing your meal...',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.lime),
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
    final items = (result['items'] as List?) ?? [];
    final totals = result['totals'] as Map? ?? {};
    final score = (result['health_score'] as num?)?.toInt() ?? 0;
    final feedback = result['feedback'] as String? ?? '';

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
                color: AppColors.success,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _scoreColor(score).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: _scoreColor(score).withValues(alpha: 0.3)),
              ),
              child: Text(
                'Score: $score/10',
                style: AppTypography.caption.copyWith(
                  color: _scoreColor(score),
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
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${item['calories']} kcal',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        )),

        const SizedBox(height: AppSpacing.sm),

        // Totals
        AppCard(
          backgroundColor: AppColors.bgTertiary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTALS',
                style: AppTypography.overline.copyWith(color: AppColors.textTertiary),
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
          backgroundColor: AppColors.infoBg,
          borderColor: AppColors.info.withValues(alpha: 0.3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🤖', style: TextStyle(fontSize: 18)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  feedback,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
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

  Color _scoreColor(int score) {
    if (score >= 8) return AppColors.success;
    if (score >= 6) return AppColors.lime;
    if (score >= 4) return AppColors.warning;
    return AppColors.error;
  }
}
