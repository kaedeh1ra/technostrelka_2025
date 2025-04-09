import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:technostrelka_2025/models/task.dart';
import 'package:technostrelka_2025/providers/task_provider.dart';
import 'package:technostrelka_2025/theme/app_theme.dart';
import 'package:technostrelka_2025/widgets/edit_task_bottom_sheet.dart';
import 'package:technostrelka_2025/widgets/pomodoro_dialog.dart';
import 'package:technostrelka_2025/widgets/tetris_animation.dart';

class TaskDetailBottomSheet extends ConsumerWidget {
  final Task task;

  const TaskDetailBottomSheet({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryColor = AppTheme.getCategoryColor(task.category);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок и кнопки
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditTaskBottomSheet(context, task),
                tooltip: 'Редактировать',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context, ref),
                tooltip: 'Удалить',
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Категория и приоритет
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: categoryColor),
                ),
                child: Text(
                  task.category,
                  style: TextStyle(
                    color: categoryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (task.priority)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red),
                  ),
                  child: const Text(
                    'Важно',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Время
          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 8),
              Text(
                '${_formatDateTime(task.startTime)} - ${_formatDateTime(task.endTime)}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Описание
          if (task.description.isNotEmpty) ...[
            const Text(
              'Описание:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(task.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
          ],

          // Кнопка "Выполнено"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _markAsCompleted(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: task.isCompleted ? Colors.grey : Colors.green,
              ),
              child: Text(
                task.isCompleted
                    ? 'Отменить выполнение'
                    : 'Отметить как выполненное',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),

          // Кнопка Pomodoro (только для важных задач)
          if (task.priority ||
              task.endTime.difference(task.startTime).inMinutes >= 30) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showPomodoroDialog(context);
                },
                icon: const Icon(Icons.timer),
                label: const Text('Запустить Pomodoro'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _markAsCompleted(BuildContext context, WidgetRef ref) {
    final firebaseService = ref.read(firebaseServiceProvider);
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);

    firebaseService
        .updateTask(updatedTask)
        .then((_) {
          Navigator.pop(context);

          // Если задача отмечена как выполненная, проверяем длительность
          if (updatedTask.isCompleted) {
            final durationInDays =
                updatedTask.endTime.difference(updatedTask.startTime).inDays;

            // Если задача длится 7 или более дней, вызываем neuroAnswer()
            if (durationInDays >= 7) {
              _neuroAnswer();
            } else {
              // Иначе показываем анимацию Tetris
              _showCompletionAnimation(context, updatedTask);
            }
          }
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка: $error'),
              backgroundColor: Colors.red,
            ),
          );
        });
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Удалить задачу'),
            content: const Text('Вы уверены, что хотите удалить эту задачу?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  final firebaseService = ref.read(firebaseServiceProvider);
                  firebaseService
                      .deleteTask(task.id)
                      .then((_) {
                        Navigator.pop(context); // Закрываем диалог
                        Navigator.pop(context); // Закрываем bottom sheet
                      })
                      .catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Ошибка: $error'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      });
                },
                child: const Text(
                  'Удалить',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showCompletionAnimation(BuildContext context, Task task) {
    // Рассчитываем количество блоков на основе длительности задачи
    final durationInHours = task.endTime.difference(task.startTime).inHours;
    final categoryColor = AppTheme.getCategoryColor(task.category);

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: TetrisAnimation(
              blockCount: durationInHours,
              color: categoryColor,
              onAnimationComplete: () {
                Navigator.of(context).pop();
              },
            ),
          ),
    );
  }

  void _neuroAnswer() {
    // TODO: Здесь будет реализация метода neuroAnswer()
  }

  void _showPomodoroDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const PomodoroDialog());
  }

  void _showEditTaskBottomSheet(BuildContext context, Task task) {
    Navigator.pop(context); // Закрываем текущий bottom sheet

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => EditTaskBottomSheet(task: task),
    );
  }
}
