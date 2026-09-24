import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class CourseRecord {
  String id;
  String name;
  int units;
  double score; // 0 to 100

  CourseRecord({
    required this.id,
    required this.name,
    required this.units,
    required this.score,
  });

  double get gradePoint {
    if (score >= 90) return 4.0;
    if (score >= 80) return 3.0;
    if (score >= 70) return 2.0;
    if (score >= 60) return 1.0;
    return 0.0;
  }

  String get letterGrade {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }
}

class ActivityOneScreen extends StatefulWidget {
  const ActivityOneScreen({super.key});

  @override
  State<ActivityOneScreen> createState() => _ActivityOneScreenState();
}

class _ActivityOneScreenState extends State<ActivityOneScreen> {
  late List<CourseRecord> _courses;
  final _newCourseController = TextEditingController();
  int _selectedUnits = 3;

  @override
  void initState() {
    super.initState();
    _resetDefaults();
  }

  @override
  void dispose() {
    _newCourseController.dispose();
    super.dispose();
  }

  void _resetDefaults() {
    setState(() {
      _courses = [
        CourseRecord(
          id: '1',
          name: 'Mobile Application Development',
          units: 3,
          score: 92,
        ),
        CourseRecord(
          id: '2',
          name: 'Data Structures & Algorithms',
          units: 3,
          score: 87,
        ),
        CourseRecord(
          id: '3',
          name: 'Database Systems Laboratory',
          units: 2,
          score: 84,
        ),
        CourseRecord(
          id: '4',
          name: 'Computer Networks & Security',
          units: 3,
          score: 78,
        ),
      ];
    });
  }

  void _addNewCourse() {
    final name = _newCourseController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _courses.add(
        CourseRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          units: _selectedUnits,
          score: 85,
        ),
      );
      _newCourseController.clear();
      _selectedUnits = 3;
    });
    Navigator.of(context).pop();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Course Subject'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _newCourseController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Course Name',
                      hintText: 'e.g. Operating Systems',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Credit Units: '),
                      const Spacer(),
                      DropdownButton<int>(
                        value: _selectedUnits,
                        items: [1, 2, 3, 4, 5].map((u) {
                          return DropdownMenuItem<int>(
                            value: u,
                            child: Text('$u Units'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              _selectedUnits = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: _addNewCourse,
                  child: const Text('Add Course'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double get _calculatedGPA {
    final totalUnits = _courses.fold<int>(0, (sum, c) => sum + c.units);
    if (totalUnits == 0) return 0.0;
    final totalWeightedPoints =
        _courses.fold<double>(0.0, (sum, c) => sum + (c.gradePoint * c.units));
    return totalWeightedPoints / totalUnits;
  }

  int get _totalUnits => _courses.fold<int>(0, (sum, c) => sum + c.units);

  String get _standing {
    final gpa = _calculatedGPA;
    if (gpa >= 3.75) return "Dean's Honor List";
    if (gpa >= 3.0) return "Very Satisfactory";
    if (gpa >= 2.0) return "Satisfactory";
    return "Academic Warning";
  }

  Color _standingColor(BuildContext context) {
    final gpa = _calculatedGPA;
    if (gpa >= 3.75) return Colors.green;
    if (gpa >= 3.0) return Colors.blue;
    if (gpa >= 2.0) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppStateProvider>();
    final isCompleted = appState.isActivityCompleted('lab1');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 1: Grade & GPA Estimator'),
        actions: [
          IconButton(
            tooltip: 'Reset sample courses',
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
            onPressed: () => appState.toggleActivityCompleted('lab1'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Course'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          final summaryWidget = Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text(
                        'Estimated Cumulative GPA',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _standingColor(context).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _standingColor(context),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _standing,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _standingColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        _calculatedGPA.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        '/ 4.00 Scale',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Wrap(
                    spacing: 20,
                    runSpacing: 10,
                    children: [
                      _MetricBadge(
                        label: 'Total Courses',
                        value: '${_courses.length}',
                      ),
                      _MetricBadge(
                        label: 'Total Credit Units',
                        value: '$_totalUnits Units',
                      ),
                      _MetricBadge(
                        label: 'Student',
                        value: appState.studentName.split(' ').first,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );

          final courseListWidget = _courses.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No courses yet. Tap "Add Course" to get started.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: isWide,
                  physics: isWide
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
                  itemCount: _courses.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: theme
                                      .colorScheme.secondaryContainer,
                                  child: Text(
                                    course.letterGrade,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme
                                          .colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        course.name,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${course.units} Units • Grade Point: ${course.gradePoint.toStringAsFixed(1)}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 20,
                                  ),
                                  color: Colors.redAccent,
                                  onPressed: () {
                                    setState(() {
                                      _courses.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Score: ${course.score.round()}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Expanded(
                                  child: Slider(
                                    value: course.score,
                                    min: 50,
                                    max: 100,
                                    divisions: 50,
                                    label: '${course.score.round()}%',
                                    onChanged: (newScore) {
                                      setState(() {
                                        course.score = newScore;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                  Expanded(flex: 2, child: summaryWidget),
                  const SizedBox(width: 24),
                  Expanded(flex: 3, child: courseListWidget),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: summaryWidget,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: courseListWidget,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final String label;
  final String value;

  const _MetricBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}
