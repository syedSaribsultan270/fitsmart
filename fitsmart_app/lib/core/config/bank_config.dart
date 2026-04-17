/// Bank transfer details shown on the manual-payment paywall.
///
/// Override at build time so secrets / account details aren't committed:
///   flutter run \
///     --dart-define=BANK_NAME='HBL' \
///     --dart-define=BANK_ACCOUNT_TITLE='FitSmart AI (Pvt) Ltd' \
///     --dart-define=BANK_ACCOUNT_NUMBER='1234-5678-9012' \
///     --dart-define=BANK_IBAN='PK00HABB0000000000000000' \
///     --dart-define=BANK_SWIFT='HABBPKKA' \
///     --dart-define=BANK_BRANCH='Karachi Main' \
///     --dart-define=PAYMENT_PRICE_MONTHLY='PKR 1,500 / month' \
///     --dart-define=PAYMENT_PRICE_ANNUAL='PKR 12,000 / year (save 33%)' \
///     --dart-define=PAYMENT_PRICE_LIFETIME='PKR 30,000 (one-time)' \
///     --dart-define=PAYMENT_CONFIRM_EMAIL='payments@fitsmart.ai' \
///     --dart-define=PAYMENT_CONFIRM_WHATSAPP='+92 300 0000000'
///
/// Placeholder defaults are intentionally non-functional so the app never
/// ships real account numbers without the build flag set.
abstract class BankConfig {
  static const bankName = String.fromEnvironment(
    'BANK_NAME', defaultValue: 'Your Bank Name',
  );
  static const accountTitle = String.fromEnvironment(
    'BANK_ACCOUNT_TITLE', defaultValue: 'FitSmart AI',
  );
  static const accountNumber = String.fromEnvironment(
    'BANK_ACCOUNT_NUMBER', defaultValue: '0000-0000-0000-0000',
  );
  static const iban = String.fromEnvironment(
    'BANK_IBAN', defaultValue: 'PK00ABCD0000000000000000',
  );
  static const swift = String.fromEnvironment(
    'BANK_SWIFT', defaultValue: 'XXXXXXXX',
  );
  static const branch = String.fromEnvironment(
    'BANK_BRANCH', defaultValue: 'Main Branch',
  );

  static const priceMonthly = String.fromEnvironment(
    'PAYMENT_PRICE_MONTHLY', defaultValue: 'Rs 1,500 / month',
  );
  static const priceAnnual = String.fromEnvironment(
    'PAYMENT_PRICE_ANNUAL', defaultValue: 'Rs 12,000 / year',
  );
  static const priceLifetime = String.fromEnvironment(
    'PAYMENT_PRICE_LIFETIME', defaultValue: 'Rs 30,000 (one-time)',
  );

  static const confirmEmail = String.fromEnvironment(
    'PAYMENT_CONFIRM_EMAIL', defaultValue: 'payments@fitsmart.ai',
  );
  static const confirmWhatsapp = String.fromEnvironment(
    'PAYMENT_CONFIRM_WHATSAPP', defaultValue: '+00 000 0000000',
  );

  /// True only when build flags actually set real bank info.
  /// UI can hide / warn when this is false (e.g. dev builds).
  static bool get isConfigured =>
      accountNumber != '0000-0000-0000-0000' &&
      bankName != 'Your Bank Name';
}
