import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:technostrelka_2025/theme.dart';
import 'features/app/splash_screen/splash_screen.dart' show SplashScreen;
import 'features/user-auth/presentation/pages/home_page.dart' show HomePage;
import 'features/user-auth/presentation/pages/login_page.dart' show Loginpage;
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

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
      home: FutureBuilder(
        // Используем FutureBuilder для задержки
        future: Future.delayed(Duration(seconds: 3)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen(); // Отображаем SplashScreen во время задержки
          } else {
            return isLoggedIn
                ? HomePage()
                : Loginpage(); // Перенаправляем после задержки
          }
        },
      ),
    );
  }
}
