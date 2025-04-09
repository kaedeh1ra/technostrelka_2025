import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:technostrelka_2025/screens/auth/login_screen.dart';
import 'package:technostrelka_2025/screens/auth/register_screen.dart';
import 'package:technostrelka_2025/screens/home_screen.dart';
import 'package:technostrelka_2025/screens/splash_screen.dart';
import 'package:technostrelka_2025/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Firebase
  await Firebase.initializeApp();

  runApp(const ProviderScope(child: TaskTetrisApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
  ],
);

class TaskTetrisApp extends StatelessWidget {
  const TaskTetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TaskTetris',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
