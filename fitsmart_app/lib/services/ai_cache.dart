/// Shared TTL cache entry for AI service clients.
class AiCacheEntry {
  final String response;
  final DateTime createdAt;
  final int ttlHours; // 0 = indefinite

  AiCacheEntry({
    required this.response,
    required this.createdAt,
    required this.ttlHours,
  });

  bool get isExpired {
    if (ttlHours == 0) return false;
    return DateTime.now().difference(createdAt).inHours >= ttlHours;
  }
}
