import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/food_knowledge_service.dart';

/// Provides the singleton [FoodKnowledgeService] instance.
///
/// Usage:
///   final kb = ref.read(foodKnowledgeProvider);
///   final results = kb.search('paneer');
///   final grounding = kb.buildGroundingContext('paneer tikka masala');
final foodKnowledgeProvider = Provider<FoodKnowledgeService>((ref) {
  return FoodKnowledgeService.instance;
});

/// Future that resolves once the knowledge base has finished loading.
/// Watch this in a top-level widget to ensure data is ready.
final foodKnowledgeLoadProvider = FutureProvider<void>((ref) async {
  final service = ref.read(foodKnowledgeProvider);
  await service.load();
});
