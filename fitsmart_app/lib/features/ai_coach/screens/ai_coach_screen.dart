import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/database/database_provider.dart';
import '../../../features/dashboard/providers/dashboard_provider.dart';
import '../../../providers/gemini_provider.dart';
import '../../../services/gemini_client.dart';

class AiCoachScreen extends ConsumerStatefulWidget {
  const AiCoachScreen({super.key});

  @override
  ConsumerState<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends ConsumerState<AiCoachScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_Message> _messages = [];
  final List<Map<String, String>> _history = [];
  bool _isTyping = false;

  static const _prefsKey = 'ai_coach_messages';
  static const _historyKey = 'ai_coach_history';

  static const _suggestions = [
    '🍽️  What should I eat before my workout?',
    '💪  Why am I not seeing muscle gains?',
    '🔥  How do I break through a plateau?',
    '😴  How does sleep affect fat loss?',
    '📊  Analyze my nutrition this week',
    '🏋️  Suggest a deload week workout',
  ];

  @override
  void initState() {
    super.initState();
    _loadChat();
  }

  Future<void> _loadChat() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMessages = prefs.getString(_prefsKey);
    final savedHistory = prefs.getString(_historyKey);

    if (savedMessages != null) {
      try {
        final list = jsonDecode(savedMessages) as List;
        final loaded = list
            .map((e) => _Message(
                  text: e['text'] as String,
                  isAi: e['isAi'] as bool,
                  suggestions: (e['suggestions'] as List?)?.cast<String>() ?? [],
                ))
            .toList();
        if (loaded.isNotEmpty && mounted) {
          setState(() => _messages.addAll(loaded));
        }
      } catch (_) {}
    }

    if (savedHistory != null) {
      try {
        final list = jsonDecode(savedHistory) as List;
        _history.addAll(
          list.map((e) => Map<String, String>.from(e as Map)),
        );
      } catch (_) {}
    }

    // If nothing was loaded, add welcome message
    if (_messages.isEmpty) {
      setState(() {
        _messages.add(const _Message(
          text: 'Hey! I\'m your FitSmart AI coach 🤖\n\nI have full access to your nutrition logs, workout history, and progress data. Ask me anything about your fitness journey — I\'ll give you personalized, data-driven answers.\n\nWhat\'s on your mind?',
          isAi: true,
        ));
      });
    }
  }

  Future<void> _saveChat() async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = _messages
        .map((m) => {
              'text': m.text,
              'isAi': m.isAi,
              'suggestions': m.suggestions,
            })
        .toList();
    await prefs.setString(_prefsKey, jsonEncode(serialized));
    await prefs.setString(_historyKey, jsonEncode(_history));
  }

  Future<void> _clearChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    await prefs.remove(_historyKey);
    setState(() {
      _messages.clear();
      _history.clear();
      _messages.add(const _Message(
        text: 'Hey! I\'m your FitSmart AI coach 🤖\n\nI have full access to your nutrition logs, workout history, and progress data. Ask me anything about your fitness journey — I\'ll give you personalized, data-driven answers.\n\nWhat\'s on your mind?',
        isAi: true,
      ));
    });
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _buildUserContext() async {
    final nutrition = ref.read(dailyNutritionProvider);
    final gamification = ref.read(gamificationProvider);
    final db = ref.read(databaseProvider);

    // ── Full onboarding profile ──────────────────────────────────────────
    Map<String, dynamic> profile = {};
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('onboarding_data');
      if (jsonStr != null) {
        profile = jsonDecode(jsonStr) as Map<String, dynamic>;
      }
    } catch (_) {}

    // ── Today's meals ────────────────────────────────────────────────────
    String todaysMealsStr = '';
    try {
      final meals = await db.getMealsForDate(DateTime.now());
      if (meals.isNotEmpty) {
        final mealLines = meals.map((m) =>
          '${m.mealType}: ${m.name} — ${m.calories.round()} kcal, P:${m.proteinG.toStringAsFixed(0)}g, C:${m.carbsG.toStringAsFixed(0)}g, F:${m.fatG.toStringAsFixed(0)}g (score: ${m.healthScore}/10)').toList();
        todaysMealsStr = mealLines.join('\n');
      }
    } catch (_) {}

    // ── Recent workouts (last 10) ────────────────────────────────────────
    String recentWorkoutsStr = '';
    try {
      final workouts = await db.getRecentWorkouts(limit: 10);
      if (workouts.isNotEmpty) {
        final wLines = workouts.map((w) =>
          '${w.name} — ${(w.durationSeconds / 60).round()} min, ~${w.estimatedCalories.round()} kcal burned (${w.completedAt.toIso8601String().substring(0, 10)})').toList();
        recentWorkoutsStr = wLines.join('\n');
      }
    } catch (_) {}

    // ── Personal records (all PRs) ───────────────────────────────────────
    String prsStr = '';
    try {
      final prs = await db.getAllPrs();
      if (prs.isNotEmpty) {
        final prLines = prs.entries.map((e) =>
          '${e.key}: ${e.value.toStringAsFixed(1)} kg').toList();
        prsStr = prLines.join('\n');
      }
    } catch (_) {}

    // ── Body measurements (latest) ───────────────────────────────────────
    String bodyMeasurementsStr = '';
    try {
      final m = await db.getLatestMeasurement();
      if (m != null) {
        final parts = <String>[];
        if (m.chestCm != null) parts.add('Chest: ${m.chestCm}cm');
        if (m.waistCm != null) parts.add('Waist: ${m.waistCm}cm');
        if (m.hipsCm != null) parts.add('Hips: ${m.hipsCm}cm');
        if (m.bicepCm != null) parts.add('Bicep: ${m.bicepCm}cm');
        if (m.thighCm != null) parts.add('Thigh: ${m.thighCm}cm');
        if (m.neckCm != null) parts.add('Neck: ${m.neckCm}cm');
        if (m.shouldersCm != null) parts.add('Shoulders: ${m.shouldersCm}cm');
        if (m.calfCm != null) parts.add('Calf: ${m.calfCm}cm');
        if (parts.isNotEmpty) {
          bodyMeasurementsStr = '${parts.join(', ')} (measured ${m.measuredAt.toIso8601String().substring(0, 10)})';
        }
      }
    } catch (_) {}

    // ── Weight history (last 30 entries) ─────────────────────────────────
    String weightHistoryStr = '';
    try {
      final weights = await db.getWeightHistory(limit: 30);
      if (weights.isNotEmpty) {
        final wLines = weights.take(10).map((w) =>
          '${w.loggedAt.toIso8601String().substring(0, 10)}: ${w.weightKg.toStringAsFixed(1)} kg${w.note.isNotEmpty ? ' (${w.note})' : ''}').toList();
        weightHistoryStr = wLines.join('\n');
        if (weights.length > 1) {
          final diff = weights.first.weightKg - weights.last.weightKg;
          weightHistoryStr += '\nTrend: ${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)} kg over ${weights.length} entries';
        }
      }
    } catch (_) {}

    // ── Water intake today ───────────────────────────────────────────────
    int waterMl = 0;
    try {
      waterMl = await db.getTodaysWater();
    } catch (_) {}

    // ── All-time stats ───────────────────────────────────────────────────
    int totalMeals = 0;
    int totalWorkouts = 0;
    try {
      totalMeals = await db.getMealCountAll();
      totalWorkouts = await db.getWorkoutCountAll();
    } catch (_) {}

    // ── Active workout plan ──────────────────────────────────────────────
    String activeWorkoutPlanStr = '';
    try {
      final plan = await db.getActiveWorkoutPlan();
      if (plan != null) {
        activeWorkoutPlanStr = '${plan.name} (${plan.weeks} weeks)';
      }
    } catch (_) {}

    // ── Active meal plan ─────────────────────────────────────────────────
    String activeMealPlanStr = '';
    try {
      final plan = await db.getActiveMealPlan();
      if (plan != null) {
        activeMealPlanStr = '${plan.days}-day plan (created ${plan.createdAt.toIso8601String().substring(0, 10)})';
      }
    } catch (_) {}

    // ── Recent daily summaries (7 days) ──────────────────────────────────
    String weeklySummaryStr = '';
    try {
      final summaries = await db.getRecentSummaries(days: 7);
      if (summaries.isNotEmpty) {
        final sLines = summaries.map((s) =>
          '${s.date.toIso8601String().substring(0, 10)}: ${s.totalCalories.round()} kcal, P:${s.totalProteinG.round()}g, ${s.workoutsCompleted} workouts, water:${s.waterMl}ml${s.streakDay ? ' ✓streak' : ''}').toList();
        weeklySummaryStr = sLines.join('\n');
      }
    } catch (_) {}

    // ── Badges ───────────────────────────────────────────────────────────
    String badgesStr = '';
    if (gamification.unlockedBadges.isNotEmpty) {
      badgesStr = gamification.unlockedBadges.join(', ');
    }

    // ── Sleep schedule ───────────────────────────────────────────────────
    String sleepStr = '';
    if (profile['bedtimeHour'] != null && profile['wakeHour'] != null) {
      final bedH = profile['bedtimeHour'] as int;
      final bedM = profile['bedtimeMin'] as int? ?? 0;
      final wakeH = profile['wakeHour'] as int;
      final wakeM = profile['wakeMin'] as int? ?? 0;
      sleepStr = 'Bedtime: ${bedH.toString().padLeft(2, '0')}:${bedM.toString().padLeft(2, '0')} → Wake: ${wakeH.toString().padLeft(2, '0')}:${wakeM.toString().padLeft(2, '0')}';
      // Calculate sleep hours
      int sleepMins = ((wakeH * 60 + wakeM) - (bedH * 60 + bedM));
      if (sleepMins < 0) sleepMins += 24 * 60;
      sleepStr += ' (~${(sleepMins / 60).toStringAsFixed(1)} hours)';
    }

    return {
      // Full profile
      'goal': profile['primaryGoal'] ?? 'general_fitness',
      'gender': profile['gender'],
      'age': profile['age'],
      'height_cm': profile['heightCm'],
      'weight_kg': profile['weightKg'],
      'body_fat_pct': profile['bodyFatPct'],
      'target_weight_kg': profile['targetWeightKg'],
      'weight_change_pace': profile['weightChangePace'],
      'activity_level': profile['activityLevel'],
      'target_body_type': profile['targetBodyType'],
      'workout_days_per_week': profile['workoutDaysPerWeek'],
      'country': profile['country'],
      'city': profile['city'],
      'dietary_restrictions': profile['dietaryRestrictions'],
      'cuisine_preferences': profile['cuisinePreferences'],
      'disliked_ingredients': profile['dislikedIngredients'],
      'monthly_budget_usd': profile['monthlyBudgetUsd'],
      'sleep_schedule': sleepStr,

      // Nutrition targets & progress
      'target_calories': nutrition.targetCalories.round(),
      'target_protein_g': nutrition.targetProtein.round(),
      'target_carbs_g': nutrition.targetCarbs.round(),
      'target_fat_g': nutrition.targetFat.round(),
      'consumed_calories_today': nutrition.consumedCalories.round(),
      'consumed_protein_today': nutrition.consumedProtein.round(),
      'consumed_carbs_today': nutrition.consumedCarbs.round(),
      'consumed_fat_today': nutrition.consumedFat.round(),
      'water_ml_today': waterMl,

      // Gamification
      'current_streak': gamification.currentStreak,
      'longest_streak': gamification.longestStreak,
      'level': gamification.currentLevel,
      'level_name': gamification.levelName,
      'total_xp': gamification.totalXp,
      'xp_to_next_level': gamification.xpToNextLevel,
      'streak_freezes_available': gamification.streakFreezesAvailable,
      if (badgesStr.isNotEmpty) 'unlocked_badges': badgesStr,

      // All-time stats
      'total_meals_logged': totalMeals,
      'total_workouts_logged': totalWorkouts,

      // Data sections
      if (todaysMealsStr.isNotEmpty) 'todays_meals': todaysMealsStr,
      if (recentWorkoutsStr.isNotEmpty) 'recent_workouts': recentWorkoutsStr,
      if (prsStr.isNotEmpty) 'personal_records': prsStr,
      if (bodyMeasurementsStr.isNotEmpty) 'body_measurements': bodyMeasurementsStr,
      if (weightHistoryStr.isNotEmpty) 'weight_history': weightHistoryStr,
      if (weeklySummaryStr.isNotEmpty) 'weekly_summary': weeklySummaryStr,
      if (activeWorkoutPlanStr.isNotEmpty) 'active_workout_plan': activeWorkoutPlanStr,
      if (activeMealPlanStr.isNotEmpty) 'active_meal_plan': activeMealPlanStr,
    };
  }

  Future<void> _sendMessage(String text, {Uint8List? imageBytes}) async {
    if (text.trim().isEmpty && imageBytes == null) return;

    final userText = text.trim().isNotEmpty ? text.trim() : 'Analyze this image';
    setState(() {
      _messages.add(_Message(text: userText, isAi: false, imageBytes: imageBytes));
      _isTyping = true;
      _messageCtrl.clear();
    });
    _scrollToBottom();
    _saveChat();

    try {
      final gemini = ref.read(geminiClientProvider);
      final userContext = await _buildUserContext();

      final result = await gemini.chat(
        message: userText,
        userContext: userContext,
        history: _history,
        imageBytes: imageBytes,
      );

      final response = result['response'] as String? ??
          'I couldn\'t generate a response. Please try again.';

      _history.add({'role': 'user', 'content': userText});
      _history.add({'role': 'model', 'content': response});

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_Message(
            text: response,
            isAi: true,
          ));
        });
        _scrollToBottom();
        _saveChat();
      }
    } on GeminiException catch (_) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_Message(
            text: 'Hmm, I\'m having a moment 😅 Tap retry to try again.',
            isAi: true,
            isError: true,
            failedUserText: userText,
          ));
        });
        _scrollToBottom();
        _saveChat();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_Message(
            text: 'Oops, ran into a small hiccup! Tap retry to try again 💪',
            isAi: true,
            isError: true,
            failedUserText: userText,
          ));
        });
        _scrollToBottom();
        _saveChat();
      }
    }
  }

  Future<void> _pickAndSendImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      await _sendMessage(_messageCtrl.text, imageBytes: bytes);
    } catch (e) {
      debugPrint('Image picker error: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.limeGlow,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lime.withValues(alpha: 0.3)),
              ),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('AI Coach',
                    style: AppTypography.bodyMedium
                        .copyWith(fontWeight: FontWeight.w700)),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Online · Context-aware',
                      style: AppTypography.overline.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (_messages.length > 1)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              color: AppColors.textTertiary,
              tooltip: 'Clear chat',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear chat?'),
                    content: const Text('This will delete all chat messages.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _clearChat();
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (_isTyping && i == _messages.length) {
                  return _TypingIndicator().animate().fadeIn(duration: 200.ms);
                }
                final msg = _messages[i];
                return _ChatBubble(
                  message: msg,
                  onSuggestionTap: _sendMessage,
                  onRetry: msg.isError && msg.failedUserText != null
                      ? () {
                          // Remove the error bubble and re-send
                          setState(() => _messages.removeAt(i));
                          _sendMessage(msg.failedUserText!);
                        }
                      : null,
                )
                    .animate(delay: 50.ms)
                    .slideY(begin: 0.1, duration: 300.ms, curve: Curves.easeOut)
                    .fadeIn(duration: 300.ms);
              },
            ),
          ),

          // Suggestions (shown when only the welcome message exists)
          if (_messages.length == 1) ...[
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadding),
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _sendMessage(
                      _suggestions[i].replaceFirst(RegExp(r'^[^\s]+\s+'), '')),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.surfaceCardBorder),
                    ),
                    child: Text(
                      _suggestions[i],
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Input bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              border:
                  Border(top: BorderSide(color: AppColors.surfaceCardBorder)),
            ),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              AppSpacing.sm,
              AppSpacing.pagePadding,
              MediaQuery.of(context).padding.bottom + AppSpacing.sm,
            ),
            child: Row(
              children: [
                // Image picker button
                GestureDetector(
                  onTap: _isTyping ? null : _pickAndSendImage,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.surfaceCardBorder),
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      color: _isTyping
                          ? AppColors.textTertiary
                          : AppColors.lime,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _messageCtrl,
                    style: AppTypography.body,
                    maxLines: 3,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Ask your AI coach anything...',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: _isTyping
                      ? null
                      : () => _sendMessage(_messageCtrl.text),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isTyping
                          ? AppColors.surfaceCard
                          : AppColors.lime,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      color: _isTyping
                          ? AppColors.textTertiary
                          : AppColors.textInverse,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isAi;
  final List<String> suggestions;
  final Uint8List? imageBytes;
  final bool isError;
  final String? failedUserText;
  const _Message({
    required this.text,
    required this.isAi,
    this.suggestions = const [],
    this.imageBytes,
    this.isError = false,
    this.failedUserText,
  });
}

class _ChatBubble extends StatelessWidget {
  final _Message message;
  final void Function(String) onSuggestionTap;
  final VoidCallback? onRetry;
  const _ChatBubble({required this.message, required this.onSuggestionTap, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment:
            message.isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: message.isAi
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.isAi) ...[
                Container(
                  width: 32,
                  height: 32,
                  margin:
                      const EdgeInsets.only(right: AppSpacing.sm, top: 2),
                  decoration: BoxDecoration(
                    color: AppColors.limeGlow,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.lime.withValues(alpha: 0.3)),
                  ),
                  child: const Center(
                      child: Text('🤖', style: TextStyle(fontSize: 14))),
                ),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: message.isAi
                        ? AppColors.surfaceCard
                        : AppColors.lime,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppRadius.lg),
                      topRight: const Radius.circular(AppRadius.lg),
                      bottomLeft: Radius.circular(
                          message.isAi ? 4 : AppRadius.lg),
                      bottomRight: Radius.circular(
                          message.isAi ? AppRadius.lg : 4),
                    ),
                    border: message.isAi
                        ? Border.all(color: AppColors.surfaceCardBorder)
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.imageBytes != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Image.memory(
                            message.imageBytes!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      if (message.isAi)
                        _RichText(text: message.text)
                      else
                        Text(
                          message.text,
                          style: AppTypography.body.copyWith(
                            color: AppColors.textInverse,
                            height: 1.6,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Retry button for error messages
          if (message.isError && onRetry != null) ...[            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh_rounded, color: AppColors.error, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Retry',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          // Follow-up suggestion chips
          if (message.isAi && message.suggestions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: message.suggestions
                    .map((s) => GestureDetector(
                          onTap: () => onSuggestionTap(s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.limeGlow,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                              border: Border.all(
                                  color:
                                      AppColors.lime.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              s,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.lime,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RichText extends StatelessWidget {
  final String text;
  const _RichText({required this.text});

  // Parses **bold** inline within a line, applying baseStyle to normal text
  // and lime+bold to bold runs.
  Widget _parseInline(String raw, TextStyle baseStyle) {
    final boldRegex = RegExp(r'\*\*(.+?)\*\*');
    final spans = <InlineSpan>[];
    int lastEnd = 0;
    for (final m in boldRegex.allMatches(raw)) {
      if (m.start > lastEnd) {
        spans.add(TextSpan(text: raw.substring(lastEnd, m.start), style: baseStyle));
      }
      spans.add(TextSpan(
        text: m.group(1),
        style: baseStyle.copyWith(
          color: AppColors.lime,
          fontWeight: FontWeight.w700,
        ),
      ));
      lastEnd = m.end;
    }
    if (lastEnd < raw.length) {
      spans.add(TextSpan(text: raw.substring(lastEnd), style: baseStyle));
    }
    if (spans.length == 1 && spans.first is TextSpan) {
      final ts = spans.first as TextSpan;
      if (ts.children == null) return Text(ts.text ?? '', style: baseStyle);
    }
    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      // ── Empty line → small vertical gap ────────────────────────────
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      // ── ### Heading 3 ───────────────────────────────────────────────
      if (line.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 3),
          child: _parseInline(
            line.substring(4),
            AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
              height: 1.5,
            ),
          ),
        ));
        continue;
      }

      // ── ## Heading 2 ────────────────────────────────────────────────
      if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: _parseInline(
            line.substring(3),
            AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15.5,
              height: 1.5,
            ),
          ),
        ));
        continue;
      }

      // ── # Heading 1 ─────────────────────────────────────────────────
      if (line.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: _parseInline(
            line.substring(2),
            AppTypography.h3.copyWith(height: 1.4),
          ),
        ));
        continue;
      }

      // ── Bullet: * text  /  - text  /  • text ───────────────────────
      final isBullet = line.startsWith('* ') ||
          line.startsWith('- ') ||
          line.startsWith('• ');
      if (isBullet) {
        final content = line.substring(2);
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '•  ',
                style: AppTypography.body.copyWith(
                  color: AppColors.lime,
                  height: 1.6,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: _parseInline(
                  content,
                  AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ));
        continue;
      }

      // ── Regular paragraph line ──────────────────────────────────────
      widgets.add(_parseInline(
        line,
        AppTypography.body.copyWith(
          color: AppColors.textPrimary,
          height: 1.6,
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: AppSpacing.sm, top: 2),
            decoration: BoxDecoration(
              color: AppColors.limeGlow,
              shape: BoxShape.circle,
            ),
            child:
                const Center(child: Text('🤖', style: TextStyle(fontSize: 14))),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
                bottomRight: Radius.circular(AppRadius.lg),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.surfaceCardBorder),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final offset =
                        (_controller.value - i * 0.2).clamp(0.0, 1.0);
                    final y = -4 *
                        (offset < 0.5
                            ? offset * 2
                            : (1 - offset) * 2);
                    return Transform.translate(
                      offset: Offset(0, y),
                      child: Container(
                        width: 8,
                        height: 8,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: AppColors.textTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
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
