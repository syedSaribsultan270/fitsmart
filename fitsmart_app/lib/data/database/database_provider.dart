import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';

/// Singleton database instance used throughout the app.
final AppDatabase appDatabaseInstance = AppDatabase();

final databaseProvider = Provider<AppDatabase>((ref) {
  return appDatabaseInstance;
});
