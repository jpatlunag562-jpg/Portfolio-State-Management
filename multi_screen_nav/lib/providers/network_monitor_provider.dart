import 'dart:async';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../models/network_models.dart';

class NetworkMonitorProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Real-time Network Status
  NetworkStatusInfo _currentStatus = NetworkStatusInfo.initial();
  NetworkStatusInfo get currentStatus => _currentStatus;

  // Simulation Mode Controls
  bool _isSimulationMode = false;
  bool get isSimulationMode => _isSimulationMode;

  // Handover History & Stats
  final List<HandoverEvent> _handoverHistory = [];
  List<HandoverEvent> get handoverHistory => List.unmodifiable(_handoverHistory);

  int _totalHandoversDetected = 0;
  int get totalHandoversDetected => _totalHandoversDetected;

  // Request Queue
  final List<NetworkRequestItem> _requests = [];
  List<NetworkRequestItem> get requests => List.unmodifiable(_requests);

  // Active execution tokens to avoid duplicate chunk processing
  final Set<String> _activelyProcessingIds = {};
  bool _disposed = false;

  NetworkMonitorProvider({bool startInSimulation = false}) {
    _isSimulationMode = startInSimulation;
    if (!startInSimulation) {
      _initConnectivityListener();
    } else {
      _currentStatus = NetworkStatusInfo(
        type: NetworkInterfaceType.wifi,
        ipAddress: '192.168.1.100',
        networkName: 'Simulated Campus Wi-Fi',
        latencyMs: 15,
        isOnline: true,
        timestamp: DateTime.now(),
      );
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  /// Initialize real-time hardware network stream listener
  Future<void> _initConnectivityListener() async {
    try {
      final initialResults = await _connectivity.checkConnectivity();
      if (_disposed) return;
      _handleConnectivityResults(initialResults, isInitial: true);
    } catch (e) {
      if (_disposed) return;
      _currentStatus = NetworkStatusInfo(
        type: NetworkInterfaceType.none,
        ipAddress: '0.0.0.0',
        networkName: 'Detection Error',
        latencyMs: 0,
        isOnline: false,
        timestamp: DateTime.now(),
      );
      notifyListeners();
    }

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (!_isSimulationMode) {
          _handleConnectivityResults(results);
        }
      },
      onError: (error) {
        _logHandoverEvent(
          from: _currentStatus.type,
          to: NetworkInterfaceType.none,
          description: 'Network Stream Listener Error: $error',
        );
      },
    );
  }

  /// Map connectivity_plus results into domain state and detect handovers
  void _handleConnectivityResults(
    List<ConnectivityResult> results, {
    bool isInitial = false,
  }) {
    final prevType = _currentStatus.type;
    NetworkInterfaceType newType = NetworkInterfaceType.none;
    String ip = '0.0.0.0';
    String name = 'Disconnected';
    int latency = 0;

    if (results.contains(ConnectivityResult.wifi)) {
      newType = NetworkInterfaceType.wifi;
      ip = '192.168.1.${100 + Random().nextInt(50)}';
      name = 'Wi-Fi (802.11ax / 5GHz)';
      latency = 12 + Random().nextInt(15);
    } else if (results.contains(ConnectivityResult.mobile)) {
      newType = NetworkInterfaceType.cellular;
      ip = '100.64.${Random().nextInt(254)}.${10 + Random().nextInt(200)}';
      name = 'Cellular (5G NR / LTE-A)';
      latency = 38 + Random().nextInt(25);
    } else if (results.contains(ConnectivityResult.ethernet)) {
      newType = NetworkInterfaceType.ethernet;
      ip = '10.0.0.${20 + Random().nextInt(80)}';
      name = 'Gigabit Ethernet (eth0)';
      latency = 4 + Random().nextInt(6);
    } else if (results.contains(ConnectivityResult.other)) {
      newType = NetworkInterfaceType.other;
      ip = '172.16.0.${Random().nextInt(200)}';
      name = 'Active VPN / Tethering';
      latency = 45 + Random().nextInt(30);
    } else {
      newType = NetworkInterfaceType.none;
      ip = '0.0.0.0';
      name = 'Offline / No Signal';
      latency = 0;
    }

    final isOnline = newType != NetworkInterfaceType.none;
    _currentStatus = NetworkStatusInfo(
      type: newType,
      ipAddress: ip,
      networkName: name,
      latencyMs: latency,
      isOnline: isOnline,
      timestamp: DateTime.now(),
    );

    if (!isInitial && prevType != newType) {
      _totalHandoversDetected++;
      final isDrop = !isOnline;
      final isRecovery = prevType == NetworkInterfaceType.none && isOnline;

      String desc;
      if (isDrop) {
        desc = 'Connection lost from ${prevType.displayName}. Active requests queued.';
      } else if (isRecovery) {
        desc = 'Network re-established on ${newType.displayName} ($ip). Draining queue...';
      } else {
        desc = 'Seamless Handover: ${prevType.displayName} -> ${newType.displayName} (New IP: $ip).';
      }

      _logHandoverEvent(
        from: prevType,
        to: newType,
        description: desc,
        wasInFlightRequestPaused: isDrop,
      );

      if (isDrop) {
        _pauseAllInFlightRequests(reason: 'Network interface dropped');
      } else {
        // Auto-resume queued requests on recovery or handover!
        _resumeAllQueuedRequests();
      }
    }

    notifyListeners();
  }

  /// Toggle simulation mode
  void setSimulationMode(bool enabled) {
    if (_isSimulationMode == enabled) return;
    _isSimulationMode = enabled;

    if (!enabled) {
      // Re-read live hardware connection
      _connectivity.checkConnectivity().then((results) {
        _handleConnectivityResults(results);
      });
    }

    _logHandoverEvent(
      from: _currentStatus.type,
      to: _currentStatus.type,
      description: enabled
          ? 'Switched to Simulation Mode. Hardware stream detached.'
          : 'Re-attached to Live Device Hardware Network Stream.',
    );
    notifyListeners();
  }

  /// Manual simulation triggers
  void simulateInterface(NetworkInterfaceType targetType) {
    if (!_isSimulationMode) {
      _isSimulationMode = true;
    }

    final prevType = _currentStatus.type;
    String ip;
    String name;
    int latency;

    switch (targetType) {
      case NetworkInterfaceType.wifi:
        ip = '192.168.1.${101 + Random().nextInt(50)}';
        name = 'Simulated Campus Wi-Fi (WLAN0)';
        latency = 14 + Random().nextInt(10);
        break;
      case NetworkInterfaceType.cellular:
        ip = '100.64.42.${15 + Random().nextInt(80)}';
        name = 'Simulated Mobile 5G (Carrier Handover)';
        latency = 42 + Random().nextInt(20);
        break;
      case NetworkInterfaceType.ethernet:
        ip = '10.0.1.55';
        name = 'Simulated Lab LAN Ethernet';
        latency = 5;
        break;
      case NetworkInterfaceType.none:
        ip = '0.0.0.0';
        name = 'Simulated Signal Loss (Offline)';
        latency = 0;
        break;
      case NetworkInterfaceType.other:
        ip = '172.20.10.4';
        name = 'Simulated Hotspot / VPN';
        latency = 55;
        break;
    }

    final isOnline = targetType != NetworkInterfaceType.none;
    _currentStatus = NetworkStatusInfo(
      type: targetType,
      ipAddress: ip,
      networkName: name,
      latencyMs: latency,
      isOnline: isOnline,
      timestamp: DateTime.now(),
    );

    if (prevType != targetType) {
      _totalHandoversDetected++;
      final isDrop = !isOnline;
      final isRecovery = prevType == NetworkInterfaceType.none && isOnline;

      String desc;
      if (isDrop) {
        desc = 'Simulated Disconnect: Dropped from ${prevType.displayName}. Pausing in-flight requests.';
      } else if (isRecovery) {
        desc = 'Simulated Recovery: Re-connected via ${targetType.displayName} ($ip). Resuming queued requests.';
      } else {
        desc = 'Simulated Handover: ${prevType.displayName} -> ${targetType.displayName} (IP migration: $ip).';
      }

      _logHandoverEvent(
        from: prevType,
        to: targetType,
        description: desc,
        wasInFlightRequestPaused: isDrop,
      );

      if (isDrop) {
        _pauseAllInFlightRequests(reason: 'Simulated network drop');
      } else {
        _resumeAllQueuedRequests();
      }
    }

    notifyListeners();
  }

  /// Simulate a rapid handover between Wi-Fi and Cellular
  void simulateQuickHandover() {
    final nextType = _currentStatus.type == NetworkInterfaceType.wifi
        ? NetworkInterfaceType.cellular
        : NetworkInterfaceType.wifi;
    simulateInterface(nextType);
  }

  /// Internal logger for handover transitions
  void _logHandoverEvent({
    required NetworkInterfaceType from,
    required NetworkInterfaceType to,
    required String description,
    bool wasInFlightRequestPaused = false,
  }) {
    _handoverHistory.insert(
      0,
      HandoverEvent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        fromType: from,
        toType: to,
        description: description,
        timestamp: DateTime.now(),
        wasInFlightRequestPaused: wasInFlightRequestPaused,
      ),
    );

    // Keep last 50 events
    if (_handoverHistory.length > 50) {
      _handoverHistory.removeLast();
    }
  }

  // ============================================================
  // Request Queuing & Graceful Recovery System
  // ============================================================

  /// Dispatch a new continuous / chunked request
  NetworkRequestItem enqueueRequest({
    required String title,
    required int totalChunks,
    required int totalSizeBytes,
    bool autoStart = true,
  }) {
    final request = NetworkRequestItem(
      id: 'REQ-${DateTime.now().millisecondsSinceEpoch % 100000}',
      title: title,
      totalChunks: totalChunks,
      totalSizeBytes: totalSizeBytes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: RequestStatus.idle,
    );

    _requests.insert(0, request);
    notifyListeners();

    if (autoStart) {
      if (_currentStatus.isOnline) {
        _processRequestChunks(request);
      } else {
        // Enqueued directly into paused state if offline!
        request.status = RequestStatus.queuedPaused;
        request.lastError = 'Queued: Network is offline';
        _logHandoverEvent(
          from: _currentStatus.type,
          to: _currentStatus.type,
          description: 'Request [${request.id}] queued immediately (Device offline).',
          wasInFlightRequestPaused: true,
        );
        notifyListeners();
      }
    }

    return request;
  }

  /// Dispatch a realistic batch of sample requests
  void enqueueSampleBatch() {
    enqueueRequest(
      title: 'Lab Telemetry Chunks (Sensors Alpha)',
      totalChunks: 25,
      totalSizeBytes: 512 * 1024, // 512 KB
    );
    enqueueRequest(
      title: 'Geospatial Satellite Imagery Data',
      totalChunks: 50,
      totalSizeBytes: 2 * 1024 * 1024, // 2 MB
    );
    enqueueRequest(
      title: 'Real-time Video Feed Sync Matrix',
      totalChunks: 35,
      totalSizeBytes: 1200 * 1024, // 1.2 MB
    );
  }

  /// Core chunk processing loop with error interception and queueing
  Future<void> _processRequestChunks(NetworkRequestItem request) async {
    if (_activelyProcessingIds.contains(request.id)) {
      return;
    }
    _activelyProcessingIds.add(request.id);

    request.status = request.retryCount > 0
        ? RequestStatus.retrying
        : RequestStatus.inProgress;
    request.lastError = null;
    request.updatedAt = DateTime.now();
    notifyListeners();

    try {
      while (request.completedChunks < request.totalChunks) {
        if (_disposed) {
          _activelyProcessingIds.remove(request.id);
          return;
        }

        // Intercept network drop or offline state
        if (!_currentStatus.isOnline) {
          request.status = RequestStatus.queuedPaused;
          request.lastError = 'Connection dropped. Paused at chunk ${request.completedChunks}/${request.totalChunks}.';
          request.updatedAt = DateTime.now();
          notifyListeners();
          _activelyProcessingIds.remove(request.id);
          return;
        }

        // Intercept cancellation or user pause
        if (request.status == RequestStatus.cancelled ||
            request.status == RequestStatus.queuedPaused) {
          _activelyProcessingIds.remove(request.id);
          return;
        }

        // Simulate network transmission chunk delay (adaptive to latency)
        final delayMs = 120 + (_currentStatus.latencyMs ~/ 2);
        await Future.delayed(Duration(milliseconds: delayMs));

        // Verify connection state again right after delay (catch sudden IP handover/drop)
        if (!_currentStatus.isOnline) {
          request.status = RequestStatus.queuedPaused;
          request.lastError = 'Network handover drop during chunk transmission';
          request.updatedAt = DateTime.now();
          notifyListeners();
          _activelyProcessingIds.remove(request.id);
          return;
        }

        request.completedChunks++;
        request.updatedAt = DateTime.now();
        notifyListeners();
      }

      // Completed successfully
      request.status = RequestStatus.completed;
      request.updatedAt = DateTime.now();
      _logHandoverEvent(
        from: _currentStatus.type,
        to: _currentStatus.type,
        description: 'Request [${request.id}] completed (${request.totalChunks}/${request.totalChunks} chunks transmitted).',
      );
      notifyListeners();
    } catch (e) {
      // Gracefully catch any communication exceptions and queue request
      request.status = RequestStatus.queuedPaused;
      request.lastError = 'Handled network exception: $e';
      request.updatedAt = DateTime.now();
      notifyListeners();
    } finally {
      _activelyProcessingIds.remove(request.id);
    }
  }

  /// Pause all active requests when network drops
  void _pauseAllInFlightRequests({required String reason}) {
    int pausedCount = 0;
    for (final req in _requests) {
      if (req.isInFlight) {
        req.status = RequestStatus.queuedPaused;
        req.lastError = reason;
        req.updatedAt = DateTime.now();
        pausedCount++;
      }
    }
    if (pausedCount > 0) {
      _logHandoverEvent(
        from: _currentStatus.type,
        to: _currentStatus.type,
        description: 'Auto-Queued $pausedCount in-flight requests to prevent data loss.',
        wasInFlightRequestPaused: true,
      );
    }
    notifyListeners();
  }

  /// Resume all queued/paused requests upon stable reconnection
  void _resumeAllQueuedRequests() {
    if (!_currentStatus.isOnline) return;

    final queued = _requests.where((r) => r.isQueued || r.status == RequestStatus.idle).toList();
    if (queued.isEmpty) return;

    _logHandoverEvent(
      from: _currentStatus.type,
      to: _currentStatus.type,
      description: 'Graceful Recovery: Resuming ${queued.length} queued request(s) on ${_currentStatus.type.displayName}.',
    );

    for (final req in queued) {
      req.retryCount++;
      _processRequestChunks(req);
    }
  }

  /// Resume single request manually
  void retryRequest(String id) {
    final req = _requests.firstWhere((r) => r.id == id);
    if (!req.isDone && _currentStatus.isOnline) {
      req.retryCount++;
      _processRequestChunks(req);
    }
  }

  /// Pause single request manually
  void pauseRequest(String id) {
    final req = _requests.firstWhere((r) => r.id == id);
    if (req.isInFlight) {
      req.status = RequestStatus.queuedPaused;
      req.lastError = 'User paused';
      req.updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  /// Cancel single request
  void cancelRequest(String id) {
    final req = _requests.firstWhere((r) => r.id == id);
    req.status = RequestStatus.cancelled;
    req.lastError = 'Cancelled by user';
    req.updatedAt = DateTime.now();
    notifyListeners();
  }

  /// Clear completed or cancelled requests
  void clearFinishedRequests() {
    _requests.removeWhere((r) => r.isDone);
    notifyListeners();
  }

  /// Clear handover history
  void clearHandoverHistory() {
    _handoverHistory.clear();
    _totalHandoversDetected = 0;
    notifyListeners();
  }

  int get inFlightRequestsCount =>
      _requests.where((r) => r.isInFlight).length;

  int get queuedRequestsCount =>
      _requests.where((r) => r.isQueued).length;

  int get completedRequestsCount =>
      _requests.where((r) => r.status == RequestStatus.completed).length;

  @override
  void dispose() {
    _disposed = true;
    _connectivitySubscription?.cancel();
    for (final req in _requests) {
      if (req.isInFlight) {
        req.status = RequestStatus.cancelled;
      }
    }
    _activelyProcessingIds.clear();
    super.dispose();
  }
}
