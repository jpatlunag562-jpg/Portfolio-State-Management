import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:multi_screen_nav/main.dart';
import 'package:multi_screen_nav/providers/app_state_provider.dart';

void main() {
  testWidgets('Dashboard renders student banner, stats, and activity cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppStateProvider(),
        child: const LabCompilationApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Dashboard AppBar and Banner
    expect(find.text('Lab Compilation Hub'), findsOneWidget);
    expect(find.text('Welcome back,'), findsOneWidget);
    expect(find.text('Maria Santos'), findsOneWidget);

    // Verify Activity Cards exist
    expect(find.text('Grade & GPA Estimator'), findsOneWidget);
    expect(find.text('Lab Milestone Tracker'), findsOneWidget);
    expect(find.text('Active Network Monitor'), findsOneWidget);
  });

  testWidgets('Navigation to Lab 3 Network Monitor screen works correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppStateProvider(),
        child: const LabCompilationApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Scroll until Lab 3 is visible and tap
    final lab3Finder = find.text('Active Network Monitor');
    expect(lab3Finder, findsOneWidget);
    await tester.ensureVisible(lab3Finder);
    await tester.pumpAndSettle();
    await tester.tap(lab3Finder);
    await tester.pumpAndSettle();

    // Verify Lab 3 elements
    expect(find.text('Network Monitor & Handover'), findsOneWidget);
    expect(find.text('Handover & Testing Console'), findsOneWidget);
    expect(find.text('Request Queue & Resiliency'), findsOneWidget);

    // Pop back to home
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Lab Compilation Hub'), findsOneWidget);
  });

  testWidgets('Navigation to Lab 1 screen and back works correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppStateProvider(),
        child: const LabCompilationApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on Open Activity for Lab 1
    final lab1Finder = find.text('Grade & GPA Estimator');
    expect(lab1Finder, findsOneWidget);
    await tester.tap(lab1Finder);
    await tester.pumpAndSettle();

    // Verify we are on Lab 1 screen
    expect(find.text('Lab 1: Grade & GPA Estimator'), findsOneWidget);
    expect(find.text('Estimated Cumulative GPA'), findsOneWidget);

    // Pop back to home
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Lab Compilation Hub'), findsOneWidget);
  });

  testWidgets('Navigation to Lab 2 screen works correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppStateProvider(),
        child: const LabCompilationApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on Lab 2
    final lab2Finder = find.text('Lab Milestone Tracker');
    expect(lab2Finder, findsOneWidget);
    await tester.tap(lab2Finder);
    await tester.pumpAndSettle();

    // Verify Lab 2 elements
    expect(find.text('Lab 2: Milestone Tracker'), findsOneWidget);
    expect(find.text('Experiment Completion Rate'), findsOneWidget);

    // Pop back to home
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Lab Compilation Hub'), findsOneWidget);
  });

  testWidgets('Global State: Settings screen updates student name and theme',
      (WidgetTester tester) async {
    final stateProvider = AppStateProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: stateProvider,
        child: const LabCompilationApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to Settings
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    expect(find.text('App Settings & Profile'), findsOneWidget);
    expect(find.text('Select Theme Mode'), findsOneWidget);

    // Tap Dark mode segment
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(stateProvider.themeMode, ThemeMode.dark);

    // Update name in text field
    final nameField = find.widgetWithText(TextFormField, 'Maria Santos');
    await tester.enterText(nameField, 'Juan Dela Cruz');
    await tester.pumpAndSettle();

    // Tap Save Profile Updates
    final saveButton = find.text('Save Profile Updates');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(stateProvider.studentName, 'Juan Dela Cruz');

    // Return to Home Dashboard and verify live update
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Juan Dela Cruz'), findsOneWidget);
  });
}
