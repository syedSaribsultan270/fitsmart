import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_client.dart';

final geminiClientProvider = Provider<GeminiClient>((ref) {
  const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  assert(apiKey.isNotEmpty, 'GEMINI_API_KEY must be provided via --dart-define');
  return GeminiClient(apiKey: apiKey);
});
