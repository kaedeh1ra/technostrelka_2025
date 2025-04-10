import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:technostrelka_2025/models/task.dart';
import 'package:technostrelka_2025/providers/task_provider.dart';
import 'package:technostrelka_2025/theme/app_theme.dart';
import 'package:technostrelka_2025/widgets/task_card.dart';
import 'package:technostrelka_2025/widgets/task_detail_bottom_sheet.dart';

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

    final weekDays = List.generate(
      7,
      (index) => weekStart.add(Duration(days: index)),
    );


    final hours = List.generate(24, (index) => index);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [

          _buildDaysHeader(context, weekDays),


          for (var hour in hours)
            _buildHourRow(context, hour, weekDays, allTasks),
        ],
      ),
    );
  }

  Widget _buildDaysHeader(BuildContext context, List<DateTime> weekDays) {
    final dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    return Row(
      children: [ // Пустая ячейка для времени
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
                        padding: const EdgeInsets.all(1.0),
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
    return GestureDetector(
      onTap: () => _showTaskDetails(context, task),
      child: TaskCard(task: task, compact: true),
    );
  }
}

List<Task> _getTasksForDayAndHour(List<Task> allTasks, DateTime day, int hour) {
  return allTasks.where((task) {
    final taskDay = DateTime(
      task.startTime.year,
      task.startTime.month,
      task.startTime.day,
    );

    final compareDay = DateTime(day.year, day.month, day.day);


    if (!taskDay.isAtSameMomentAs(compareDay)) {
      return false;
    }


    return task.startTime.hour == hour ||
        (task.startTime.hour < hour && task.endTime.hour > hour);
  }).toList();
}

bool _isToday(DateTime date) =>
    date.year == DateTime.now().year &&
    date.month == DateTime.now().month &&
    date.day == DateTime.now().day;

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
