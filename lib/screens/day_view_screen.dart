import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:technostrelka_2025/models/task.dart';
import 'package:technostrelka_2025/providers/task_provider.dart';
import 'package:technostrelka_2025/widgets/task_card.dart';
import 'package:technostrelka_2025/widgets/task_detail_bottom_sheet.dart';

class DayViewScreen extends ConsumerWidget {
  const DayViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final tasks = ref.watch(tasksByDateProvider(selectedDate));

    return Column(
      children: [
        _buildDateSelector(context, ref, selectedDate),
        Expanded(child: _buildTimelineView(context, tasks)),
      ],
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final newDate = selectedDate.subtract(const Duration(days: 1));
              ref.read(selectedDateProvider.notifier).state = newDate;
            },
          ),
          TextButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                ref.read(selectedDateProvider.notifier).state = picked;
              }
            },
            child: Text(
              '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final newDate = selectedDate.add(const Duration(days: 1));
              ref.read(selectedDateProvider.notifier).state = newDate;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineView(BuildContext context, List<Task> tasks) {
    // Часы с 0:00 до 23:00
    final hours = List.generate(24, (index) => index);

    return ListView.builder(
      itemCount: hours.length,
      itemBuilder: (context, index) {
        final hour = hours[index];
        final hourTasks =
            tasks
                .where(
                  (task) =>
                      task.startTime.hour == hour ||
                      (task.startTime.hour < hour && task.endTime.hour > hour),
                )
                .toList();

        return _buildHourRow(context, hour, hourTasks);
      },
    );
  }

  Widget _buildHourRow(BuildContext context, int hour, List<Task> tasks) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Временная метка
        SizedBox(
          width: 60,
          height: 80,
          child: Center(
            child: Text(
              '$hour:00',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        // Контейнер для задач
        Expanded(
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
              ),
            ),
            child: Stack(
              children: [
                for (var task in tasks) _buildTaskItem(context, task, hour),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task, int hour) {
    // Расчет позиции и размера задачи
    final startHour = task.startTime.hour;
    final startMinute = task.startTime.minute;
    final endHour = task.endTime.hour;
    final endMinute = task.endTime.minute;

    // Если задача начинается в этот час
    if (startHour == hour) {
      // Высота задачи в зависимости от длительности
      final durationInMinutes =
          (endHour - startHour) * 60 + (endMinute - startMinute);
      final heightPercentage = durationInMinutes / 60.0;
      final height = 80.0 * heightPercentage;

      // Позиция по вертикали в зависимости от минут
      final topOffset = (startMinute / 60.0) * 0.0;

      return Positioned(
        top: topOffset,
        left: 0,
        right: 0,
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: GestureDetector(
            onTap: () {
              _showTaskDetails(context, task);
            },
            child: TaskCard(task: task),
          ),
        ),
      );
    }

    // Если задача продолжается в этот час
    if (startHour < hour && endHour > hour) {
      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: 80,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: GestureDetector(
            onTap: () {
              _showTaskDetails(context, task);
            },
            child: TaskCard(task: task),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
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
