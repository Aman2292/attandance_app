import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';
import '../../core/widgets/input_field.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  String? _errorMessage;

  Future<void> _signUp() async {
    try {
      final user = await _authService.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: 'employee', // Default to employee role
      );
      if (user != null && mounted) {
        context.go('/employee');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Sign Up', style: AppTextStyles.heading2)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppInputField(
              labelText: 'Name',
              controller: _nameController,
              prefixIcon: const Icon(Iconsax.user),
            ),
            const SizedBox(height: 16),
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
              onPressed: _signUp,
              child: const Text('Sign Up', style: AppTextStyles.button),
            ),
            const SizedBox(height: 16),
            TextButton(
              style: AppButtonStyles.textButton,
              onPressed: () => context.go('/login'),
              child: const Text('Already have an account? Log In'),
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