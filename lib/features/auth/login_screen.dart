import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumalearn/core/theme/app_theme.dart';
import 'services/auth_service.dart'; // Make sure you created this in the previous step!

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLoginMode = true; // Toggle between Login and Sign Up

  // Handle Form Submission
  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);

      if (_isLoginMode) {
        // Log In
        await authService.signIn(email, password);
      } else {
        // Sign Up
        await authService.signUp(email, password);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created! Please sign in.')),
          );
          setState(() => _isLoginMode = true); // Switch to login after signup
          setState(() => _isLoading = false);
          return;
        }
      }

      // Success! Navigate to Home
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      // Error handling
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().contains('message')
                ? "Error: Check your credentials"
                : "An error occurred"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. LOGO & TITLE
              const Icon(Icons.lock_outline, size: 60, color: AppTheme.neonGreen),
              const SizedBox(height: 20),
              Text(
                _isLoginMode ? 'Welcome Back' : 'Create Account',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),

              // 2. INPUT FIELDS
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textGrey),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.key_outlined, color: AppTheme.textGrey),
                ),
              ),
              const SizedBox(height: 30),

              // 3. ACTION BUTTON
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.black),
                  )
                      : Text(_isLoginMode ? 'Sign In' : 'Sign Up'),
                ),
              ),

              const SizedBox(height: 20),

              // 4. TOGGLE MODE
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoginMode = !_isLoginMode;
                  });
                },
                child: RichText(
                  text: TextSpan(
                    text: _isLoginMode
                        ? "Don't have an account? "
                        : "Already have an account? ",
                    style: const TextStyle(color: AppTheme.textGrey),
                    children: [
                      TextSpan(
                        text: _isLoginMode ? 'Sign Up' : 'Log In',
                        style: const TextStyle(
                          color: AppTheme.neonGreen,
                          fontWeight: FontWeight.bold,
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
    );
  }
}