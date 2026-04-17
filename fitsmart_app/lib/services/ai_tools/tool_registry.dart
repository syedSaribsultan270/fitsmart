import 'ai_tool.dart';
import 'log_meal_tool.dart';
import 'log_quick_workout_tool.dart';
import 'log_water_tool.dart';
import 'log_weight_tool.dart';
import 'read_tools.dart';
import 'suggest_meal_card_tool.dart';

/// Singleton registry of every AI tool the app exposes. The orchestrator
/// pulls tool schemas from here to send to the model, and dispatches
/// executions by name.
///
/// Deliberately NOT exposed: any delete-* tools. Destructive operations
/// stay in the UI's swipe-to-delete path — prevents prompt injection from
/// nuking user data.
class ToolRegistry {
  ToolRegistry._();
  static final ToolRegistry instance = ToolRegistry._();

  final List<AiTool> _tools = [
    LogMealTool(),
    LogWeightTool(),
    LogWaterTool(),
    LogQuickWorkoutTool(),
    SuggestMealCardTool(),
    GetTodaysTotalsTool(),
    GetTodaysMealsTool(),
    GetRecentWeightTrendTool(),
  ];

  List<AiTool> get all => List.unmodifiable(_tools);

  List<AiTool> get writeTools => _tools.where((t) => t.isWrite).toList();
  List<AiTool> get readTools => _tools.where((t) => !t.isWrite).toList();

  AiTool? byName(String name) {
    try {
      return _tools.firstWhere((t) => t.name == name);
    } catch (_) {
      return null;
    }
  }

  /// OpenAI-style tools array for Groq.
  List<Map<String, dynamic>> toOpenAiTools() {
    return _tools.map((t) => {
      'type': 'function',
      'function': {
        'name': t.name,
        'description': t.description,
        'parameters': t.parameterSchema,
      },
    }).toList();
  }

  /// Gemini-style function_declarations array.
  List<Map<String, dynamic>> toGeminiFunctionDeclarations() {
    return _tools.map((t) => {
      'name': t.name,
      'description': t.description,
      'parameters': t.parameterSchema,
    }).toList();
  }
}
