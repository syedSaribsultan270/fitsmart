import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/liquid_glass.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../services/auth_service.dart';
import '../../../services/analytics_service.dart';
import '../../onboarding/providers/onboarding_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final wasAnonymous = AuthService.currentUser != null && AuthService.isAnonymous;
      // If current user is anonymous, link instead of creating new
      if (wasAnonymous) {
        await AuthService.linkWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await AuthService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      // Update display name
      if (_nameController.text.trim().isNotEmpty) {
        await AuthService.updateDisplayName(_nameController.text.trim());
      }

      await AnalyticsService.instance.track('auth_sign_up', props: {
        'method': 'email',
        'account_linked': wasAnonymous,
      });
      await AnalyticsService.instance.setUserId(AuthService.currentUser!.uid);

      // Navigate explicitly:
      //  - Linked anonymous account → already onboarded → go to dashboard.
      //  - Fresh signup → needs onboarding.
      if (mounted) context.go(wasAnonymous ? '/dashboard' : '/onboarding');
    } on FirebaseAuthException catch (e) {
      await AnalyticsService.instance.track('auth_error', props: {'method': 'email_signup', 'error_code': e.code});
      if (mounted) setState(() => _errorMessage = _signupErrorMessage(e.code));
    } catch (e) {
      await AnalyticsService.instance.track('auth_error', props: {'method': 'email_signup', 'error_code': 'unknown'});
      if (mounted) setState(() => _errorMessage = 'Sign up failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    // Capture anonymous state before triggering Google flow.
    final wasAnonymous = AuthService.currentUser != null && AuthService.isAnonymous;
    try {
      await AuthService.signInWithGoogle();
      await AnalyticsService.instance.track('auth_sign_up', props: {
        'method': 'google',
        'account_linked': wasAnonymous,
      });
      await AnalyticsService.instance.setUserId(AuthService.currentUser!.uid);
      // Navigate explicitly — for credential-already-in-use the UID may
      // have changed, so re-check onboarding state via UID-scoped helper.
      if (mounted) {
        final onboarded = await OnboardingNotifier.isOnboardingCompleteLocal();
        if (mounted) context.go(onboarded ? '/dashboard' : '/onboarding');
      }
    } on FirebaseAuthException catch (e) {
      await AnalyticsService.instance.track('auth_error', props: {'method': 'google_signup', 'error_code': e.code});
      if (mounted) setState(() => _errorMessage = _signupErrorMessage(e.code));
    } catch (e) {
      await AnalyticsService.instance.track('auth_error', props: {'method': 'google_signup', 'error_code': 'unknown'});
      if (mounted) setState(() => _errorMessage = 'Google sign-up failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      appBar: LiquidAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),

                Text('Create Account', style: AppTypography.h1)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: -0.1),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Start your fitness transformation today',
                  style: AppTypography.body.copyWith(color: context.colors.textTertiary),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: AppSpacing.xxxl),

                // Name
                TextFormField(
                  controller: _nameController,
                  style: AppTypography.body,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter your name';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Email
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

                // Password
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
                    if (v == null || v.isEmpty) return 'Enter a password';
                    if (v.length < 8) return 'At least 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Confirm password
                TextFormField(
                  controller: _confirmController,
                  obscureText: true,
                  style: AppTypography.body,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
                  ),
                  validator: (v) {
                    if (v != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Inline error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
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

                // Sign up button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: context.colors.textInverse),
                          )
                        : const Text('Create Account'),
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

                // Google Sign Up
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signUpWithGoogle,
                    icon: const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                    label: Text(
                      'Sign up with Google',
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

                const SizedBox(height: AppSpacing.lg),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTypography.caption.copyWith(color: context.colors.textTertiary),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        'Sign In',
                        style: AppTypography.caption.copyWith(
                          color: context.colors.lime,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _signupErrorMessage(String code) {
  switch (code) {
    case 'email-already-in-use':
      return 'An account with this email already exists.';
    case 'invalid-email':
      return 'Invalid email address.';
    case 'weak-password':
      return 'Password is too weak. Use at least 6 characters.';
    case 'operation-not-allowed':
      return 'Email/password sign-up is disabled.';
    case 'credential-already-in-use':
      return 'This email is already linked to another account.';
    default:
      return 'Sign up error: $code';
  }
}
