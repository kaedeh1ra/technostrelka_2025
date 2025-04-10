import 'package:flutter/material.dart';
import 'dart:math' as math;

class TetrisAnimation extends StatefulWidget {
  final VoidCallback onAnimationComplete;
  final int
  blockCount; // Количество блоков в фигуре (зависит от длительности задачи)
  final Color color; // Цвет фигуры (зависит от категории задачи)

  const TetrisAnimation({
    super.key,
    required this.onAnimationComplete,
    this.blockCount = 4, // По умолчанию 4 блока
    this.color = Colors.cyan, // По умолчанию голубой цвет
  });

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

  @override
  void initState() {
    super.initState();

    // Создаем фигуру на основе количества блоков
    _figure = _createFigureFromBlockCount(widget.blockCount, widget.color);

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

  // Создаем фигуру на основе количества блоков
  TetrisFigure _createFigureFromBlockCount(int blockCount, Color color) {
    // Если блоков меньше 4, используем стандартные фигуры
    if (blockCount <= 4) {
      final figures = [
        TetrisFigure.i(color: color),
        TetrisFigure.j(color: color),
        TetrisFigure.l(color: color),
        TetrisFigure.o(color: color),
        TetrisFigure.s(color: color),
        TetrisFigure.t(color: color),
        TetrisFigure.z(color: color),
      ];
      return figures[math.Random().nextInt(figures.length)];
    } else {
      return _createCustomFigure(blockCount, color);
    }
  }

  // Создаем кастомную фигуру на основе количества блоков
  TetrisFigure _createCustomFigure(int blockCount, Color color) {
    final gridSize = math.max(3, math.sqrt(blockCount).ceil());
    final shape = List.generate(gridSize, (_) => List.filled(gridSize, 0));
    // Заполняем сетку блоками
    int blocksPlaced = 0;
    int centerX = gridSize ~/ 2;
    int centerY = gridSize ~/ 2;

    // Сначала размещаем блок в центре
    shape[centerY][centerX] = 1;
    blocksPlaced++;

    // Затем размещаем остальные блоки спирально вокруг центра
    final directions = [
      [0, 1], // вправо
      [1, 0], // вниз
      [0, -1], // влево
      [-1, 0], // вверх
    ];

    int x = centerX;
    int y = centerY;
    int dirIndex = 0;
    int stepsInCurrentDir = 1;
    int stepsTaken = 0;
    int turnsCount = 0;

    while (blocksPlaced < blockCount && blocksPlaced < gridSize * gridSize) {
      final dir = directions[dirIndex];
      x += dir[0];
      y += dir[1];
      stepsTaken++;

      // Проверяем, что координаты в пределах сетки
      if (x >= 0 && x < gridSize && y >= 0 && y < gridSize) {
        shape[y][x] = 1;
        blocksPlaced++;
      }

      // Меняем направление, если нужно
      if (stepsTaken == stepsInCurrentDir) {
        dirIndex = (dirIndex + 1) % 4;
        stepsTaken = 0;
        turnsCount++;

        // Увеличиваем длину шага каждые два поворота
        if (turnsCount % 2 == 0) {
          stepsInCurrentDir++;
        }
      }
    }

    return TetrisFigure(shape: shape, color: color);
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
  factory TetrisFigure.i({Color color = Colors.cyan}) {
    return TetrisFigure(
      shape: [
        [0, 0, 0, 0],
        [1, 1, 1, 1],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      color: color,
    );
  }

  // J-фигура
  factory TetrisFigure.j({Color color = Colors.blue}) {
    return TetrisFigure(
      shape: [
        [1, 0, 0],
        [1, 1, 1],
        [0, 0, 0],
      ],
      color: color,
    );
  }

  // L-фигура
  factory TetrisFigure.l({Color color = Colors.orange}) {
    return TetrisFigure(
      shape: [
        [0, 0, 1],
        [1, 1, 1],
        [0, 0, 0],
      ],
      color: color,
    );
  }

  // O-фигура
  factory TetrisFigure.o({Color color = Colors.yellow}) {
    return TetrisFigure(
      shape: [
        [1, 1],
        [1, 1],
      ],
      color: color,
    );
  }

  // S-фигура
  factory TetrisFigure.s({Color color = Colors.green}) {
    return TetrisFigure(
      shape: [
        [0, 1, 1],
        [1, 1, 0],
        [0, 0, 0],
      ],
      color: color,
    );
  }

  // T-фигура
  factory TetrisFigure.t({Color color = Colors.purple}) {
    return TetrisFigure(
      shape: [
        [0, 1, 0],
        [1, 1, 1],
        [0, 0, 0],
      ],
      color: color,
    );
  }

  // Z-фигура
  factory TetrisFigure.z({Color color = Colors.red}) {
    return TetrisFigure(
      shape: [
        [1, 1, 0],
        [0, 1, 1],
        [0, 0, 0],
      ],
      color: color,
    );
  }
}
