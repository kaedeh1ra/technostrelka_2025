import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:technostrelka_2025/providers/task_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();

    // Проверяем авторизацию и перенаправляем пользователя
    _checkAuth();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    // Имитация задержки для отображения сплеш-экрана
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final firebaseService = ref.read(firebaseServiceProvider);
    final user = firebaseService.currentUser;

    if (user != null) {
      context.go('/home');
    } else {
      context.go('/wellcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Анимированный логотип
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: const Icon(
                    Icons.grid_view,
                    size: 100,
                    color: Colors.deepPurple,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Название приложения
            const Text(
              'TaskTetris',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Подзаголовок
            const Text(
              'Управляйте задачами в стиле Tetris',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),

            // Индикатор загрузки
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
