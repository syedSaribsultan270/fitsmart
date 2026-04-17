import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Minimal "reader" interface — widgets pass `WidgetRef`, providers pass
/// `Ref`, neither extends the other, but both expose `read()`. Using a
/// wrapper lets tools stay agnostic to who called them.
typedef ToolRef = T Function<T>(ProviderListenable<T>);

/// A function the AI can request the app to run on the user's behalf.
///
/// Two flavours:
/// - **Write tools** mutate state (log_meal, log_weight, etc.) — gated
///   behind user confirmation before execution.
/// - **Read tools** return data (get_todays_totals, etc.) — always
///   auto-execute, no confirmation needed.
abstract class AiTool {
  /// Machine name sent to the model. Snake_case, stable across versions.
  String get name;

  /// Human-readable description for the model's system prompt.
  /// Be specific about WHEN the tool should be used to reduce spurious
  /// calls (e.g. "Call this when the user says they just ate something").
  String get description;

  /// JSON Schema (OpenAPI-ish) describing the parameters. Used by both
  /// Gemini (`function_declarations`) and Groq (`tools[].function.parameters`).
  Map<String, dynamic> get parameterSchema;

  /// Whether the tool mutates persistent state. Writes require confirmation;
  /// reads execute directly.
  bool get isWrite;

  /// Human-readable title shown on the confirmation card (write tools only).
  /// Should answer "what will happen?" in a short verb phrase.
  /// Example: `log_meal` → "Log meal".
  String get confirmTitle;

  /// Execute the tool with [args] from the model.
  /// - On success: return [AiToolResult.ok] with a JSON-serializable value
  ///   that gets sent back to the model.
  /// - On user-level error (invalid args, out-of-bounds): return
  ///   [AiToolResult.error] — the model will see the error and can retry.
  /// - On infrastructure error: throw — the orchestrator surfaces it.
  ///
  /// [read] is a closure over the caller's Riverpod reader. Works with
  /// both `WidgetRef.read` and `Ref.read`.
  Future<AiToolResult> execute(ToolRef read, Map<String, dynamic> args);

  /// Build a short, human-readable summary for the confirmation or receipt
  /// card. Called with the raw args (before execution) and, for receipts,
  /// the success result.
  /// Example: `log_meal` → "Aloo Gobi · 150 kcal · 4p / 18c / 7f"
  String summarize(Map<String, dynamic> args);
}

/// Result of tool execution. Feeds back into the model as a tool-response
/// message so the model can acknowledge, retry on error, or continue.
class AiToolResult {
  final bool success;
  final Map<String, dynamic> data;
  final String? errorMessage;

  /// For write tools: a stable identifier the UI can use to wire Undo.
  /// Typically the local Drift row id.
  final int? entityId;

  const AiToolResult.ok(this.data, {this.entityId})
      : success = true,
        errorMessage = null;

  const AiToolResult.error(String message)
      : success = false,
        data = const {},
        errorMessage = message,
        entityId = null;

  Map<String, dynamic> toJson() => {
        'success': success,
        if (success) ...data,
        if (!success) 'error': errorMessage,
      };
}

/// A pending tool call awaiting user confirmation. Held by the orchestrator
/// while the UI shows the confirmation card.
class PendingToolCall {
  /// Stable id used to correlate the model's request with the response
  /// once the user confirms / cancels.
  final String id;
  final AiTool tool;
  final Map<String, dynamic> args;

  const PendingToolCall({
    required this.id,
    required this.tool,
    required this.args,
  });
}
