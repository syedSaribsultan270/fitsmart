import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../features/dashboard/providers/dashboard_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/snackbar_service.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final String? workoutId;
  const ActiveWorkoutScreen({super.key, this.workoutId});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  final _stopwatch = Stopwatch();
  late Timer _timer;
  int _currentExercise = 0;
  bool _isResting = false;
  int _restSecondsLeft = 0;
  Timer? _restTimer;
  bool _isSaving = false;

  late final List<_Exercise> _exercises;
  late final String _workoutName;

  @override
  void initState() {
    super.initState();

    // Parse workout data passed via route extra, fall back to defaults
    if (widget.workoutId != null) {
      try {
        final data = jsonDecode(widget.workoutId!) as Map<String, dynamic>;
        _workoutName = data['focus'] as String? ?? 'Workout';
        final exercises = data['exercises'] as List? ?? [];
        _exercises = exercises.map((e) {
          final sets = e['sets'] as int? ?? 3;
          return _Exercise(
            e['name'] as String? ?? 'Exercise',
            sets,
            List.generate(sets, (_) => _Set(0, 0)),
            e['rest_sec'] as int? ?? 60,
          );
        }).toList();
      } catch (_) {
        _workoutName = 'Quick Workout';
        _exercises = _defaultExercises();
      }
    } else {
      _workoutName = 'Quick Workout';
      _exercises = _defaultExercises();
    }

    _stopwatch.start();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  static List<_Exercise> _defaultExercises() => [
        _Exercise('Bench Press', 4,
            [_Set(0, 0), _Set(0, 0), _Set(0, 0), _Set(0, 0)], 90),
        _Exercise('Overhead Press', 3,
            [_Set(0, 0), _Set(0, 0), _Set(0, 0)], 90),
        _Exercise('Incline DB Press', 3,
            [_Set(0, 0), _Set(0, 0), _Set(0, 0)], 60),
        _Exercise('Lateral Raises', 4,
            [_Set(0, 0), _Set(0, 0), _Set(0, 0), _Set(0, 0)], 60),
        _Exercise('Tricep Dips', 3,
            [_Set(0, 0), _Set(0, 0), _Set(0, 0)], 60),
      ];

  @override
  void dispose() {
    _stopwatch.stop();
    _timer.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  String get _elapsedTime {
    final e = _stopwatch.elapsed;
    final m = e.inMinutes.toString().padLeft(2, '0');
    final s = (e.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startRestTimer(int seconds) {
    setState(() {
      _isResting = true;
      _restSecondsLeft = seconds;
    });
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_restSecondsLeft <= 1) {
        t.cancel();
        HapticFeedback.heavyImpact();
        setState(() => _isResting = false);
      } else {
        setState(() => _restSecondsLeft--);
      }
    });
  }

  void _logSet(int exerciseIdx, int setIdx, double weight, int reps) {
    setState(() {
      _exercises[exerciseIdx].sets[setIdx] =
          _Set(weight, reps, isLogged: true);
    });
    HapticFeedback.mediumImpact();
    _startRestTimer(_exercises[exerciseIdx].restSeconds);
  }

  int get _totalLoggedSets {
    int count = 0;
    for (final ex in _exercises) {
      for (final s in ex.sets) {
        if (s.isLogged) count++;
      }
    }
    return count;
  }

  int get _totalLoggedReps {
    int count = 0;
    for (final ex in _exercises) {
      for (final s in ex.sets) {
        if (s.isLogged) count += s.reps;
      }
    }
    return count;
  }

  double get _estimatedCalories {
    // Rough estimate: 0.4 kcal per rep * weight factor
    double cal = 0;
    for (final ex in _exercises) {
      for (final s in ex.sets) {
        if (s.isLogged) {
          cal += s.reps * (0.15 + (s.weight * 0.005));
        }
      }
    }
    // Add ~3 kcal/min for base metabolic during workout
    cal += _stopwatch.elapsed.inMinutes * 3;
    return cal;
  }

  Future<void> _saveWorkout() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final db = ref.read(databaseProvider);
      final duration = _stopwatch.elapsed.inSeconds;
      final totalSets = _totalLoggedSets;
      final totalReps = _totalLoggedReps;
      final estCal = _estimatedCalories;
      final now = DateTime.now();

      // Build exercises JSON
      final exercisesJson = _exercises.map((ex) {
        return {
          'name': ex.name,
          'sets': ex.sets
              .where((s) => s.isLogged)
              .map((s) => {'weight': s.weight, 'reps': s.reps})
              .toList(),
        };
      }).toList();

      // Insert workout log
      final workoutId = await db.insertWorkout(WorkoutLogsCompanion(
        name: Value(_workoutName),
        durationSeconds: Value(duration),
        totalSets: Value(totalSets),
        totalReps: Value(totalReps),
        estimatedCalories: Value(estCal),
        exercisesJson: Value(jsonEncode(exercisesJson)),
        completedAt: Value(now),
      ));

      // Insert individual sets
      final setCompanions = <WorkoutSetsCompanion>[];
      for (final ex in _exercises) {
        int setNum = 0;
        for (final s in ex.sets) {
          if (s.isLogged) {
            setNum++;
            setCompanions.add(WorkoutSetsCompanion(
              workoutLogId: Value(workoutId),
              exerciseName: Value(ex.name),
              muscleGroup: const Value(''),
              setNumber: Value(setNum),
              weightKg: Value(s.weight),
              reps: Value(s.reps),
              completedAt: Value(now),
            ));
          }
        }
      }
      if (setCompanions.isNotEmpty) {
        await db.insertWorkoutSets(setCompanions);
      }

      // Sync to Firestore
      final uid = AuthService.uid;
      if (uid != null) {
        FirestoreService.addWorkoutLog(uid, {
          'name': _workoutName,
          'durationSeconds': duration,
          'totalSets': totalSets,
          'totalReps': totalReps,
          'estimatedCalories': estCal,
          'completedAt': now.toIso8601String(),
        }).catchError((_) => '');
      }

      // Award XP
      await ref.read(gamificationProvider.notifier).awardXp(
            25,
            checkStreak: true,
          );

      ref.invalidate(personalRecordsProvider);
      ref.invalidate(allTimeStatsProvider);

      if (mounted) {
        SnackbarService.success(
            'Workout saved! +25 XP ⚡ · $totalSets sets · ${estCal.toStringAsFixed(0)} kcal');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        SnackbarService.error('Failed to save workout: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _exercises[_currentExercise];
    final progress = (_currentExercise) / _exercises.length;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _showFinishDialog(context),
        ),
        title: Row(
          children: [
            Text(
              _elapsedTime,
              style: AppTypography.mono.copyWith(
                color: AppColors.lime,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text('⏱️', style: TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _showFinishDialog(context),
            child: Text(
              'Finish',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.lime,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceCardBorder,
            valueColor: const AlwaysStoppedAnimation(AppColors.lime),
            minHeight: 3,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rest timer overlay
                  if (_isResting) ...[
                    _RestTimerBanner(
                      secondsLeft: _restSecondsLeft,
                      onSkip: () {
                        _restTimer?.cancel();
                        setState(() => _isResting = false);
                      },
                    ).animate().slideY(begin: -0.2, duration: 300.ms).fadeIn(),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Exercise name + navigation
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Exercise ${_currentExercise + 1} of ${_exercises.length}',
                              style: AppTypography.overline
                                  .copyWith(color: AppColors.textTertiary),
                            ),
                            Text(
                              exercise.name,
                              style: AppTypography.h2
                                  .copyWith(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              '${exercise.targetSets} sets · ${exercise.restSeconds}s rest',
                              style: AppTypography.body
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          if (_currentExercise > 0)
                            IconButton(
                              onPressed: () =>
                                  setState(() => _currentExercise--),
                              icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 18),
                              color: AppColors.textTertiary,
                            ),
                          if (_currentExercise < _exercises.length - 1)
                            IconButton(
                              onPressed: () =>
                                  setState(() => _currentExercise++),
                              icon: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 18),
                              color: AppColors.textTertiary,
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // Sets header
                  Text(
                    'SETS',
                    style: AppTypography.overline
                        .copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        const SizedBox(width: 36),
                        Expanded(
                          child: Text('WEIGHT (kg)',
                              style: AppTypography.overline,
                              textAlign: TextAlign.center),
                        ),
                        Expanded(
                          child: Text('REPS',
                              style: AppTypography.overline,
                              textAlign: TextAlign.center),
                        ),
                        const SizedBox(width: 64),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...exercise.sets.asMap().entries.map((e) => _SetRow(
                        setNumber: e.key + 1,
                        set: e.value,
                        onLog: (w, r) =>
                            _logSet(_currentExercise, e.key, w, r),
                      ).animate(delay: (e.key * 40).ms).fadeIn(duration: 200.ms)),

                  const SizedBox(height: AppSpacing.sectionGap),

                  // Workout plan overview
                  AppCard(
                    backgroundColor: AppColors.bgSecondary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WORKOUT PLAN',
                          style: AppTypography.overline
                              .copyWith(color: AppColors.textTertiary),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ..._exercises.asMap().entries.map((e) {
                          final isDone = e.key < _currentExercise;
                          final isCurrent = e.key == _currentExercise;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _currentExercise = e.key),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isDone
                                          ? AppColors.success
                                          : isCurrent
                                              ? AppColors.lime
                                              : AppColors.surfaceCardBorder,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: isDone
                                          ? const Icon(Icons.check_rounded,
                                              size: 14,
                                              color: AppColors.textInverse)
                                          : Text(
                                              '${e.key + 1}',
                                              style: AppTypography.overline
                                                  .copyWith(
                                                color: isCurrent
                                                    ? AppColors.textInverse
                                                    : AppColors.textTertiary,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    e.value.name,
                                    style: AppTypography.body.copyWith(
                                      color: isCurrent
                                          ? AppColors.textPrimary
                                          : isDone
                                              ? AppColors.textTertiary
                                              : AppColors.textSecondary,
                                      fontWeight: isCurrent
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      decoration: isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFinishDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Finish Workout?'),
        content: Text(
          'Time: $_elapsedTime · $_totalLoggedSets sets logged\n'
          'Est. ${_estimatedCalories.toStringAsFixed(0)} kcal burned',
          style:
              AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Going'),
          ),
          ElevatedButton(
            onPressed: _isSaving
                ? null
                : () {
                    Navigator.pop(context);
                    _saveWorkout();
                  },
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save +25 XP ⚡'),
          ),
        ],
      ),
    );
  }
}

class _RestTimerBanner extends StatelessWidget {
  final int secondsLeft;
  final VoidCallback onSkip;

  const _RestTimerBanner({required this.secondsLeft, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.cyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Text('⏸️', style: TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REST TIME',
                  style: AppTypography.overline
                      .copyWith(color: AppColors.cyan),
                ),
                Text(
                  '${secondsLeft}s remaining',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onSkip,
            child: Text(
              'Skip',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetRow extends StatefulWidget {
  final int setNumber;
  final _Set set;
  final void Function(double weight, int reps) onLog;

  const _SetRow({
    required this.setNumber,
    required this.set,
    required this.onLog,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController _weightCtrl;
  late TextEditingController _repsCtrl;

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(
      text: widget.set.weight > 0 ? widget.set.weight.toString() : '',
    );
    _repsCtrl = TextEditingController(
      text: widget.set.reps > 0 ? widget.set.reps.toString() : '',
    );
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: widget.set.isLogged
              ? AppColors.success.withValues(alpha: 0.08)
              : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: widget.set.isLogged
                ? AppColors.success.withValues(alpha: 0.3)
                : AppColors.surfaceCardBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: widget.set.isLogged
                    ? AppColors.success
                    : AppColors.bgTertiary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: widget.set.isLogged
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: AppColors.textInverse)
                    : Text(
                        '${widget.setNumber}',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTertiary,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextField(
                controller: _weightCtrl,
                style: AppTypography.bodyMedium
                    .copyWith(fontWeight: FontWeight.w700),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '0',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: _repsCtrl,
                style: AppTypography.bodyMedium
                    .copyWith(fontWeight: FontWeight.w700),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '0',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: () {
                final w = double.tryParse(_weightCtrl.text) ?? 0;
                final r = int.tryParse(_repsCtrl.text) ?? 0;
                widget.onLog(w, r);
              },
              child: Container(
                width: 56,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.set.isLogged
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.lime,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: widget.set.isLogged
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.success, size: 18)
                      : Text(
                          'LOG',
                          style: AppTypography.overline.copyWith(
                            color: AppColors.textInverse,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Exercise {
  final String name;
  final int targetSets;
  final List<_Set> sets;
  final int restSeconds;

  _Exercise(this.name, this.targetSets, this.sets, this.restSeconds);
}

class _Set {
  double weight;
  int reps;
  bool isLogged;

  _Set(this.weight, this.reps, {this.isLogged = false});
}
