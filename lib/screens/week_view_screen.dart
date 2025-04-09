import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:technostrelka_2025/models/task.dart';
import 'package:technostrelka_2025/providers/task_provider.dart';
import 'package:technostrelka_2025/theme/app_theme.dart';
import 'package:technostrelka_2025/widgets/task_card.dart';
import 'package:technostrelka_2025/widgets/task_detail_bottom_sheet.dart';
import 'package:technostrelka_2025/widgets/tetris_animation.dart';

class WeekViewScreen extends ConsumerWidget {
  const WeekViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedWeek = ref.watch(selectedWeekProvider);
    final tasksAsyncValue = ref.watch(tasksStreamProvider);

    return Column(
      children: [
        _buildWeekSelector(context, ref, selectedWeek),
        Expanded(
          child: tasksAsyncValue.when(
            data: (tasks) => _buildWeekGrid(context, tasks, selectedWeek),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Ошибка: $error')),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekSelector(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedWeek,
  ) {
    final mondayDate = selectedWeek.day;
    final sundayDate = selectedWeek.add(const Duration(days: 6)).day;
    final month = selectedWeek.month;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final newWeek = selectedWeek.subtract(const Duration(days: 7));
              ref.read(selectedWeekProvider.notifier).state = newWeek;
            },
          ),
          TextButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedWeek,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                // Получаем понедельник выбранной недели
                final monday = picked.subtract(
                  Duration(days: picked.weekday - 1),
                );
                ref.read(selectedWeekProvider.notifier).state = monday;
              }
            },
            child: Text(
              '$mondayDate-$sundayDate.$month',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final newWeek = selectedWeek.add(const Duration(days: 7));
              ref.read(selectedWeekProvider.notifier).state = newWeek;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekGrid(
    BuildContext context,
    List<Task> allTasks,
    DateTime weekStart,
  ) {
    // Дни недели
    final weekDays = List.generate(
      7,
      (index) => weekStart.add(Duration(days: index)),
    );

    // Часы с 8:00 до 20:00
    final hours = List.generate(13, (index) => index + 8);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          // Заголовок с днями недели
          _buildDaysHeader(context, weekDays),

          // Сетка часов и задач
          for (var hour in hours)
            _buildHourRow(context, hour, weekDays, allTasks),
        ],
      ),
    );
  }

  Widget _buildDaysHeader(BuildContext context, List<DateTime> weekDays) {
    final dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    return Row(
      children: [
        // Пустая ячейка для времени
        SizedBox(
          width: 60,
          height: 50,
          child: Center(
            child: Text('Время', style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
        // Дни недели
        ...List.generate(7, (index) {
          final day = weekDays[index];
          final isToday = _isToday(day);

          return Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color:
                    isToday
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                border: Border(
                  left: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayNames[index],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${day.day}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHourRow(
    BuildContext context,
    int hour,
    List<DateTime> weekDays,
    List<Task> allTasks,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Временная метка
        SizedBox(
          width: 60,
          height: 60,
          child: Center(
            child: Text(
              '$hour:00',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        // Ячейки для каждого дня
        ...List.generate(7, (dayIndex) {
          final day = weekDays[dayIndex];
          final tasksForDay = _getTasksForDayAndHour(allTasks, day, hour);

          return Expanded(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  for (var task in tasksForDay)
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: _buildTaskWidget(context, task),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTaskWidget(BuildContext context, Task task) {
    // Если задача выполнена, показываем фигуру Tetris
    if (task.isCompleted) {
      final categoryColor = AppTheme.getCategoryColor(task.category);
      final durationInHours = task.endTime.difference(task.startTime).inHours;

      return GestureDetector(
        onTap: () => _showTaskDetails(context, task),
        child: CustomPaint(
          painter: TetrisBlockPainter(
            color: categoryColor,
            blockCount: durationInHours,
          ),
        ),
      );
    } else {
      // Иначе показываем обычную карточку задачи
      return GestureDetector(
        onTap: () => _showTaskDetails(context, task),
        child: TaskCard(task: task, compact: true),
      );
    }
  }

  List<Task> _getTasksForDayAndHour(
    List<Task> allTasks,
    DateTime day,
    int hour,
  ) {
    return allTasks.where((task) {
      final taskStartDay = DateTime(
        task.startTime.year,
        task.startTime.month,
        task.startTime.day,
      );

      final taskEndDay = DateTime(
        task.endTime.year,
        task.endTime.month,
        task.endTime.day,
      );

      final compareDay = DateTime(day.year, day.month, day.day);

      final isDayInRange =
          compareDay.isAtSameMomentAs(taskStartDay) ||
          compareDay.isAtSameMomentAs(taskEndDay) ||
          (compareDay.isAfter(taskStartDay) && compareDay.isBefore(taskEndDay));

      if (!isDayInRange) {
        return false;
      }

      if (compareDay.isAtSameMomentAs(taskStartDay)) {
        return hour >= task.startTime.hour;
      } else if (compareDay.isAtSameMomentAs(taskEndDay)) {
        return hour <= task.endTime.hour;
      } else {
        return true;
      }
    }).toList();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => TaskDetailBottomSheet(task: task),
    );
  }
}

// Painter для отображения блоков Tetris для выполненных задач
class TetrisBlockPainter extends CustomPainter {
  final Color color;
  final int blockCount;

  TetrisBlockPainter({required this.color, required this.blockCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final borderPaint =
        Paint()
          ..color = color.withOpacity(0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    // Определяем размер блока
    final blockSize = size.height / 3;

    // Определяем количество блоков, которые можно разместить
    final maxBlocks = (size.width / blockSize).floor() * 3;
    final actualBlocks = math.min(blockCount, maxBlocks);

    // Размещаем блоки в виде фигуры Tetris
    int blocksPlaced = 0;

    // Создаем сетку 3x3 для размещения блоков
    final grid = List.generate(
      3,
      (_) => List.filled((size.width / blockSize).ceil(), 0),
    );

    // Заполняем сетку блоками
    for (int row = 0; row < 3 && blocksPlaced < actualBlocks; row++) {
      for (
        int col = 0;
        col < (size.width / blockSize).floor() && blocksPlaced < actualBlocks;
        col++
      ) {
        grid[row][col] = 1;
        blocksPlaced++;
      }
    }

    // Рисуем блоки
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < (size.width / blockSize).floor(); col++) {
        if (grid[row][col] == 1) {
          final rect = Rect.fromLTWH(
            col * blockSize,
            row * blockSize,
            blockSize,
            blockSize,
          );

          canvas.drawRect(rect, paint);
          canvas.drawRect(rect, borderPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant TetrisBlockPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.blockCount != blockCount;
  }
}
