import 'package:flutter/material.dart';
import 'dart:math' as math;

class TetrisAnimation extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const TetrisAnimation({super.key, required this.onAnimationComplete});

  @override
  State<TetrisAnimation> createState() => _TetrisAnimationState();
}

class _TetrisAnimationState extends State<TetrisAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fallAnimation;
  late Animation<double> _rotateAnimation;

  // Случайная фигура Tetris
  late TetrisFigure _figure;

  // Список возможных фигур
  final List<TetrisFigure> _figures = [
    TetrisFigure.i(),
    TetrisFigure.j(),
    TetrisFigure.l(),
    TetrisFigure.o(),
    TetrisFigure.s(),
    TetrisFigure.t(),
    TetrisFigure.z(),
  ];

  @override
  void initState() {
    super.initState();

    _figure = _figures[math.Random().nextInt(_figures.length)];

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fallAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _rotateAnimation = Tween<double>(begin: 0, end: math.pi / 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 400),
          painter: TetrisPainter(
            figure: _figure,
            fallProgress: _fallAnimation.value,
            rotateAngle: _rotateAnimation.value,
          ),
        );
      },
    );
  }
}

class TetrisPainter extends CustomPainter {
  final TetrisFigure figure;
  final double fallProgress;
  final double rotateAngle;

  TetrisPainter({
    required this.figure,
    required this.fallProgress,
    required this.rotateAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = figure.color
          ..style = PaintingStyle.fill;

    final blockSize = size.width / 10;

    // Центр фигуры
    final centerX = size.width / 2;
    final startY = -blockSize * 2;
    final endY = size.height - blockSize * figure.shape.length;

    // Текущая позиция Y
    final currentY = startY + (endY - startY) * fallProgress;

    // Сохраняем текущее состояние холста
    canvas.save();

    // Перемещаем холст в центр фигуры
    canvas.translate(centerX, currentY + blockSize * figure.shape.length / 2);

    // Поворачиваем холст
    canvas.rotate(rotateAngle);

    // Рисуем фигуру
    for (var y = 0; y < figure.shape.length; y++) {
      for (var x = 0; x < figure.shape[y].length; x++) {
        if (figure.shape[y][x] == 1) {
          final blockX = (x - figure.shape[y].length / 2) * blockSize;
          final blockY = (y - figure.shape.length / 2) * blockSize;

          canvas.drawRect(
            Rect.fromLTWH(blockX, blockY, blockSize, blockSize),
            paint,
          );

          // Рисуем границу блока
          canvas.drawRect(
            Rect.fromLTWH(blockX, blockY, blockSize, blockSize),
            Paint()
              ..color = figure.color.withOpacity(0.7)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
      }
    }

    // Восстанавливаем состояние холста
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TetrisPainter oldDelegate) {
    return oldDelegate.fallProgress != fallProgress ||
        oldDelegate.rotateAngle != rotateAngle ||
        oldDelegate.figure != figure;
  }
}

class TetrisFigure {
  final List<List<int>> shape;
  final Color color;

  TetrisFigure({required this.shape, required this.color});

  // I-фигура
  factory TetrisFigure.i() {
    return TetrisFigure(
      shape: [
        [0, 0, 0, 0],
        [1, 1, 1, 1],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      color: Colors.cyan,
    );
  }

  // J-фигура
  factory TetrisFigure.j() {
    return TetrisFigure(
      shape: [
        [1, 0, 0],
        [1, 1, 1],
        [0, 0, 0],
      ],
      color: Colors.blue,
    );
  }

  // L-фигура
  factory TetrisFigure.l() {
    return TetrisFigure(
      shape: [
        [0, 0, 1],
        [1, 1, 1],
        [0, 0, 0],
      ],
      color: Colors.orange,
    );
  }

  // O-фигура
  factory TetrisFigure.o() {
    return TetrisFigure(
      shape: [
        [1, 1],
        [1, 1],
      ],
      color: Colors.yellow,
    );
  }

  // S-фигура
  factory TetrisFigure.s() {
    return TetrisFigure(
      shape: [
        [0, 1, 1],
        [1, 1, 0],
        [0, 0, 0],
      ],
      color: Colors.green,
    );
  }

  // T-фигура
  factory TetrisFigure.t() {
    return TetrisFigure(
      shape: [
        [0, 1, 0],
        [1, 1, 1],
        [0, 0, 0],
      ],
      color: Colors.purple,
    );
  }

  // Z-фигура
  factory TetrisFigure.z() {
    return TetrisFigure(
      shape: [
        [1, 1, 0],
        [0, 1, 1],
        [0, 0, 0],
      ],
      color: Colors.red,
    );
  }
}
