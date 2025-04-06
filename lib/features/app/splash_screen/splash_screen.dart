import 'package:flutter/material.dart';
import 'package:technostrelka_2025/features/user-auth/presentation/pages/login_page.dart';

class SplashScreen extends StatelessWidget {
  // SplashScreen теперь StatelessWidget
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Welcome to this shit!',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ),
    );
  }
}
