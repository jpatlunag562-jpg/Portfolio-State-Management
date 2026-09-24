import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:multi_screen_nav/models/network_models.dart';
import 'package:multi_screen_nav/providers/network_monitor_provider.dart';
import 'package:multi_screen_nav/screens/network_monitor_screen.dart';

void main() {
  group('NetworkMonitorProvider Unit Tests', () {
    test('Initial simulation switch to Wi-Fi updates status', () {
      final provider = NetworkMonitorProvider(startInSimulation: true);
      provider.simulateInterface(NetworkInterfaceType.wifi);

      expect(provider.currentStatus.type, NetworkInterfaceType.wifi);
      expect(provider.currentStatus.isOnline, isTrue);
      expect(provider.currentStatus.ipAddress.startsWith('192.168.1.'), isTrue);
      provider.dispose();
    });

    test('Handover from Wi-Fi to Cellular records transition and updates IP', () {
      final provider = NetworkMonitorProvider(startInSimulation: true);
      provider.simulateInterface(NetworkInterfaceType.wifi);
      final initialHandovers = provider.totalHandoversDetected;

      provider.simulateInterface(NetworkInterfaceType.cellular);

      expect(provider.currentStatus.type, NetworkInterfaceType.cellular);
      expect(provider.currentStatus.isOnline, isTrue);
      expect(provider.currentStatus.ipAddress.startsWith('100.64.'), isTrue);
      expect(provider.totalHandoversDetected, initialHandovers + 1);
      expect(provider.handoverHistory.first.fromType, NetworkInterfaceType.wifi);
      expect(provider.handoverHistory.first.toType, NetworkInterfaceType.cellular);
      provider.dispose();
    });

    test('Network drop pauses in-flight requests into Queued state without crashing', () {
      final provider = NetworkMonitorProvider(startInSimulation: true);
      provider.simulateInterface(NetworkInterfaceType.wifi);

      final req = provider.enqueueRequest(
        title: 'Mission Critical Satellite Feed',
        totalChunks: 50,
        totalSizeBytes: 1024 * 1024,
      );

      expect(req.status, anyOf(RequestStatus.inProgress, RequestStatus.retrying));

      // Simulate sudden network drop
      provider.simulateInterface(NetworkInterfaceType.none);

      expect(provider.currentStatus.type, NetworkInterfaceType.none);
      expect(provider.currentStatus.isOnline, isFalse);
      expect(req.status, RequestStatus.queuedPaused);
      expect(req.isQueued, isTrue);
      expect(provider.queuedRequestsCount, greaterThanOrEqualTo(1));
      provider.dispose();
    });

    test('Graceful Recovery: Re-establishing Wi-Fi automatically resumes queued requests', () {
      final provider = NetworkMonitorProvider(startInSimulation: true);
      // Start offline
      provider.simulateInterface(NetworkInterfaceType.none);

      final req = provider.enqueueRequest(
        title: 'Telemetry Chunks',
        totalChunks: 10,
        totalSizeBytes: 200 * 1024,
      );

      expect(req.status, RequestStatus.queuedPaused);

      // Reconnect to Cellular
      provider.simulateInterface(NetworkInterfaceType.cellular);

      expect(provider.currentStatus.isOnline, isTrue);
      expect(req.status, anyOf(RequestStatus.inProgress, RequestStatus.retrying, RequestStatus.completed));
      expect(req.retryCount, greaterThanOrEqualTo(1));
      provider.dispose();
    });

    test('Quick Handover alternates between Wi-Fi and Cellular', () {
      final provider = NetworkMonitorProvider(startInSimulation: true);
      provider.simulateInterface(NetworkInterfaceType.wifi);
      provider.simulateQuickHandover();
      expect(provider.currentStatus.type, NetworkInterfaceType.cellular);

      provider.simulateQuickHandover();
      expect(provider.currentStatus.type, NetworkInterfaceType.wifi);
      provider.dispose();
    });

    test('User can cancel and clear finished requests', () {
      final provider = NetworkMonitorProvider(startInSimulation: true);
      final req = provider.enqueueRequest(
        title: 'Cancelable Request',
        totalChunks: 20,
        totalSizeBytes: 100 * 1024,
      );

      provider.cancelRequest(req.id);
      expect(req.status, RequestStatus.cancelled);
      expect(req.isDone, isTrue);

      provider.clearFinishedRequests();
      expect(provider.requests.any((r) => r.id == req.id), isFalse);
      provider.dispose();
    });
  });

  group('NetworkMonitorScreen Widget Tests', () {
    testWidgets('Renders all main dashboard sections and controls', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final provider = NetworkMonitorProvider(startInSimulation: true);
      provider.simulateInterface(NetworkInterfaceType.wifi);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const NetworkMonitorScreen(),
          ),
        ),
      );
      await tester.pump();

      // Check header and banners
      expect(find.text('Network Monitor & Handover'), findsOneWidget);
      expect(find.text('WI-FI'), findsOneWidget);
      expect(find.text('ONLINE'), findsOneWidget);
      expect(find.text('Assigned IP'), findsOneWidget);

      // Check controls & cards
      expect(find.text('Handover & Testing Console'), findsOneWidget);
      expect(find.text('Continuous Request Dispatcher'), findsOneWidget);
      expect(find.text('Request Queue & Resiliency'), findsOneWidget);
      expect(find.text('Handover & State Log'), findsOneWidget);

      provider.dispose();
    });

    testWidgets('Tapping interface buttons updates UI in real-time', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final provider = NetworkMonitorProvider(startInSimulation: true);
      provider.simulateInterface(NetworkInterfaceType.wifi);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const NetworkMonitorScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('WI-FI'), findsOneWidget);

      // Tap Cellular button
      await tester.tap(find.text('Cellular 5G'));
      await tester.pump();

      expect(find.text('CELLULAR'), findsOneWidget);

      // Tap Drop Connection (Offline)
      await tester.tap(find.text('Drop Connection (Offline)'));
      await tester.pump();

      expect(find.text('OFFLINE'), findsAtLeast(1));

      provider.dispose();
    });

    testWidgets('Dispatching request displays progress in queue section', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final provider = NetworkMonitorProvider(startInSimulation: true);
      provider.simulateInterface(NetworkInterfaceType.wifi);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const NetworkMonitorScreen(),
          ),
        ),
      );
      await tester.pump();

      final fetchFinder = find.text('Fetch Telemetry (30 chunks)');
      await tester.ensureVisible(fetchFinder);
      await tester.tap(fetchFinder);
      await tester.pump();

      expect(find.text('Telemetry Stream (Lab Activity 3)'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      provider.dispose();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('Renders cleanly on narrow mobile viewport (360x640) without any overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final provider = NetworkMonitorProvider(startInSimulation: true);
      provider.simulateInterface(NetworkInterfaceType.wifi);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const NetworkMonitorScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('WI-FI'), findsOneWidget);
      expect(find.text('ONLINE'), findsOneWidget);
      expect(find.text('Assigned IP'), findsOneWidget);

      provider.dispose();
    });
  });
}
