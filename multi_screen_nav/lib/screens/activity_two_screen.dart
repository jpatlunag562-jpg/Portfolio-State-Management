import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_item.dart';
import '../providers/app_state_provider.dart';

class ActivityTwoScreen extends StatefulWidget {
  const ActivityTwoScreen({super.key});

  @override
  State<ActivityTwoScreen> createState() => _ActivityTwoScreenState();
}

class _ActivityTwoScreenState extends State<ActivityTwoScreen> {
  late List<TaskItem> _tasks;
  String _selectedCategory = 'All';
  final _taskTitleController = TextEditingController();
  final _taskNoteController = TextEditingController();
  String _dialogCategory = 'Pre-Lab';

  final List<String> _categories = [
    'All',
    'Pre-Lab',
    'Hardware Setup',
    'Software & Code',
    'Documentation',
  ];

  @override
  void initState() {
    super.initState();
    _resetDefaults();
  }

  @override
  void dispose() {
    _taskTitleController.dispose();
    _taskNoteController.dispose();
    super.dispose();
  }

  void _resetDefaults() {
    setState(() {
      _tasks = [
        TaskItem(
          id: '1',
          title: 'Review Experiment Rubrics & Schema',
          category: 'Pre-Lab',
          isCompleted: true,
          note: 'Read Chapter 4 of the Laboratory Manual.',
        ),
        TaskItem(
          id: '2',
          title: 'Verify Flutter SDK & Android Toolchain',
          category: 'Pre-Lab',
          isCompleted: true,
          note: 'Run flutter doctor to confirm environment readiness.',
        ),
        TaskItem(
          id: '3',
          title: 'Configure Breadboard & Sensor Wiring',
          category: 'Hardware Setup',
          isCompleted: false,
          note: 'Check 3.3V and GND connections on pin header.',
        ),
        TaskItem(
          id: '4',
          title: 'Implement Multi-Screen Navigation Stack',
          category: 'Software & Code',
          isCompleted: true,
          note: 'Design Material routes and passing arguments.',
        ),
        TaskItem(
          id: '5',
          title: 'Integrate Provider Global State Store',
          category: 'Software & Code',
          isCompleted: true,
          note: 'Light/Dark mode and Student profile reactive listeners.',
        ),
        TaskItem(
          id: '6',
          title: 'Compile Activity Report & Screenshots',
          category: 'Documentation',
          isCompleted: false,
          note: 'Prepare PDF documentation with test walkthrough.',
        ),
      ];
    });
  }

  void _addNewTask() {
    final title = _taskTitleController.text.trim();
    if (title.isEmpty) return;

    setState(() {
      _tasks.add(
        TaskItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          category: _dialogCategory,
          isCompleted: false,
          note: _taskNoteController.text.trim(),
        ),
      );
      _taskTitleController.clear();
      _taskNoteController.clear();
      _dialogCategory = 'Pre-Lab';
    });
    Navigator.of(context).pop();
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Milestone Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _taskTitleController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        hintText: 'e.g. Conduct Unit Tests',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _taskNoteController,
                      decoration: const InputDecoration(
                        labelText: 'Notes / Description (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Category:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _dialogCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: _categories
                          .where((c) => c != 'All')
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            _dialogCategory = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: _addNewTask,
                  child: const Text('Add Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<TaskItem> get _filteredTasks {
    if (_selectedCategory == 'All') return _tasks;
    return _tasks.where((t) => t.category == _selectedCategory).toList();
  }

  double get _completionRatio {
    if (_tasks.isEmpty) return 0.0;
    final done = _tasks.where((t) => t.isCompleted).length;
    return done / _tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppStateProvider>();
    final isCompleted = appState.isActivityCompleted('lab2');
    final completedCount = _tasks.where((t) => t.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 2: Milestone Tracker'),
        actions: [
          IconButton(
            tooltip: 'Reset sample tasks',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _resetDefaults,
          ),
          IconButton(
            tooltip: isCompleted ? 'Completed' : 'Mark Completed',
            icon: Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.check_circle_outline_rounded,
              color: isCompleted ? Colors.green : null,
            ),
            onPressed: () => appState.toggleActivityCompleted('lab2'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('New Task'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          // Header summary with progress bar
          final progressWidget = Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Text(
                        'Experiment Completion Rate',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${(_completionRatio * 100).round()}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _completionRatio,
                      minHeight: 10,
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _completionRatio == 1.0
                            ? Colors.green
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        '$completedCount of ${_tasks.length} tasks completed',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        _completionRatio == 1.0
                            ? 'All Tasks Done!'
                            : '${_tasks.length - completedCount} tasks remaining',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _completionRatio == 1.0
                              ? Colors.green
                              : theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );

          // Category filter row
          final filterWidget = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          );

          // Task items list
          final taskListWidget = _filteredTasks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No tasks in this category.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: isWide,
                  physics: isWide
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
                  itemCount: _filteredTasks.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final task = _filteredTasks[index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: task.isCompleted
                              ? Colors.green.withValues(alpha: 0.3)
                              : Colors.transparent,
                        ),
                      ),
                      child: CheckboxListTile(
                        value: task.isCompleted,
                        onChanged: (val) {
                          setState(() {
                            task.isCompleted = val ?? false;
                          });
                        },
                        activeColor: Colors.green,
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: task.isCompleted
                                ? theme.disabledColor
                                : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                task.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            if (task.note.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                task.note,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                        secondary: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded),
                          color: Colors.redAccent,
                          tooltip: 'Delete task',
                          onPressed: () {
                            setState(() {
                              _tasks.remove(task);
                            });
                          },
                        ),
                      ),
                    );
                  },
                );

          if (isWide) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        progressWidget,
                        const SizedBox(height: 16),
                        filterWidget,
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(flex: 3, child: taskListWidget),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: progressWidget,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: filterWidget,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: taskListWidget,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
