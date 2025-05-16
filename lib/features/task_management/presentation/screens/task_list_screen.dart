import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../providers/task_providers.dart';
import 'add_task_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../auth/presentation/screens/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  int _selectedIndex = 0;
  bool? _isCompletedFilter;
  TaskPriority? _priorityFilter;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onAddTaskTap() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddTaskScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final taskRepository = ref.watch(taskRepositoryProvider);
    final isDarkMode = false; // Force light theme

    Widget _getScreen(int index) {
      if (index == 2) return const ProfileScreen();
      // Only index 0 is the task list, index 1 is unused (add button)
      return _buildMainTaskList(context);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _getScreen(_selectedIndex)),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.home_rounded,
                color:
                    _selectedIndex == 0
                        ? const Color(0xFF2D62ED)
                        : Colors.grey[400],
                size: 28,
              ),
              onPressed: () => setState(() => _selectedIndex = 0),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFF2D62ED),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x4D2D62ED),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 32),
                onPressed: _onAddTaskTap,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.person_outline_rounded,
                color:
                    _selectedIndex == 2
                        ? const Color(0xFF2D62ED)
                        : Colors.grey[400],
                size: 28,
              ),
              onPressed: () => setState(() => _selectedIndex = 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTaskList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My tasks',
                style: GoogleFonts.montserrat(
                  color: const Color(0xFF1E1E1E),
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -1,
                ),
              ),
              Builder(
                builder: (context) {
                  final user = FirebaseAuth.instance.currentUser;
                  return Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                    ),
                    child:
                        user?.photoURL != null
                            ? ClipOval(
                              child: Image.network(
                                user!.photoURL!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Icon(
                                      Icons.person,
                                      color: Colors.grey[400],
                                      size: 32,
                                    ),
                              ),
                            )
                            : Icon(
                              Icons.person,
                              color: Colors.grey[400],
                              size: 32,
                            ),
                  );
                },
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                child: Text(
                  _getMonthYear(_focusedDay),
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1E1E1E),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.week,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerVisible: false,
                daysOfWeekHeight: 20,
                rowHeight: 45,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  defaultDecoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  weekendDecoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendTextStyle: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  outsideTextStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  todayDecoration: BoxDecoration(
                    color: const Color(0xFF2D62ED).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: const Color(0xFF2D62ED),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                    color: Color(0xFF2D62ED),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  cellMargin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  cellPadding: const EdgeInsets.symmetric(vertical: 6),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  weekendStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              _buildFilterChip(
                label:
                    _isCompletedFilter == null
                        ? 'Status'
                        : _isCompletedFilter!
                        ? 'Completed'
                        : 'Active',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder:
                        (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: Text(
                                'All',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                              onTap: () {
                                setState(() => _isCompletedFilter = null);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: Text(
                                'Active',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                              onTap: () {
                                setState(() => _isCompletedFilter = false);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: Text(
                                'Completed',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                              onTap: () {
                                setState(() => _isCompletedFilter = true);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                  );
                },
              ),
              const SizedBox(width: 10),
              _buildFilterChip(
                label:
                    _priorityFilter == null
                        ? 'Priority'
                        : _priorityFilter!.name.toUpperCase(),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder:
                        (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: Text(
                                'All',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                              onTap: () {
                                setState(() => _priorityFilter = null);
                                Navigator.pop(context);
                              },
                            ),
                            ...TaskPriority.values.map(
                              (priority) => ListTile(
                                title: Text(
                                  priority.name.toUpperCase(),
                                  style: TextStyle(color: Colors.grey[800]),
                                ),
                                leading: Icon(
                                  _getPriorityIcon(priority),
                                  color: _getPriorityColor(priority),
                                ),
                                onTap: () {
                                  setState(() => _priorityFilter = priority);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(child: _buildTaskList(ref.read(taskRepositoryProvider))),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune, color: Colors.grey[600], size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey[800], fontSize: 14),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(TaskRepository taskRepository) {
    return StreamBuilder<List<Task>>(
      stream: taskRepository.getTasksStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Colors.grey[800]),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2D62ED)),
          );
        }

        final allTasks = snapshot.data ?? [];
        final tasks =
            allTasks.where((task) {
                final dateMatches = isSameDay(task.dueDate, _selectedDay);
                final statusMatches =
                    _isCompletedFilter == null ||
                    task.isCompleted == _isCompletedFilter;
                final priorityMatches =
                    _priorityFilter == null || task.priority == _priorityFilter;
                return dateMatches && statusMatches && priorityMatches;
              }).toList()
              ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No tasks found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildTaskCard(task),
            );
          },
        );
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    final taskRepository = ref.read(taskRepositoryProvider);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildPriorityBadge(task.priority),
                    const SizedBox(width: 8),
                    if (task.isCompleted) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2166E3).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Completed',
                          style: TextStyle(
                            color: Color(0xFF2166E3),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2166E3).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: const Color(0xFF2166E3),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(task.dueDate),
                            style: const TextStyle(
                              color: Color(0xFF2166E3),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Transform.rotate(
                      angle: -0.5,
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  task.title,
                  style: TextStyle(
                    color: Colors.grey[900],
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    task.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final updatedTask = Task(
                          id: task.id,
                          title: task.title,
                          description: task.description,
                          dueDate: task.dueDate,
                          priority: task.priority,
                          isCompleted: !task.isCompleted,
                        );
                        await taskRepository.updateTask(updatedTask);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              task.isCompleted
                                  ? const Color(0xFFD7C9F0).withOpacity(0.2)
                                  : const Color(0xFF2166E3).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              task.isCompleted ? Icons.undo : Icons.check,
                              size: 14,
                              color:
                                  task.isCompleted
                                      ? const Color(0xFF6E6E6E)
                                      : const Color(0xFF2166E3),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.isCompleted
                                  ? 'Mark as Active'
                                  : 'Mark as Completed',
                              style: TextStyle(
                                color:
                                    task.isCompleted
                                        ? const Color(0xFF6E6E6E)
                                        : const Color(0xFF2166E3),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTaskScreen(task: task),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(TaskPriority priority) {
    Color color;
    String text;
    switch (priority) {
      case TaskPriority.low:
        color = const Color(0xFF34C759);
        text = 'Low';
        break;
      case TaskPriority.medium:
        color = const Color(0xFFFF9500);
        text = 'Medium';
        break;
      case TaskPriority.high:
        color = const Color(0xFFFF3B30);
        text = 'High';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour > 12 ? hour - 12 : hour;
    return '$formattedHour:$minute $period';
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
        return const Color(0xFFFF3B30);
      case TaskPriority.medium:
        return const Color(0xFFFF9500);
      case TaskPriority.low:
        return const Color(0xFF34C759);
    }
  }

  String _getMonthYear(DateTime date) {
    return "${_monthName(date.month)} ${date.year}";
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
