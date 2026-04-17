import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/subscription_service.dart';

/// True when the current user holds the `premium` flag on their user doc.
/// Granted manually after a verified bank transfer (see paywall_screen).
final isPremiumProvider = StreamProvider<bool>((ref) {
  return SubscriptionService.instance.premiumStream;
});
