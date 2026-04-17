import 'ai_tool.dart';

/// Render a tappable meal card in the chat. User taps the card to open the
/// normal log-confirmation sheet — then the usual [LogMealTool] runs.
///
/// Designed to replace `log_meal` for INFO / RECOMMENDATION / SUGGESTION
/// contexts (e.g. "what's in chicken biryani?", "recommend a breakfast").
/// The user never sees a confirm sheet without first tapping a card.
///
/// From the model's perspective this is a *read* tool — it does not mutate
/// state. The orchestrator auto-executes it and pulls the args out as a
/// [SuggestedMealCard] the UI renders under the assistant bubble.
class SuggestMealCardTool extends AiTool {
  @override
  String get name => 'suggest_meal_card';

  @override
  bool get isWrite => false;

  @override
  String get confirmTitle => 'Suggest meal';

  @override
  String get description =>
      'Show the user a tappable meal card with macros so they can log this '
      'meal with one tap if they want. '
      'CALL THIS — NOT `log_meal` — whenever you mention a specific dish in '
      'response to an INFORMATION question, a RECOMMENDATION, a SUGGESTION, '
      'or a "what\'s in X" question. '
      'Examples where you MUST use this instead of log_meal: '
      '"what are the constituents of X?", "what\'s a good breakfast?", '
      '"recommend something with 400 kcal", "how many calories in X?". '
      'Only call log_meal when the user EXPLICITLY states they just ate '
      'something (e.g. "I had X", "just ate Y", "log Z for lunch").';

  @override
  Map<String, dynamic> get parameterSchema => {
        'type': 'object',
        'properties': {
          'name': {'type': 'string', 'description': 'Dish name.'},
          'meal_type': {
            'type': 'string',
            'enum': ['Breakfast', 'Lunch', 'Dinner', 'Snack',
              'Pre-Workout', 'Post-Workout'],
            'description':
                'Suggested meal slot. Infer from time of day if unclear.',
          },
          'calories':  {'type': 'number'},
          'protein_g': {'type': 'number'},
          'carbs_g':   {'type': 'number'},
          'fat_g':     {'type': 'number'},
          'fiber_g':   {'type': 'number'},
        },
        'required': ['name', 'meal_type', 'calories', 'protein_g', 'carbs_g', 'fat_g'],
      };

  @override
  String summarize(Map<String, dynamic> args) {
    final name = args['name'] ?? 'Meal';
    final cal = (args['calories'] as num?)?.round() ?? 0;
    return '$name · $cal kcal';
  }

  @override
  Future<AiToolResult> execute(ToolRef read, Map<String, dynamic> args) async {
    // Nothing to do — this tool just shuttles a payload back to the UI.
    // The orchestrator picks these up via args and renders a card.
    return AiToolResult.ok({
      'card_ready': true,
      'name': args['name'],
    });
  }
}
