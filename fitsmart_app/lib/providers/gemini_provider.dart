import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_client.dart';
import '../services/groq_client.dart';
import '../services/ai_orchestrator_service.dart';
import '../services/local_ai_fallback_service.dart';
import '../services/local_llm_service.dart';

final geminiClientProvider = Provider<GeminiClient>((ref) {
  const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  assert(apiKey.isNotEmpty, 'GEMINI_API_KEY must be provided via --dart-define');
  return GeminiClient(apiKey: apiKey);
});

/// Groq cloud provider (secondary cloud fallback).
/// Pass key via --dart-define=GROQ_API_KEY=gsk_...
/// If no key is provided, Groq tier is silently skipped.
final groqClientProvider = Provider<GroqClient?>((ref) {
  const apiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
  if (apiKey.isEmpty) return null;
  return GroqClient(apiKey: apiKey);
});

/// Singleton provider for the on-device LLM service (Gemma 2 2B).
final localLlmProvider = Provider<LocalLlmService>((ref) {
  return LocalLlmService.instance;
});

/// The main AI provider for the entire app — **4-tier fallback**.
///
/// Tier 1a: [GeminiClient] → Tier 1b: [GroqClient] → Tier 2: [LocalLlmService]
/// → Tier 3: [LocalAiFallbackService].
/// All screens should use this instead of individual providers directly.
final aiProvider = Provider<AiOrchestratorService>((ref) {
  final gemini = ref.read(geminiClientProvider);
  final groq = ref.read(groqClientProvider);
  final llm = ref.read(localLlmProvider);
  return AiOrchestratorService(
    gemini: gemini,
    groq: groq,
    local: LocalAiFallbackService.instance,
    llm: llm,
  );
});
