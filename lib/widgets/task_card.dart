import 'package:flutter/material.dart';
import 'package:technostrelka_2025/models/task.dart';
import 'package:technostrelka_2025/theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool compact;

  const TaskCard({super.key, required this.task, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppTheme.getCategoryColor(task.category);

    return Card(
      margin: EdgeInsets.zero,
      elevation: task.priority ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side:
            task.priority
                ? BorderSide(color: Colors.red.shade300, width: 2)
                : BorderSide.none,
      ),
      color: categoryColor.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(compact ? 4.0 : 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок и категория
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                if (!compact) ...[
                  Text(
                    task.category,
                    style: TextStyle(
                      fontSize: 10,
                      color: categoryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (task.priority)
                    const Icon(
                      Icons.priority_high,
                      size: 12,
                      color: Colors.red,
                    ),
                ],
              ],
            ),

            // Название задачи
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: compact ? 10 : 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Время
            if (!compact || task.startTime.hour == task.endTime.hour)
              Text(
                '${_formatTime(task.startTime)} - ${_formatTime(task.endTime)}',
                style: TextStyle(
                  fontSize: compact ? 8 : 10,
                  color: Colors.grey[600],
                ),
              ),

            // Описание (только если не компактный режим и есть место)
            if (!compact && task.description.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    task.description,
                    style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
