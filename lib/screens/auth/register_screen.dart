import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:technostrelka_2025/screens/auth/login_screen.dart';
import 'package:technostrelka_2025/theme/app_theme.dart';
import 'package:technostrelka_2025/widgets/mini_next_button.dart';
import 'package:technostrelka_2025/widgets/text_input.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mesh_gradient/mesh_gradient.dart';

import 'package:flutter_svg/flutter_svg.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              constraints: const BoxConstraints.expand(),
              child: AnimatedMeshGradient(
                colors: AppTheme.gradientColors,
                options: AnimatedMeshGradientOptions(speed: 0.05),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 10, left: 20),
                child: SvgPicture.asset('assets/logos/tlm_logo.svg'),
              )
            ),
            BuildRegisterScreen(),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: HaveAccount(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BuildRegisterScreen extends StatefulWidget {
  const BuildRegisterScreen({super.key});

  @override
  State<BuildRegisterScreen> createState() => _BuildRegisterScreenState();
}

class _BuildRegisterScreenState extends State<BuildRegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 48, right: 48, top: 60, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          RegistrationForm(),
        ],
      ),
    );
  }
}

class HaveAccount extends StatelessWidget {
  const HaveAccount({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Уже есть аккаунт?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
          ),
        ),
        GestureDetector(
          onTap: () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen())
            )
          },
          child: Text('Войти',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold
            ),
          ),
        )
      ],
    );
  }
}

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({
    super.key,
  });

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  File? _avatarImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _avatarImage = File(image.path);
      });
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));
        
        // Here you would normally send the registration data to your API
        // Example:
        // final response = await supabase.auth.signUp(
        //   email: _emailController.text,
        //   password: _passwordController.text,
        // );
        
        // Upload avatar if selected
        if (_avatarImage != null) {
          // Example:
          // final String path = 'avatars/${response.user!.id}';
          // await supabase.storage.from('avatars').upload(path, _avatarImage!);
          // final String avatarUrl = supabase.storage.from('avatars').getPublicUrl(path);
          
          // Update user profile with avatar URL
          // await supabase.from('profiles').upsert({
          //   'id': response.user!.id,
          //   'name': _nameController.text,
          //   'avatar_url': avatarUrl,
          // });
        }
        
        if (mounted) {
          // Navigate to the next screen after successful registration
          // Navigator.pushReplacementNamed(context, '/home');
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Регистрация успешна!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка: ${e.toString()}')),
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
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Form(
              key: _formKey,
              child: Column(
                spacing: 32,
                children: [
                  Text('Регистрация',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  Column(
                    spacing: 10,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: _avatarImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(64),
                              child: Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2)
                                ),
                                child: Image.file(
                                  _avatarImage!,
                                  width: 128,
                                  height: 128,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : AddPhoto(),
                      ),
                      Text('Добавить фото',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  Column(
                    spacing: 25,
                    children: [
                      SizedBox(
                        height: 30,
                        child: TextInput(
                          controller: _nameController,
                          placeholder: 'Имя', 
                          borderRadius: 24,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Пожалуйста, введите имя';
                            }
                            return null;
                          },
                        ) 
                      ),
                      SizedBox(
                        height: 30,
                        child: TextInput(
                          controller: _emailController,
                          placeholder: 'Email', 
                          borderRadius: 24,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Пожалуйста, введите email';
                            }
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Пожалуйста, введите корректный email';
                            }
                            return null;
                          },
                        )
                      ),
                      SizedBox(
                        height: 30,
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
                              return 'Пароль должен быть не менее 6 символов';
                            }
                            return null;
                          },
                        )
                      ),
                      SizedBox(
                        height: 30,
                        child: TextInput(
                          controller: _confirmPasswordController,
                          placeholder: 'Подтверждение пароля', 
                          borderRadius: 24,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Пожалуйста, подтвердите пароль';
                            }
                            if (value != _passwordController.text) {
                              return 'Пароли не совпадают';
                            }
                            return null;
                          },
                        )
                      ),
                      _isLoading 
                        ? SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : MiniNextButton(onPressed: _register)
                    ],
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

class AddPhoto extends StatelessWidget {
  const AddPhoto({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(64),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 64, sigmaY: 64),
        child: Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2)
          ),
          child: Icon(
            Icons.add_rounded,
            size: 100,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}