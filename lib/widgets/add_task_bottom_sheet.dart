import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:technostrelka_2025/models/task.dart';
import 'package:technostrelka_2025/providers/task_provider.dart';
import 'package:uuid/uuid.dart';

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
  String _category = 'Учёба';
  bool _priority = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    );

    if (pickedTime != null) {
      setState(() {
        _startTime = DateTime(
          _startTime.year,
          _startTime.month,
          _startTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Если время окончания раньше времени начала, корректируем
        if (_endTime.isBefore(_startTime)) {
          _endTime = _startTime.add(const Duration(hours: 1));
        }
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime),
    );

    if (pickedTime != null) {
      final newEndTime = DateTime(
        _endTime.year,
        _endTime.month,
        _endTime.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      // Проверяем, что время окончания позже времени начала
      if (newEndTime.isAfter(_startTime)) {
        setState(() {
          _endTime = newEndTime;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Время окончания должно быть позже времени начала'),
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        // Обновляем дату, сохраняя время
        _startTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _startTime.hour,
          _startTime.minute,
        );

        _endTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _endTime.hour,
          _endTime.minute,
        );
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final firebaseService = ref.read(firebaseServiceProvider);

      // Создаем новую задачу
      final newTask = Task(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: _startTime,
        endTime: _endTime,
        category: _category,
        priority: _priority,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      // Сохраняем в Firebase
      firebaseService
          .addTask(newTask)
          .then((_) {
            Navigator.pop(context);
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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              const Center(
                child: Text(
                  'Добавить задачу',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              // Название задачи
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Название задачи',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название задачи';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Дата
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Дата',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_startTime.day}.${_startTime.month}.${_startTime.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Время начала и окончания
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectStartTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Начало',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectEndTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Окончание',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Описание
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Категория
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Категория',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Учёба', child: Text('Учёба')),
                  DropdownMenuItem(value: 'Работа', child: Text('Работа')),
                  DropdownMenuItem(value: 'Личное', child: Text('Личное')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Важность
              SwitchListTile(
                title: const Text('Важная задача'),
                value: _priority,
                onChanged: (value) {
                  setState(() {
                    _priority = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),

              // Кнопки
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveTask,
                    child: const Text('Сохранить'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
