import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/liquid_glass.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.sendPasswordReset(_emailController.text.trim());
      if (mounted) setState(() => _sent = true);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        if (e.code == 'user-not-found') {
          setState(() => _errorMessage = 'No account found with this email.');
        } else {
          setState(() => _errorMessage = 'Failed to send reset email. Try again.');
        }
      }
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'Something went wrong.');
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
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: _sent ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text('Reset Password', style: AppTypography.h1)
              .animate()
              .fadeIn(duration: 300.ms),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "Enter your email and we'll send you a link to reset your password.",
            style: AppTypography.body.copyWith(color: context.colors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.xxxl),

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

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendReset,
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: context.colors.textInverse),
                    )
                  : const Text('Send Reset Link'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.mark_email_read_rounded, size: 64, color: context.colors.success)
            .animate()
            .scale(duration: 400.ms, curve: Curves.elasticOut),
        const SizedBox(height: AppSpacing.lg),
        Text('Check your email', style: AppTypography.h2),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'We sent a password reset link to ${_emailController.text.trim()}',
          style: AppTypography.body.copyWith(color: context.colors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxxl),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Back to Sign In'),
          ),
        ),
      ],
    );
  }
}
