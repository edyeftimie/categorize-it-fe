import 'package:categoriseit_fe/presentation/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers.dart';
import '../../../core/services/google_sign_in_service.dart';
import 'login_screen.dart'; 


class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _obscure  = true;
  bool _loading  = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text;
    final pass2 = _pass2Ctrl.text;

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (pass != pass2) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authControllerProvider.notifier).register(
        email: email, password: pass, name: name,
      );
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'An unexpected error occurred.');
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
              const SizedBox(height: 48),
              const Text('Create account',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Text('Start tracking your finances',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 32),

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.redBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.red.withValues(alpha: 0.4)),
                  ),
                  child: Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 13)),
                ),
                const SizedBox(height: 16),
              ],

              const AuthLabel('Name'),
              const SizedBox(height: 6),
              AuthTextField(controller: _nameCtrl, hint: 'Your name'),
              const SizedBox(height: 16),

              const AuthLabel('Email'),
              const SizedBox(height: 6),
              AuthTextField(controller: _emailCtrl, hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),

              const AuthLabel('Password'),
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
              const SizedBox(height: 16),

              const AuthLabel('Confirm password'),
              const SizedBox(height: 6),
              AuthTextField(controller: _pass2Ctrl, hint: '••••••••', obscure: _obscure),
              const SizedBox(height: 28),

              AuthPrimaryButton(label: 'Create Account', loading: _loading, onTap: _register),
              const SizedBox(height: 24),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Already have an account? ',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Text('Sign In',
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