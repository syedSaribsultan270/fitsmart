import 'package:flutter_test/flutter_test.dart';
import 'package:fitsmart_app/services/ai_cache.dart';

void main() {
  group('AiCacheEntry.isExpired', () {
    test('ttl=0 (indefinite) never expires', () {
      final entry = AiCacheEntry(
        response: 'cached data',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        ttlHours: 0,
      );
      expect(entry.isExpired, false);
    });

    test('fresh entry (created just now) is not expired', () {
      final entry = AiCacheEntry(
        response: 'cached data',
        createdAt: DateTime.now(),
        ttlHours: 24,
      );
      expect(entry.isExpired, false);
    });

    test('stale entry (created beyond TTL) is expired', () {
      final entry = AiCacheEntry(
        response: 'cached data',
        createdAt: DateTime.now().subtract(const Duration(hours: 25)),
        ttlHours: 24,
      );
      expect(entry.isExpired, true);
    });

    test('entry at exact TTL boundary is expired', () {
      final entry = AiCacheEntry(
        response: 'cached data',
        createdAt: DateTime.now().subtract(const Duration(hours: 24)),
        ttlHours: 24,
      );
      expect(entry.isExpired, true);
    });

    test('entry 1 hour before TTL is not expired', () {
      final entry = AiCacheEntry(
        response: 'cached data',
        createdAt: DateTime.now().subtract(const Duration(hours: 23)),
        ttlHours: 24,
      );
      expect(entry.isExpired, false);
    });
  });
}
