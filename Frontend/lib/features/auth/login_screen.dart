import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import '../../shared/custom_button.dart';
import '../../shared/custom_text_field.dart';
import '../../core/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(email, password);

    if (success && mounted) {
      if (authProvider.isAdmin) {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/user_dashboard');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // Sporty dynamic background
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Symbol (Sporty Flutter-like icon)
                    Transform.rotate(
                      angle: -0.2,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          size: 40,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'ECO \nREWARD',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 56,
                        height: 0.9,
                        letterSpacing: -3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'FASTEST WAY TO SAVE NATURE',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 56),

                    CustomTextField(
                      label: 'EMAIL',
                      hint: 'your@email.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'PASSWORD',
                      hint: '••••••••',
                      controller: _passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 48),
                    CustomButton(
                      text: 'LOGIN NOW',
                      isLoading: authProvider.isLoading,
                      onPressed: _handleLogin,
                    ),
                    
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("DON'T HAVE AN ACCOUNT? ", style: TextStyle(color: Colors.white30, fontSize: 12, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text(
                            'REGISTER',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
