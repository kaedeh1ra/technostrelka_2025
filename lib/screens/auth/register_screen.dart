import 'dart:io';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:technostrelka_2025/screens/auth/login_screen.dart';
import 'package:technostrelka_2025/theme/app_theme.dart';
import 'package:technostrelka_2025/widgets/mini_next_button.dart';
import 'package:technostrelka_2025/widgets/text_input.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:technostrelka_2025/screens/home_screen.dart'; // Импортируйте ваш HomeScreen

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
              ),
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
        Text(
          'Уже есть аккаунт?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
          ),
        ),
        GestureDetector(
          onTap: () => {
            context.go('/login')
          },
          child: Text(
            'Войти',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _avatarImage = File(image.path);
      });
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ).then((userCredential) async {
          String? localImagePath;

          if (_avatarImage != null) {

            final Directory appDir = await getApplicationDocumentsDirectory();
            final String imagePath = path.join(appDir.path, 'avatar_${userCredential.user!.uid}.jpg');
            final File localImage = await _avatarImage!.copy(imagePath);
            localImagePath = localImage.path;


            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('avatarPath', localImagePath);
          }

          await userCredential.user!.updateDisplayName(_nameController.text.trim());


          await _auth.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );


          context.go('/home');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Регистрация прошла успешно!')),
          );
        });
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Ошибка регистрации: ${e.message}';
        if (e.code == 'weak-password') {
          errorMessage = 'Пароль слишком слабый.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'Аккаунт с таким email уже существует.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Произошла ошибка: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.20),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Form(
              key: _formKey,
              child: Column(
                spacing: 32,
                children: [
                  Text(
                    'Регистрация',
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
                                border: Border.all(color: Colors.white, width: 2)),
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
                      Text(
                        'Добавить фото',
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

                        ),
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

                        ),
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

                        ),
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

                        ),
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
            border: Border.all(color: Colors.white, width: 2),
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