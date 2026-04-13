import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import '../../shared/custom_button.dart';
import '../../shared/custom_text_field.dart';
import '../../core/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(name, email, password);

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/user_dashboard');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Sporty Blobs
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'CREAT \nACCOUNT',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 40,
                        height: 0.9,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'START YOUR ECO JOURNEY',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    CustomTextField(
                      label: 'Full Name',
                      hint: 'John Doe',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Email Address',
                      hint: 'john@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Password',
                      hint: '••••••••',
                      controller: _passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 40),
                    CustomButton(
                      text: 'CREATE ACCOUNT',
                      isLoading: authProvider.isLoading,
                      onPressed: _handleRegister,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? ', style: TextStyle(color: Colors.grey)),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'LOGIN',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
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
