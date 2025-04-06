import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technostrelka_2025/features/user-auth/presentation/widgets/form_container_widget.dart';
import 'package:technostrelka_2025/global/commands/error_toast.dart';
import 'package:technostrelka_2025/global/commands/toast.dart';
import '../../firebase_auth_implement/firebase_auth_services.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isSignedUp = false;
  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sign Up',
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              FormContainerWidget(
                controller: _usernameController,
                hintText: 'Username',
                isPasswordField: false,
              ),
              const SizedBox(height: 10),
              FormContainerWidget(
                controller: _emailController,
                hintText: 'Email',
                isPasswordField: false,
              ),
              const SizedBox(height: 10),
              FormContainerWidget(
                controller: _passwordController,
                hintText: 'Password',
                isPasswordField: true,
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: _signUp,
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue,
                  ),
                  child: Center(
                    child:
                        _isSignedUp
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              'Signup',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        "/login",
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    setState(() {
      _isSignedUp = true;
    });

    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    setState(() {
      _isSignedUp = false;
    });

    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      showToast(message: 'Registration is complete');
      Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
    } else {
      showErrorToast(message: "Failed to create user");
    }
  }
}
