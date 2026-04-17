import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../../data/database/app_database.dart';
import '../../data/database/database_provider.dart';
import '../auth_service.dart';
import '../firestore_service.dart';
import 'ai_tool.dart';

class LogWeightTool extends AiTool {
  @override
  String get name => 'log_weight';

  @override
  bool get isWrite => true;

  @override
  String get confirmTitle => 'Log weight';

  @override
  String get description =>
      'Log the user\'s weigh-in. Call this when the user explicitly reports '
      'their current body weight (e.g. "weighed in at 82kg today"). Weight '
      'should be in kilograms — if user says pounds, convert before calling.';

  @override
  Map<String, dynamic> get parameterSchema => {
        'type': 'object',
        'properties': {
          'weight_kg': {
            'type': 'number',
            'description': 'Body weight in kilograms (convert from lbs if needed).',
          },
          'note': {
            'type': 'string',
            'description': 'Optional short note (e.g. "morning fasted").',
          },
        },
        'required': ['weight_kg'],
      };

  @override
  String summarize(Map<String, dynamic> args) {
    final w = (args['weight_kg'] as num?)?.toStringAsFixed(1) ?? '?';
    final note = args['note'] as String?;
    return note == null || note.isEmpty
        ? '$w kg'
        : '$w kg · $note';
  }

  @override
  Future<AiToolResult> execute(ToolRef read, Map<String, dynamic> args) async {
    final w = (args['weight_kg'] as num?)?.toDouble() ?? 0;
    if (w < 20 || w > 400) {
      return AiToolResult.error(
        'weight_kg must be between 20 and 400 — you sent $w',
      );
    }
    final note = args['note'] as String? ?? '';
    final loggedAt = DateTime.now();
    final db = read(databaseProvider);
    final localId = await db.insertWeight(WeightLogsCompanion(
      weightKg: Value(w),
      note: Value(note),
      loggedAt: Value(loggedAt),
    ));

    final uid = AuthService.uid;
    if (uid != null) {
      FirestoreService.addWeightLog(uid, {
        'weightKg': w,
        'loggedAt': loggedAt.toIso8601String(),
      }).then((cloudId) {
        if (cloudId.isNotEmpty) db.setWeightCloudId(localId, cloudId);
      }).catchError((Object e) {
        debugPrint('[AiTool:log_weight] cloud sync failed: $e');
      });
    }

    return AiToolResult.ok(
      {'logged': true, 'weight_kg': w},
      entityId: localId,
    );
  }
}
