import 'package:flutter/material.dart';
import '../models/activity_item.dart';

class AppStateProvider extends ChangeNotifier {
  // Theme state
  ThemeMode _themeMode = ThemeMode.system;
  Color _primarySeedColor = Colors.indigo;

  // Student Profile state
  String _studentName = 'Maria Santos';
  String _studentId = '2026-IT-101';
  String _courseAndYear = 'BS Information Technology - Year 3';
  String _institution = 'College of Computer Studies';

  // Completed Activities tracker
  final Set<String> _completedActivities = {'lab1'};

  // Available Activities list for Master Compilation
  final List<ActivityItem> _activities = [
    const ActivityItem(
      id: 'lab1',
      activityNumber: 1,
      title: 'Grade & GPA Estimator',
      subtitle: 'Dynamic Course Units & Letter Grade Calculator',
      description:
          'Compute weighted GPA, determine academic status, adjust test scores dynamically with sliders, and review grade scales.',
      category: 'Computation',
      icon: Icons.calculate_outlined,
      route: '/activity1',
      badgeText: 'Active',
      isAvailable: true,
    ),
    const ActivityItem(
      id: 'lab2',
      activityNumber: 2,
      title: 'Lab Milestone Tracker',
      subtitle: 'Interactive Checklist & Experiment Milestones',
      description:
          'Track lab tasks, organize objectives by category (Pre-Lab, Hardware, Report), add custom checklist items, and monitor real-time completion rates.',
      category: 'Workflow',
      icon: Icons.checklist_rtl_rounded,
      route: '/activity2',
      badgeText: 'Active',
      isAvailable: true,
    ),
    const ActivityItem(
      id: 'lab3',
      activityNumber: 3,
      title: 'Active Network Monitor',
      subtitle: 'Real-time Stream Listener & Handover Resiliency',
      description:
          'Monitor Wi-Fi, Cellular, and offline states in real-time. Gracefully pause and queue in-flight requests during network handovers and auto-resume upon reconnection.',
      category: 'Networking',
      icon: Icons.network_check_rounded,
      route: '/network-monitor',
      badgeText: 'Active',
      isAvailable: true,
    ),
    const ActivityItem(
      id: 'lab4',
      activityNumber: 4,
      title: 'Capstone Project Hub',
      subtitle: 'Synthesis & Final Defense Repository',
      description:
          'Final laboratory module consolidating documentation, repository links, and evaluation rubrics.',
      category: 'Capstone',
      icon: Icons.workspace_premium_outlined,
      route: '/activity4',
      badgeText: 'Upcoming',
      isAvailable: false,
    ),
  ];

  // Accent color options
  static const List<Color> availableColors = [
    Colors.indigo,
    Colors.teal,
    Colors.deepPurple,
    Colors.blueGrey,
    Colors.deepOrange,
    Colors.green,
  ];

  // Getters
  ThemeMode get themeMode => _themeMode;
  Color get primarySeedColor => _primarySeedColor;
  String get studentName => _studentName;
  String get studentId => _studentId;
  String get courseAndYear => _courseAndYear;
  String get institution => _institution;
  List<ActivityItem> get activities => List.unmodifiable(_activities);
  int get completedActivitiesCount => _completedActivities.length;

  bool isActivityCompleted(String activityId) {
    return _completedActivities.contains(activityId);
  }

  // Setters & Actions
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    if (_primarySeedColor != color) {
      _primarySeedColor = color;
      notifyListeners();
    }
  }

  void updateProfile({
    required String name,
    required String studentId,
    required String course,
    String? institution,
  }) {
    _studentName = name.trim().isEmpty ? _studentName : name.trim();
    _studentId = studentId.trim().isEmpty ? _studentId : studentId.trim();
    _courseAndYear = course.trim().isEmpty ? _courseAndYear : course.trim();
    if (institution != null && institution.trim().isNotEmpty) {
      _institution = institution.trim();
    }
    notifyListeners();
  }

  void toggleActivityCompleted(String activityId) {
    if (_completedActivities.contains(activityId)) {
      _completedActivities.remove(activityId);
    } else {
      _completedActivities.add(activityId);
    }
    notifyListeners();
  }
}
