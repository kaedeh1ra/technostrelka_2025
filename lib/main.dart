import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:technostrelka_2025/theme.dart';
import 'features/app/splash_screen/splash_screen.dart' show SplashScreen;
import 'features/user-auth/presentation/pages/home_page.dart' show HomePage;
import 'features/user-auth/presentation/pages/login_page.dart' show Loginpage;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Technostrelka_2025',
      theme: AppTheme.light(),
      darkTheme: AppTheme.light(),
      initialRoute: '/',
      routes: {
        '/login': (context) => Loginpage(),
        '/home': (context) => HomePage(),
      },
      home: const SplashScreen(child: Loginpage()),
    );
  }
}
