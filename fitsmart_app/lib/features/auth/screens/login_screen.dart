import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/analytics_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      await AnalyticsService.instance.track('auth_sign_in', props: {'method': 'email'});
      await AnalyticsService.instance.setUserId(AuthService.currentUser!.uid);
    } on FirebaseAuthException catch (e) {
      await AnalyticsService.instance.track('auth_error', props: {'method': 'email', 'error_code': e.code});
      if (mounted) setState(() => _errorMessage = _authErrorMessage(e.code));
    } catch (e) {
      await AnalyticsService.instance.track('auth_error', props: {'method': 'email', 'error_code': 'unknown'});
      if (mounted) setState(() => _errorMessage = 'Sign in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await AuthService.signInAnonymously();
      if (AuthService.currentUser != null) {
        await AnalyticsService.instance.setUserId(AuthService.currentUser!.uid);
      }
      await AnalyticsService.instance.track('auth_sign_in', props: {'method': 'guest'});
      if (mounted) context.go('/onboarding');
    } catch (e) {
      await AnalyticsService.instance.track('auth_error', props: {'method': 'guest', 'error_code': 'unknown'});
      if (mounted) setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await AuthService.signInWithGoogle();
      await AnalyticsService.instance.track('auth_sign_in', props: {'method': 'google'});
      await AnalyticsService.instance.setUserId(AuthService.currentUser!.uid);
    } on FirebaseAuthException catch (e) {
      await AnalyticsService.instance.track('auth_error', props: {'method': 'google', 'error_code': e.code});
      if (mounted) setState(() => _errorMessage = _authErrorMessage(e.code));
    } catch (e) {
      await AnalyticsService.instance.track('auth_error', props: {'method': 'google', 'error_code': 'unknown'});
      if (mounted) setState(() => _errorMessage = 'Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 16;
    final settings = ref.watch(settingsProvider);
    final isDark = settings.themeMode == ThemeMode.dark ||
        (settings.themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Theme toggle
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: context.colors.textTertiary,
                    ),
                    tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
                    onPressed: () {
                      ref.read(settingsProvider.notifier).setThemeMode(
                            isDark ? ThemeMode.light : ThemeMode.dark,
                          );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Logo
                const Text('\u26A1', style: TextStyle(fontSize: 56))
                    .animate()
                    .scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'FitSmart AI',
                  style: AppTypography.h1.copyWith(
                    color: context.colors.lime,
                    letterSpacing: -1,
                  ),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your AI fitness companion',
                  style: AppTypography.body.copyWith(color: context.colors.textTertiary),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: AppSpacing.xl),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTypography.body,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, size: 20),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter your email';
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: AppTypography.body,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20,
                        color: context.colors.textTertiary,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter your password';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text(
                      'Forgot password?',
                      style: AppTypography.caption.copyWith(color: context.colors.cyan),
                    ),
                  ),
                ),

                // Inline error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: context.colors.errorBg,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: AppTypography.caption.copyWith(color: context.colors.error),
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.md),

                // Sign In button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: context.colors.textInverse,
                            ),
                          )
                        : const Text('Sign In'),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: context.colors.surfaceCardBorder)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text('or', style: AppTypography.caption.copyWith(color: context.colors.textTertiary)),
                    ),
                    Expanded(child: Divider(color: context.colors.surfaceCardBorder)),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Google Sign In
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                    label: Text(
                      'Continue with Google',
                      style: AppTypography.bodyMedium.copyWith(color: context.colors.textSecondary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.colors.surfaceCardBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Continue as guest
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _continueAsGuest,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.colors.surfaceCardBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    child: Text(
                      'Continue as Guest',
                      style: AppTypography.bodyMedium.copyWith(color: context.colors.textSecondary),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTypography.caption.copyWith(color: context.colors.textTertiary),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/signup'),
                      child: Text(
                        'Sign Up',
                        style: AppTypography.caption.copyWith(
                          color: context.colors.lime,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: bottomPad),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


String _authErrorMessage(String code) {
  switch (code) {
    case 'user-not-found':
      return 'No account found with this email.';
    case 'wrong-password':
      return 'Incorrect password.';
    case 'invalid-email':
      return 'Invalid email address.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'too-many-requests':
      return 'Too many attempts. Try again later.';
    case 'invalid-credential':
      return 'Invalid email or password.';
    default:
      return 'Authentication error: $code';
  }
}
