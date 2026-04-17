import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

/// A single food item from the knowledge base (Indian or common).
class FoodEntry {
  final String name;
  final String? category;
  final String? dish;
  final String? dietary;
  final double cal;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final String serving;
  final int servingG;
  final List<String> ingredients;
  final List<String> aliases;
  final String? description;

  const FoodEntry({
    required this.name,
    this.category,
    this.dish,
    this.dietary,
    required this.cal,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    required this.serving,
    required this.servingG,
    this.ingredients = const [],
    this.aliases = const [],
    this.description,
  });

  factory FoodEntry.fromIndianJson(Map<String, dynamic> json) {
    return FoodEntry(
      name: json['name'] as String,
      category: json['category'] as String?,
      dish: json['dish'] as String?,
      dietary: json['dietary'] as String?,
      cal: (json['cal'] as num).toDouble(),
      protein: (json['p'] as num).toDouble(),
      carbs: (json['c'] as num).toDouble(),
      fat: (json['f'] as num).toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0,
      serving: json['serving'] as String,
      servingG: (json['serving_g'] as num).toInt(),
      ingredients: (json['ingredients'] as List?)?.cast<String>() ?? [],
      aliases: (json['aliases'] as List?)?.cast<String>() ?? [],
      description: json['description'] as String?,
    );
  }

  factory FoodEntry.fromCommonJson(Map<String, dynamic> json) {
    return FoodEntry(
      name: json['name'] as String,
      cal: (json['cal'] as num).toDouble(),
      protein: (json['p'] as num).toDouble(),
      carbs: (json['c'] as num).toDouble(),
      fat: (json['f'] as num).toDouble(),
      serving: json['serving'] as String,
      servingG: _parseServingGrams(json['serving'] as String),
    );
  }

  /// Best-effort parse grams from serving string like "100g" or "1 egg (50g)"
  static int _parseServingGrams(String s) {
    final match = RegExp(r'(\d+)\s*g').firstMatch(s);
    if (match != null) return int.parse(match.group(1)!);
    final mlMatch = RegExp(r'(\d+)\s*ml').firstMatch(s);
    if (mlMatch != null) return int.parse(mlMatch.group(1)!);
    return 100; // default
  }

  /// Convert to a concise grounding string for injection into Gemini prompts.
  String toGroundingString() {
    final buf = StringBuffer()
      ..write('$name: $cal kcal, ${protein}g P, ${carbs}g C, ${fat}g F')
      ..write(' per $serving');
    if (dietary != null) buf.write(' [$dietary]');
    if (description != null) buf.write(' — $description');
    return buf.toString();
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'cal': cal,
        'p': protein,
        'c': carbs,
        'f': fat,
        'fiber': fiber,
        'serving': serving,
        'serving_g': servingG,
        if (category != null) 'category': category,
        if (dietary != null) 'dietary': dietary,
        if (description != null) 'description': description,
      };
}

/// Result from a knowledge base search — the food entry plus a relevance score.
class FoodSearchResult {
  final FoodEntry food;
  final double score; // 0.0 – 1.0 (higher = better match)

  const FoodSearchResult({required this.food, required this.score});
}

/// Client-side food knowledge service.
///
/// Loads [indian_foods.json] and [common_foods.json] from assets, indexes them,
/// and exposes fuzzy search that returns ranked results. This is the "retrieval"
/// half of the RAG pipeline — results are injected into Gemini prompts as
/// grounding context.
class FoodKnowledgeService {
  FoodKnowledgeService._();
  static final instance = FoodKnowledgeService._();

  List<FoodEntry> _indianFoods = [];
  List<FoodEntry> _commonFoods = [];
  bool _loaded = false;

  /// All foods combined (Indian + common).
  List<FoodEntry> get allFoods => [..._indianFoods, ..._commonFoods];

  /// Only the Indian food dataset.
  List<FoodEntry> get indianFoods => List.unmodifiable(_indianFoods);

  /// Only the common food dataset.
  List<FoodEntry> get commonFoods => List.unmodifiable(_commonFoods);

  bool get isLoaded => _loaded;

  /// Pre-built search index: lowercased name + aliases → FoodEntry
  final Map<String, List<FoodEntry>> _index = {};

  // ── Initialization ──────────────────────────────────────────────────

  Future<void> load() async {
    if (_loaded) return;

    final results = await Future.wait([
      rootBundle.loadString('assets/data/indian_foods.json'),
      rootBundle.loadString('assets/data/common_foods.json'),
    ]);

    final indianList = (jsonDecode(results[0]) as List)
        .map((e) => FoodEntry.fromIndianJson(e as Map<String, dynamic>))
        .toList();
    final commonList = (jsonDecode(results[1]) as List)
        .map((e) => FoodEntry.fromCommonJson(e as Map<String, dynamic>))
        .toList();

    _indianFoods = indianList;
    _commonFoods = commonList;
    _buildIndex();
    _loaded = true;
  }

  void _buildIndex() {
    _index.clear();
    for (final food in allFoods) {
      _addToIndex(food.name, food);
      for (final alias in food.aliases) {
        _addToIndex(alias, food);
      }
      // Also index individual ingredients for ingredient-based search
      for (final ing in food.ingredients) {
        _addToIndex(ing, food);
      }
    }
  }

  void _addToIndex(String key, FoodEntry food) {
    final k = key.toLowerCase().trim();
    _index.putIfAbsent(k, () => []).add(food);
  }

  // ── Search ──────────────────────────────────────────────────────────

  /// Fuzzy search over all foods. Returns top [limit] results sorted by
  /// relevance score (1.0 = exact match, lower = fuzzier).
  ///
  /// Scoring combines:
  ///  - Exact match on name or alias (1.0)
  ///  - Starts-with on name/alias (0.9)
  ///  - Substring match on name/alias (0.75)
  ///  - Substring match on ingredients (0.5)
  ///  - Normalized edit-distance similarity (0.3 – 0.7)
  ///
  /// Uses the pre-built [_index] for fast exact and prefix lookups before
  /// falling back to full fuzzy iteration for remaining results.
  List<FoodSearchResult> search(String query, {int limit = 10}) {
    if (!_loaded || query.trim().isEmpty) return [];

    final q = query.toLowerCase().trim();
    final tokens = q.split(RegExp(r'[\s,]+'));
    final scored = <FoodEntry, double>{};

    // ── Phase 1: Index-based fast lookup ──────────────────────────────
    // Check for exact key matches in the index (name, alias, ingredient).
    if (_index.containsKey(q)) {
      for (final food in _index[q]!) {
        // Determine the right score: exact name/alias = 1.0,
        // exact ingredient = 0.5 (ingredient match).
        final nameMatch = food.name.toLowerCase() == q;
        final aliasMatch =
            food.aliases.any((a) => a.toLowerCase() == q);
        final score = (nameMatch || aliasMatch) ? 1.0 : 0.5;
        scored[food] = max(scored[food] ?? 0, score);
      }
    }

    // Check for prefix matches across index keys.
    for (final entry in _index.entries) {
      if (entry.key.startsWith(q) && entry.key != q) {
        for (final food in entry.value) {
          // Determine if the matching key is a name/alias or ingredient.
          final nameMatch = food.name.toLowerCase().startsWith(q);
          final aliasMatch =
              food.aliases.any((a) => a.toLowerCase().startsWith(q));
          final score = (nameMatch || aliasMatch) ? 0.9 : 0.5;
          scored[food] = max(scored[food] ?? 0, score);
        }
      }
    }

    // Also check each query token against the index for multi-word queries.
    if (tokens.length > 1) {
      for (final token in tokens) {
        if (token.length < 2) continue;
        if (_index.containsKey(token)) {
          for (final food in _index[token]!) {
            scored[food] = max(scored[food] ?? 0, 0.5);
          }
        }
      }
    }

    // If we already have enough high-quality results from the index,
    // we can still run the fuzzy pass but skip foods already scored >= 0.9
    // to avoid redundant work.
    final indexMatched = scored.keys.toSet();

    // ── Phase 2: Fuzzy iteration for remaining results ────────────────
    for (final food in allFoods) {
      // Skip expensive fuzzy scoring for foods already matched with
      // high confidence from the index.
      if (indexMatched.contains(food) && scored[food]! >= 0.9) continue;

      double bestScore = scored[food] ?? 0;

      // Score against name
      bestScore = max(bestScore, _scoreMatch(q, food.name.toLowerCase()));

      // Score against aliases
      for (final alias in food.aliases) {
        bestScore = max(bestScore, _scoreMatch(q, alias.toLowerCase()));
      }

      // Score each query token against ingredients
      for (final token in tokens) {
        if (token.length < 2) continue;
        for (final ing in food.ingredients) {
          if (ing.toLowerCase().contains(token)) {
            bestScore = max(bestScore, 0.5);
          }
        }
      }

      // Score against category/dish
      if (food.category != null && food.category!.toLowerCase().contains(q)) {
        bestScore = max(bestScore, 0.4);
      }
      if (food.dish != null && food.dish!.toLowerCase().contains(q)) {
        bestScore = max(bestScore, 0.45);
      }

      if (bestScore > 0.1) {
        scored[food] = max(scored[food] ?? 0, bestScore);
      }
    }

    final results = scored.entries
        .map((e) => FoodSearchResult(food: e.key, score: e.value))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return results.take(limit).toList();
  }

  /// Score how well [candidate] matches [query].
  double _scoreMatch(String query, String candidate) {
    if (candidate == query) return 1.0;
    if (candidate.startsWith(query)) return 0.9;
    if (candidate.contains(query)) return 0.75;
    if (query.length >= 3) {
      final sim = _similarity(query, candidate);
      if (sim > 0.5) return sim * 0.8;
    }
    return 0;
  }

  /// Normalized similarity (1 - normalizedEditDistance).
  double _similarity(String a, String b) {
    final dist = _editDistance(a, b);
    final maxLen = max(a.length, b.length);
    if (maxLen == 0) return 1.0;
    return 1.0 - (dist / maxLen);
  }

  /// Levenshtein edit distance.
  int _editDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final m = a.length;
    final n = b.length;
    // Space-optimized: two rows
    var prev = List.generate(n + 1, (j) => j);
    var curr = List.filled(n + 1, 0);

    for (var i = 1; i <= m; i++) {
      curr[0] = i;
      for (var j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = [
          prev[j] + 1, // deletion
          curr[j - 1] + 1, // insertion
          prev[j - 1] + cost, // substitution
        ].reduce(min);
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }
    return prev[n];
  }

  // ── RAG Grounding ───────────────────────────────────────────────────

  /// Given a user query (photo caption, text description, or chat message),
  /// return a grounding context block suitable for injection into a Gemini prompt.
  ///
  /// This is the core RAG retrieval → prompt-injection step.
  String buildGroundingContext(String query, {int maxResults = 8}) {
    final results = search(query, limit: maxResults);
    if (results.isEmpty) return '';

    final buf = StringBuffer()
      ..writeln('=== FOOD KNOWLEDGE BASE (use as grounding reference) ===')
      ..writeln(
          'The following foods from our verified database may be relevant.');
    for (final r in results) {
      buf.writeln('• ${r.food.toGroundingString()}');
    }
    buf.writeln(
        'Use the above data to improve accuracy. If the food matches one of these entries, prefer the listed nutritional values.');
    return buf.toString();
  }

  /// Build grounding for a list of food names (e.g. after Gemini identifies items in a photo).
  String buildGroundingForNames(List<String> foodNames, {int perName = 3}) {
    if (foodNames.isEmpty) return '';

    final seen = <String>{};
    final results = <FoodSearchResult>[];
    for (final name in foodNames) {
      for (final r in search(name, limit: perName)) {
        if (seen.add(r.food.name)) results.add(r);
      }
    }
    if (results.isEmpty) return '';

    final buf = StringBuffer()
      ..writeln('=== FOOD KNOWLEDGE BASE (use as grounding reference) ===');
    for (final r in results) {
      buf.writeln('• ${r.food.toGroundingString()}');
    }
    buf.writeln(
        'Prefer these verified nutritional values when they match identified food items.');
    return buf.toString();
  }
}
