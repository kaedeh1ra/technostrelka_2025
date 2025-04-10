import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:technostrelka_2025/models/task.dart';
import 'package:technostrelka_2025/providers/task_provider.dart';

class EditTaskBottomSheet extends ConsumerStatefulWidget {
  final Task task;

  const EditTaskBottomSheet({super.key, required this.task});

  @override
  ConsumerState<EditTaskBottomSheet> createState() =>
      _EditTaskBottomSheetState();
}

class _EditTaskBottomSheetState extends ConsumerState<EditTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  late DateTime _startDate;
  late DateTime _endDate;
  late DateTime _startTime;
  late DateTime _endTime;
  late String _category;
  late bool _priority;
  late bool _isMultiDay;

  @override
  void initState() {
    super.initState();

    // Инициализируем контроллеры
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description,
    );

    // Инициализируем даты и время
    _startDate = DateTime(
      widget.task.startTime.year,
      widget.task.startTime.month,
      widget.task.startTime.day,
    );

    _endDate = DateTime(
      widget.task.endTime.year,
      widget.task.endTime.month,
      widget.task.endTime.day,
    );

    _startTime = widget.task.startTime;
    _endTime = widget.task.endTime;

    // Инициализируем категорию и приоритет
    _category = widget.task.category;
    _priority = widget.task.priority;

    // Определяем, является ли задача многодневной
    _isMultiDay = !_isSameDay(_startDate, _endDate);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

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
          _startDate.year,
          _startDate.month,
          _startDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Если время окончания раньше времени начала и это однодневная задача, корректируем
        if (!_isMultiDay && _endTime.isBefore(_startTime)) {
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
        _endDate.year,
        _endDate.month,
        _endDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      // Проверяем, что время окончания позже времени начала для однодневных задач
      if (_isMultiDay || newEndTime.isAfter(_startTime)) {
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

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        // Обновляем дату начала, сохраняя время
        _startDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
        );

        _startTime = DateTime(
          _startDate.year,
          _startDate.month,
          _startDate.day,
          _startTime.hour,
          _startTime.minute,
        );

        // Если дата окончания раньше даты начала, устанавливаем её равной дате начала
        if (_endDate.isBefore(_startDate)) {
          _endDate = DateTime(
            _startDate.year,
            _startDate.month,
            _startDate.day,
          );

          _endTime = DateTime(
            _endDate.year,
            _endDate.month,
            _endDate.day,
            _endTime.hour,
            _endTime.minute,
          );
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate, // Конечная дата не может быть раньше начальной
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        _endDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
        _endTime = DateTime(
          _endDate.year,
          _endDate.month,
          _endDate.day,
          _endTime.hour,
          _endTime.minute,
        );
      });
    }
  }

  void _toggleMultiDay(bool value) {
    setState(() {
      _isMultiDay = value;
      if (!_isMultiDay) {
        _endDate = DateTime(_startDate.year, _startDate.month, _startDate.day);

        _endTime = DateTime(
          _endDate.year,
          _endDate.month,
          _endDate.day,
          _endTime.hour,
          _endTime.minute,
        );
      }
    });
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final firebaseService = ref.read(firebaseServiceProvider);

      final startDateTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTime = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      if (endDateTime.isBefore(startDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Время окончания должно быть позже времени начала'),
          ),
        );
        return;
      }

      final updatedTask = widget.task.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: startDateTime,
        endTime: endDateTime,
        category: _category,
        priority: _priority,
      );

      firebaseService
          .updateTask(updatedTask)
          .then((_) {
            Navigator.pop(context);
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
              const Center(
                child: Text(
                  'Изменить задачу',
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

              // Переключатель многодневной задачи
              SwitchListTile(
                title: const Text('Многодневная задача'),
                value: _isMultiDay,
                onChanged: _toggleMultiDay,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),

              // Дата начала
              InkWell(
                onTap: () => _selectStartDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Дата начала',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_startDate.day}.${_startDate.month}.${_startDate.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isMultiDay) ...[
                InkWell(
                  onTap: () => _selectEndDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Дата окончания',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_endDate.day}.${_endDate.month}.${_endDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

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
