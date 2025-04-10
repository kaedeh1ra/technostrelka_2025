import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:technostrelka_2025/providers/task_provider.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:technostrelka_2025/theme/app_theme.dart';

import 'package:technostrelka_2025/widgets/text_input.dart';
import 'package:technostrelka_2025/widgets/mini_next_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final firebaseService = ref.read(firebaseServiceProvider);
        await firebaseService.loginWithEmail(
          _emailController.text,
          _passwordController.text,
        );

        if (mounted) {
          context.go('/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка входа: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              constraints: const BoxConstraints.expand(),
              child: AnimatedMeshGradient(
                colors: AppTheme.gradientColors,
                options: AnimatedMeshGradientOptions(speed: 0.05),
              ),
            ),
            
            // Logo at top left
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, left: 20),
                child: SvgPicture.asset('assets/logos/tlm_logo.svg'),
              )
            ),
            
            // Login form
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    // Glassmorphism login form
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.20),
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Вход',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  
                                  // Email field using TextInput component
                                  SizedBox(
                                    height: 50,
                                    child: TextInput(
                                      controller: _emailController,
                                      placeholder: 'Email',
                                      borderRadius: 24,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Пожалуйста, введите email';
                                        }
                                        if (!value.contains('@')) {
                                          return 'Пожалуйста, введите корректный email';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  
                                  // Password field using TextInput component
                                  SizedBox(
                                    height: 50,
                                    child: TextInput(
                                      controller: _passwordController,
                                      placeholder: 'Пароль',
                                      borderRadius: 24,
                                      obscureText: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Пожалуйста, введите пароль';
                                        }
                                        if (value.length < 6) {
                                          return 'Пароль должен содержать не менее 6 символов';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  
                                  // Login button using MiniNextButton
                                  _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : MiniNextButton(onPressed: _login),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // No account text at bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Ещё нет аккаунта?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: const Text(
                        'Регистрация',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
