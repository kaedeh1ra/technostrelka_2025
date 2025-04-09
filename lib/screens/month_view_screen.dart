import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:technostrelka_2025/models/task.dart';
import 'package:technostrelka_2025/providers/task_provider.dart';
import 'package:technostrelka_2025/theme/app_theme.dart';
import 'package:technostrelka_2025/widgets/task_detail_bottom_sheet.dart';

class MonthViewScreen extends ConsumerWidget {
  const MonthViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final tasksAsyncValue = ref.watch(tasksStreamProvider);

    return Column(
      children: [
        _buildMonthSelector(context, ref, selectedMonth),
        Expanded(
          child: tasksAsyncValue.when(
            data: (tasks) => _buildCalendar(context, tasks, selectedMonth),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Ошибка: $error')),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedMonth,
  ) {
    final monthName = _getMonthName(selectedMonth.month);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final newMonth = DateTime(
                selectedMonth.year,
                selectedMonth.month - 1,
                1,
              );
              ref.read(selectedMonthProvider.notifier).state = newMonth;
            },
          ),
          TextButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedMonth,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                final newMonth = DateTime(picked.year, picked.month, 1);
                ref.read(selectedMonthProvider.notifier).state = newMonth;
              }
            },
            child: Text(
              '$monthName ${selectedMonth.year}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final newMonth = DateTime(
                selectedMonth.year,
                selectedMonth.month + 1,
                1,
              );
              ref.read(selectedMonthProvider.notifier).state = newMonth;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    List<Task> allTasks,
    DateTime month,
  ) {
    // Получаем количество дней в месяце
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // Получаем день недели первого дня месяца (0 - понедельник, 6 - воскресенье)
    final firstDayWeekday = DateTime(month.year, month.month, 1).weekday;

    // Корректируем, чтобы понедельник был 0
    final adjustedFirstDay = firstDayWeekday - 1;

    // Создаем сетку календаря
    final calendarDays = <Widget>[];

    // Добавляем заголовки дней недели
    final dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    for (var dayName in dayNames) {
      calendarDays.add(
        Container(
          height: 40,
          alignment: Alignment.center,
          child: Text(dayName, style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }

    // Добавляем пустые ячейки для дней до начала месяца
    for (var i = 0; i < adjustedFirstDay; i++) {
      calendarDays.add(
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
        ),
      );
    }

    // Добавляем дни месяца
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final tasksForDay = _getTasksForDay(allTasks, date);
      final isToday = _isToday(date);

      calendarDays.add(
        Container(
          decoration: BoxDecoration(
            color:
                isToday
                    ? Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.3)
                    : null,
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Номер дня
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  '$day',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              // Задачи на день
              Expanded(child: _buildTasksForDay(context, tasksForDay)),
            ],
          ),
        ),
      );
    }

    // Добавляем пустые ячейки в конце, чтобы заполнить сетку
    final totalCells = calendarDays.length;
    final remainingCells = 7 - (totalCells % 7);
    if (remainingCells < 7) {
      for (var i = 0; i < remainingCells; i++) {
        calendarDays.add(
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
          ),
        );
      }
    }

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 0.8,
      children: calendarDays,
    );
  }

  Widget _buildTasksForDay(BuildContext context, List<Task> tasks) {
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }

    // Показываем максимум 3 задачи, остальные - счетчиком
    final displayTasks = tasks.take(3).toList();
    final remainingTasks = tasks.length - displayTasks.length;

    return Column(
      children: [
        ...displayTasks.map((task) => _buildTaskItem(context, task)),
        if (remainingTasks > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              '+ ещё $remainingTasks',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    final categoryColor = AppTheme.getCategoryColor(task.category);

    return GestureDetector(
      onTap: () => _showTaskDetails(context, task),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: categoryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: categoryColor.withOpacity(0.5)),
        ),
        child: Text(
          task.title,
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  List<Task> _getTasksForDay(List<Task> allTasks, DateTime day) {
    return allTasks.where((task) {
      final taskDay = DateTime(
        task.startTime.year,
        task.startTime.month,
        task.startTime.day,
      );
      final compareDay = DateTime(day.year, day.month, day.day);
      return taskDay.isAtSameMomentAs(compareDay);
    }).toList();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ];
    return monthNames[month - 1];
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
