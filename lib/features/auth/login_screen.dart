import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';
import '../../core/widgets/input_field.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  String? _errorMessage;

  Future<void> _signIn() async {
    try {
      final user = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (user != null && mounted) {
        context.go(user.role == 'admin' ? '/admin' : '/employee');
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains('User data not found')) {
          _errorMessage = 'Account not found. Please sign up first.';
        } else {
          _errorMessage = 'Login failed: $e';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Login', style: AppTextStyles.heading2)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppInputField(
              labelText: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Iconsax.sms),
            ),
            const SizedBox(height: 16),
            AppInputField(
              labelText: 'Password',
              controller: _passwordController,
              obscureText: true,
              prefixIcon: const Icon(Iconsax.lock),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: AppButtonStyles.primaryButton,
              onPressed: _signIn,
              child: const Text('Sign In', style: AppTextStyles.button),
            ),
            const SizedBox(height: 16),
            TextButton(
              style: AppButtonStyles.textButton,
              onPressed: () => context.go('/signup'),
              child: const Text('Don\'t have an account? Sign Up'),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage!,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}