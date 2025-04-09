import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:technostrelka_2025/models/task.dart';
import 'package:technostrelka_2025/services/firebase_service.dart';

// Провайдер сервиса Firebase
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getUserTasks();
});

final tasksByDateProvider = Provider.family<List<Task>, DateTime>((ref, date) {
  final tasksAsyncValue = ref.watch(tasksStreamProvider);

  return tasksAsyncValue.when(
    data: (tasks) {
      return tasks.where((task) {
        final taskDate = DateTime(
          task.startTime.year,
          task.startTime.month,
          task.startTime.day,
        );
        final compareDate = DateTime(date.year, date.month, date.day);
        return taskDate.isAtSameMomentAs(compareDate);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final selectedWeekProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  return monday;
});

// Провайдер для выбранного месяца
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});
