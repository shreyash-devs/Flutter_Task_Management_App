import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_providers.dart';
import '../../data/models/task_model.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  final Task? task;
  const AddTaskScreen({Key? key, this.task}) : super(key: key);

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime? _selectedDate;
  late TimeOfDay? _selectedTime;
  late TaskPriority _priority;
  late bool _isCompleted;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.task != null;
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    if (widget.task?.dueDate != null) {
      _selectedDate = widget.task?.dueDate;
      _selectedTime = TimeOfDay.fromDateTime(widget.task!.dueDate);
    } else {
      _selectedDate = null;
      _selectedTime = null;
    }
    _priority = widget.task?.priority ?? TaskPriority.low;
    _isCompleted = widget.task?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Task' : 'Create new task',
          style: TextStyle(
            color: Colors.grey[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        actions:
            _isEditing
                ? [
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.grey[800]),
                    onPressed: () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text(
                                'Delete Task',
                                style: TextStyle(color: Colors.grey[900]),
                              ),
                              content: Text(
                                'Are you sure you want to delete this task?',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Color(0xFFFF3B30)),
                                  ),
                                ),
                              ],
                            ),
                      );

                      if (shouldDelete == true && mounted) {
                        await ref
                            .read(taskRepositoryProvider)
                            .deleteTask(widget.task!.id);
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Task deleted'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: const Color(0xFF2D62ED),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ]
                : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                  style: TextStyle(color: Colors.grey[900]),
                  decoration: InputDecoration(
                    labelText: 'Task name',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2D62ED)),
                    ),
                  ),
                validator:
                    (value) =>
                          value == null || value.isEmpty
                              ? 'Enter a title'
                              : null,
              ),
                const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                  style: TextStyle(color: Colors.grey[900]),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2D62ED)),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Text(
                  'Task Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
              ListTile(
                title: Text(
                          'Due Date',
                          style: TextStyle(color: Colors.grey[900]),
                        ),
                        subtitle: Text(
                          _selectedDate == null
                              ? 'Choose a date'
                              : _selectedDate!.toLocal().toString().split(
                                ' ',
                              )[0],
                          style: TextStyle(color: Colors.grey[600]),
                ),
                        trailing: Icon(
                          Icons.calendar_today,
                          color: const Color(0xFF2D62ED),
                        ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: const Color(0xFF2D62ED),
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: Colors.grey[900]!,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                  );
                          if (picked != null)
                            setState(() => _selectedDate = picked);
                },
              ),
                      const Divider(height: 1),
                      ListTile(
                        title: Text(
                          'Due Time',
                          style: TextStyle(color: Colors.grey[900]),
                        ),
                        subtitle: Text(
                          _selectedTime == null
                              ? 'Choose a time'
                              : _selectedTime!.format(context),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: Icon(
                          Icons.access_time,
                          color: const Color(0xFF2D62ED),
                        ),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime ?? TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: const Color(0xFF2D62ED),
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: Colors.grey[900]!,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null)
                            setState(() => _selectedTime = picked);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Priority',
                          style: TextStyle(color: Colors.grey[900]),
                        ),
                      ),
                      const Divider(height: 1),
                      ...TaskPriority.values.map(
                        (priority) => RadioListTile<TaskPriority>(
                          title: Text(
                            priority.name.toUpperCase(),
                            style: TextStyle(color: Colors.grey[900]),
                          ),
                          value: priority,
                          groupValue: _priority,
                          onChanged:
                              (value) => setState(() => _priority = value!),
                          activeColor: _getPriorityColor(priority),
                          secondary: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(
                                priority,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getPriorityIcon(priority),
                              size: 16,
                              color: _getPriorityColor(priority),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ),
              const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Mark as Completed',
                            style: TextStyle(
                              color: Colors.grey[900],
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Switch(
                          value: _isCompleted,
                          onChanged: (val) {
                            setState(() {
                              _isCompleted = val;
                            });
                          },
                          activeColor: Color(0xFF2166E3),
                          inactiveThumbColor: Colors.grey[300],
                          inactiveTrackColor: Colors.grey[200],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          _selectedDate != null &&
                          _selectedTime != null) {
                        final DateTime dueDate = DateTime(
                          _selectedDate!.year,
                          _selectedDate!.month,
                          _selectedDate!.day,
                          _selectedTime!.hour,
                          _selectedTime!.minute,
                        );

                    final task = Task(
                          id: widget.task?.id ?? '',
                      title: _titleController.text,
                      description: _descriptionController.text,
                          dueDate: dueDate,
                      priority: _priority,
                          isCompleted: _isCompleted,
                    );

                        if (_isEditing) {
                          await ref
                              .read(taskRepositoryProvider)
                              .updateTask(task);
                        } else {
                    await ref.read(addTaskUseCaseProvider).call(task);
                        }

                        if (mounted) {
                          Navigator.pop(context);
                        }
                      } else {
                        String message = '';
                        if (_selectedDate == null) {
                          message = 'Please select a due date';
                        } else if (_selectedTime == null) {
                          message = 'Please select a due time';
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF2D62ED),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                  }
                },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D62ED),
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(_isEditing ? 'Update Task' : 'Create Task'),
                  ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Icons.warning;
      case TaskPriority.medium:
        return Icons.info;
      case TaskPriority.low:
        return Icons.low_priority;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red[400]!;
      case TaskPriority.medium:
        return Colors.orange[400]!;
      case TaskPriority.low:
        return Colors.green[400]!;
    }
  }
}
