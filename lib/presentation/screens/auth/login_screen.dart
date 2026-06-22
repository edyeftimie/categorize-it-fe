import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/google_sign_in_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers.dart';
import '../../widgets/auth_widgets.dart'; // AuthLabel, AuthTextField, AuthPrimaryButton, AuthGoogleButton

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure  = true;
  bool _loading  = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authControllerProvider.notifier).login(email: email, password: pass);
      // GoRouter redirect handles navigation on success.
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() { _loading = true; _error = null; });
    try {
      final idToken = await GoogleSignInService.getIdToken();
      if (idToken == null) return;
      await ref.read(authControllerProvider.notifier).googleLogin(idToken: idToken);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 64),
              // Logo / title
              Center(
                child: Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.emeraldBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: AppColors.emerald, size: 32),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text('CategoriseIt',
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text('Sign in to your account',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              ),
              const SizedBox(height: 40),

              // Error banner
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.redBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.red.withOpacity(0.4)),
                  ),
                  child: Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 13)),
                ),
                const SizedBox(height: 16),
              ],

              // Email
              AuthLabel('Email'),
              const SizedBox(height: 6),
              AuthTextField(
                controller: _emailCtrl,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password
              AuthLabel('Password'),
              const SizedBox(height: 6),
              AuthTextField(
                controller: _passCtrl,
                hint: '••••••••',
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textMuted, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 28),

              // Sign In button
              AuthPrimaryButton(
                label: 'Sign In',
                loading: _loading,
                onTap: _login,
              ),
              const SizedBox(height: 16),

              // OR divider
              Row(children: [
                Expanded(child: Divider(color: AppColors.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ),
                Expanded(child: Divider(color: AppColors.border)),
              ]),
              const SizedBox(height: 16),

              // Google Sign-In
              AuthGoogleButton(loading: _loading, onTap: _googleSignIn),
              const SizedBox(height: 32),

              // Register link
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Don't have an account? ",
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                GestureDetector(
                  onTap: () => context.push('/register'),
                  child: const Text('Register',
                      style: TextStyle(color: AppColors.emerald, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}