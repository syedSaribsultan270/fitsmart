import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/liquid_glass.dart';
import '../../../services/ai_orchestrator_service.dart'
    show ExecutedToolCall, SuggestedMealCard;
import '../../../services/ai_tools/ai_tool.dart';

/// Bottom-sheet shown before a write tool fires. User must explicitly
/// approve each action. Returns `true` on Confirm, `false` on Cancel
/// (including swipe-to-dismiss).
Future<bool> showToolConfirmation(
  BuildContext context, {
  required PendingToolCall pending,
}) async {
  HapticFeedback.selectionClick();
  final approved = await showLiquidGlassSheet<bool>(
    context,
    useSafeArea: true,
    accentRim: true,
    padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
    builder: (ctx) => _ToolConfirmationBody(pending: pending),
  );
  return approved == true;
}

class _ToolConfirmationBody extends StatelessWidget {
  final PendingToolCall pending;
  const _ToolConfirmationBody({required this.pending});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grab handle
        Center(
          child: Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: c.textTertiary.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: c.limeGlow,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(_iconForTool(pending.tool.name),
                  color: c.lime, size: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              pending.tool.confirmTitle,
              style: AppTypography.h3.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'The AI wants to do this for you. Confirm to save it to your log.',
          style: AppTypography.body.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Summary card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: c.surfaceCard,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: c.surfaceCardBorder),
          ),
          child: Text(
            pending.tool.summarize(pending.args),
            style: AppTypography.bodyMedium.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.textSecondary,
                    side: BorderSide(color: c.surfaceCardBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.lime,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _iconForTool(String name) {
    switch (name) {
      case 'log_meal':          return Icons.restaurant_rounded;
      case 'log_weight':        return Icons.monitor_weight_outlined;
      case 'log_water':         return Icons.water_drop_outlined;
      case 'log_quick_workout': return Icons.fitness_center_rounded;
      default:                  return Icons.bolt_rounded;
    }
  }
}

/// Inline receipt card rendered below the AI's bubble when a write tool
/// was executed. Shows the summary + a 5-second undo window.
///
/// [onUndo] is called when the user taps Undo — the caller is responsible
/// for actually deleting the logged entity (we don't know the domain here).
class ToolReceiptCard extends StatefulWidget {
  final ExecutedToolCall receipt;
  final Future<void> Function(ExecutedToolCall) onUndo;

  const ToolReceiptCard({
    super.key,
    required this.receipt,
    required this.onUndo,
  });

  @override
  State<ToolReceiptCard> createState() => _ToolReceiptCardState();
}

class _ToolReceiptCardState extends State<ToolReceiptCard> {
  static const _undoWindow = Duration(seconds: 5);
  bool _undone = false;
  bool _running = false;

  Future<void> _handleUndo() async {
    if (_running || _undone) return;
    setState(() => _running = true);
    try {
      await widget.onUndo(widget.receipt);
      if (mounted) setState(() => _undone = true);
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tool = widget.receipt.tool;
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _undone
            ? c.surfaceCard
            : c.lime.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: _undone
              ? c.surfaceCardBorder
              : c.lime.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _undone
                ? Icons.undo_rounded
                : Icons.check_circle_rounded,
            color: _undone ? c.textTertiary : c.lime,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _undone ? 'Undone' : tool.confirmTitle,
                  style: AppTypography.overline.copyWith(
                    color: _undone ? c.textTertiary : c.lime,
                    fontSize: 9,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tool.summarize(widget.receipt.args),
                  style: AppTypography.bodyMedium.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                    decoration:
                        _undone ? TextDecoration.lineThrough : null,
                    decorationColor: c.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (!_undone)
            _UndoButton(
              running: _running,
              window: _undoWindow,
              onPressed: _handleUndo,
            ),
        ],
      ),
    );
  }
}

/// Tappable opt-in card the AI proposes via `suggest_meal_card`. Shows the
/// dish + macros and a "Log this meal" button that fires the normal
/// confirmation sheet → log path. User is always in control — no log ever
/// happens without them tapping first.
class MealSuggestionCard extends StatefulWidget {
  final SuggestedMealCard card;
  final Future<void> Function(SuggestedMealCard card) onLog;
  const MealSuggestionCard({
    super.key,
    required this.card,
    required this.onLog,
  });

  @override
  State<MealSuggestionCard> createState() => _MealSuggestionCardState();
}

class _MealSuggestionCardState extends State<MealSuggestionCard> {
  bool _logged = false;
  bool _running = false;

  Future<void> _tapLog() async {
    if (_running || _logged) return;
    setState(() => _running = true);
    try {
      await widget.onLog(widget.card);
      if (mounted) setState(() => _logged = true);
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final card = widget.card;
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: c.lime.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: c.limeGlow,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.restaurant_rounded,
                    color: c.lime, size: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      card.name,
                      style: AppTypography.bodyMedium.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${card.calories.round()} kcal · '
                      '${card.proteinG.round()}p / '
                      '${card.carbsG.round()}c / '
                      '${card.fatG.round()}f'
                      ' · ${card.mealType}',
                      style: AppTypography.caption.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: _logged
                ? OutlinedButton.icon(
                    onPressed: null,
                    icon: Icon(Icons.check_rounded, size: 16, color: c.lime),
                    label: Text(
                      'Logged',
                      style: TextStyle(
                        color: c.lime, fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: c.lime.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _running ? null : _tapLog,
                    icon: _running
                        ? const SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black,
                            ),
                          )
                        : const Icon(Icons.add_rounded, size: 16),
                    label: const Text(
                      'Log this meal',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.lime,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Undo button with a built-in countdown — disables itself after the
/// undo window elapses so you can't undo something you've forgotten about.
class _UndoButton extends StatefulWidget {
  final Duration window;
  final VoidCallback onPressed;
  final bool running;

  const _UndoButton({
    required this.window,
    required this.onPressed,
    required this.running,
  });

  @override
  State<_UndoButton> createState() => _UndoButtonState();
}

class _UndoButtonState extends State<_UndoButton> {
  late final DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return StreamBuilder<int>(
      stream: Stream.periodic(
        const Duration(milliseconds: 250),
        (i) => i,
      ),
      builder: (ctx, snap) {
        final elapsed = DateTime.now().difference(_startedAt);
        final expired = elapsed >= widget.window;
        return AnimatedOpacity(
          duration: motionGate(context, AppMotion.fast),
          opacity: expired ? 0.35 : 1.0,
          child: TextButton(
            onPressed:
                (expired || widget.running) ? null : widget.onPressed,
            style: TextButton.styleFrom(
              foregroundColor: c.error,
              minimumSize: const Size(50, 32),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
              ),
            ),
            child: widget.running
                ? SizedBox(
                    width: 14, height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: c.error,
                    ),
                  )
                : const Text(
                    'Undo',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        );
      },
    );
  }
}
