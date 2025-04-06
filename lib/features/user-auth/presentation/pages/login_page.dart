import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technostrelka_2025/features/user-auth/presentation/pages/home_page.dart';
import 'package:technostrelka_2025/features/user-auth/presentation/pages/sign_up_page.dart';
import 'package:technostrelka_2025/features/user-auth/presentation/widgets/form_container_widget.dart';
import 'package:technostrelka_2025/global/commands/error_toast.dart';
import 'package:technostrelka_2025/global/commands/toast.dart';

import '../../firebase_auth_implement/firebase_auth_services.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  bool _isSignedIn = false;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Login',
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
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
                onTap: _signIn,
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue,
                  ),
                  child: Center(
                    child:
                        _isSignedIn
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // GestureDetector(
              //   onTap: _signInWithGoogle,
              //   child: Container(
              //     width: double.infinity,
              //     height: 45,
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(10),
              //       color: Colors.red,
              //     ),
              //     child: Center(
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Icon(FontAwesomeIcons.google, color: Colors.white),
              //           SizedBox(width: 5),
              //           Text(
              //             'Sign in with Google',
              //             style: TextStyle(
              //               color: Colors.white,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account? '),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Sign Up',
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

  void _signIn() async {
    setState(() {
      _isSignedIn = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;
    User? user = await _auth.signInWithEmailAndPassword(email, password);
    setState(() {
      _isSignedIn = false;
    });
    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      showToast(message: "You are logged in");
      Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
    } else {
      showErrorToast(message: "Something is wrong!");
    }
  }

  void _signInWithGoogle() async {
    GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );
        await _firebaseAuth.signInWithCredential(credential);
        Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
      }
    } catch (e) {}
  }
}
