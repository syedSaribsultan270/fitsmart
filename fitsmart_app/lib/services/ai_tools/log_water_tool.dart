import '../../data/database/database_provider.dart';
import 'ai_tool.dart';

class LogWaterTool extends AiTool {
  @override
  String get name => 'log_water';

  @override
  bool get isWrite => true;

  @override
  String get confirmTitle => 'Log water';

  @override
  String get description =>
      'Log water intake. Call this when the user says they drank water — '
      'convert cups/bottles/litres into millilitres (1 cup ≈ 240ml, '
      '1 standard bottle ≈ 500ml, 1L = 1000ml).';

  @override
  Map<String, dynamic> get parameterSchema => {
        'type': 'object',
        'properties': {
          'ml': {
            'type': 'integer',
            'description': 'Volume in millilitres. Positive, up to 5000.',
          },
        },
        'required': ['ml'],
      };

  @override
  String summarize(Map<String, dynamic> args) {
    final ml = (args['ml'] as num?)?.toInt() ?? 0;
    return ml >= 1000
        ? '${(ml / 1000).toStringAsFixed(1)}L'
        : '$ml ml';
  }

  @override
  Future<AiToolResult> execute(ToolRef read, Map<String, dynamic> args) async {
    final ml = (args['ml'] as num?)?.toInt() ?? 0;
    if (ml < 1 || ml > 5000) {
      return AiToolResult.error('ml must be between 1 and 5000 — you sent $ml');
    }
    final db = read(databaseProvider);
    await db.addWater(ml);
    return AiToolResult.ok({'logged': true, 'ml': ml});
  }
}
