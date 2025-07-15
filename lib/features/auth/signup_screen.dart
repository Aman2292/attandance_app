import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  String? _errorMessage;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Basic validation
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill all fields';
        _isLoading = false;
      });
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
        _isLoading = false;
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters long';
        _isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match';
        _isLoading = false;
      });
      return;
    }

    try {
      final user = await _authService.signUp(
        name: name,
        email: email,
        password: password,
        role: 'employee', // Only employees
      );
      if (user != null && mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Iconsax.tick_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Registration Successful'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/employee');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'email-already-in-use':
            _errorMessage = 'This email is already registered.';
            break;
          case 'invalid-email':
            _errorMessage = 'Invalid email format.';
            break;
          case 'weak-password':
            _errorMessage = 'Password is too weak.';
            break;
          default:
            _errorMessage = 'Signup failed: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving user data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                  // Image.asset(
                  //   'assets/images/Signup.png',
                  //   height: 350,
                  //   fit: BoxFit.contain,
                  // ),
                  const SizedBox(height: 16),
                  Text(
                    'Create Account',
                    style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign up to get started',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Name Field
                  AppInputField(
                    labelText: 'Name',
                    controller: _nameController,
                    prefixIcon: const Icon(Iconsax.user, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
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
                  // Confirm Password Field with Visibility Toggle
                  AppInputField(
                    labelText: 'Confirm Password',
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    prefixIcon: const Icon(Iconsax.lock, color: AppColors.textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                        color: AppColors.textSecondary,
                        semanticLabel: _isConfirmPasswordVisible ? 'Hide confirm password' : 'Show confirm password',
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                 
                  const SizedBox(height: 16),
                  // Sign Up Button
                  ElevatedButton(
                    style: AppButtonStyles.primaryButton,
                    onPressed: _isLoading ? null : _signUp,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text('Sign Up', style: AppTextStyles.button),
                  ),
                  const SizedBox(height: 16),
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        style: AppButtonStyles.textButton,
                        onPressed: () => context.go('/login'),
                        child: Text(
                          'Log In',
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
