
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (user != null && mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Card(
          elevation: 0, // Minimal elevation for seamless look
          margin: EdgeInsets.zero, // No margins to cover full screen
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // No rounded corners
          child: Container(
            width: MediaQuery.of(context).size.width, // Full screen width
            height: MediaQuery.of(context).size.height, // Full screen height
            color: AppColors.background, // Match Scaffold background
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo or Header
                  Image.asset(
                    'assets/images/Login.png',
                    height: 350,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome Back',
                    style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Email Field
                  AppInputField(
                    labelText: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Iconsax.sms, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  // Password Field with Visibility Toggle
                  AppInputField(
                    labelText: 'Password',
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    prefixIcon: const Icon(Iconsax.lock, color: AppColors.textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                        color: AppColors.textSecondary,
                        semanticLabel: _isPasswordVisible ? 'Hide password' : 'Show password',
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Forgot Password Link
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: TextButton(
                  //     style: AppButtonStyles.textButton,
                  //     onPressed: () => context.go('/forgot-password'),
                  //     child: Text(
                  //       'Forgot Password?',
                  //       style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 16),
                  // Sign In Button
                  ElevatedButton(
                    style: AppButtonStyles.primaryButton,
                    onPressed: _isLoading ? null : _signIn,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text('Sign In', style: AppTextStyles.button),
                  ),
                  const SizedBox(height: 16),
                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        style: AppButtonStyles.textButton,
                        onPressed: () => context.go('/signup'),
                        child: Text(
                          'Sign Up',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Error Message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: AnimatedOpacity(
                        opacity: _errorMessage != null ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.warning_2,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _errorMessage!,
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
