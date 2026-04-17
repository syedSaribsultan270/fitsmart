import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/health_service.dart';

/// Whether the user has granted Health (Apple Health / Health Connect) permission.
/// Toggled by calling HealthService.instance.requestPermission().
final isHealthConnectedProvider = StateProvider<bool>(
  (ref) => HealthService.instance.isAuthorized,
);

/// Today's step count from Health. Returns 0 when not authorized or unavailable.
final healthStepsProvider = FutureProvider.autoDispose<int>((ref) {
  return HealthService.instance.getStepsToday();
});

/// Today's active calories burned from Health. Returns 0 when unavailable.
final healthActiveCalProvider = FutureProvider.autoDispose<double>((ref) {
  return HealthService.instance.getActiveCaloriesToday();
});
