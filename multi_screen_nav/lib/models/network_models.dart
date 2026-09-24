import 'package:flutter/material.dart';

/// Supported network interfaces
enum NetworkInterfaceType {
  wifi,
  cellular,
  ethernet,
  none,
  other;

  String get displayName {
    switch (this) {
      case NetworkInterfaceType.wifi:
        return 'Wi-Fi';
      case NetworkInterfaceType.cellular:
        return 'Cellular';
      case NetworkInterfaceType.ethernet:
        return 'Ethernet';
      case NetworkInterfaceType.none:
        return 'Offline';
      case NetworkInterfaceType.other:
        return 'Other Network';
    }
  }

  IconData get icon {
    switch (this) {
      case NetworkInterfaceType.wifi:
        return Icons.wifi_rounded;
      case NetworkInterfaceType.cellular:
        return Icons.signal_cellular_alt_rounded;
      case NetworkInterfaceType.ethernet:
        return Icons.settings_ethernet_rounded;
      case NetworkInterfaceType.none:
        return Icons.wifi_off_rounded;
      case NetworkInterfaceType.other:
        return Icons.device_hub_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NetworkInterfaceType.wifi:
        return const Color(0xFF0288D1); // Light Blue
      case NetworkInterfaceType.cellular:
        return const Color(0xFF2E7D32); // Deep Green
      case NetworkInterfaceType.ethernet:
        return const Color(0xFF6A1B9A); // Purple
      case NetworkInterfaceType.none:
        return const Color(0xFFC62828); // Red
      case NetworkInterfaceType.other:
        return const Color(0xFFEF6C00); // Orange
    }
  }
}

/// Detailed snapshot of the current network state
class NetworkStatusInfo {
  final NetworkInterfaceType type;
  final String ipAddress;
  final String networkName;
  final int latencyMs;
  final bool isOnline;
  final DateTime timestamp;

  const NetworkStatusInfo({
    required this.type,
    required this.ipAddress,
    required this.networkName,
    required this.latencyMs,
    required this.isOnline,
    required this.timestamp,
  });

  factory NetworkStatusInfo.initial() {
    return NetworkStatusInfo(
      type: NetworkInterfaceType.none,
      ipAddress: '0.0.0.0',
      networkName: 'Detecting connection...',
      latencyMs: 0,
      isOnline: false,
      timestamp: DateTime.now(),
    );
  }

  NetworkStatusInfo copyWith({
    NetworkInterfaceType? type,
    String? ipAddress,
    String? networkName,
    int? latencyMs,
    bool? isOnline,
    DateTime? timestamp,
  }) {
    return NetworkStatusInfo(
      type: type ?? this.type,
      ipAddress: ipAddress ?? this.ipAddress,
      networkName: networkName ?? this.networkName,
      latencyMs: latencyMs ?? this.latencyMs,
      isOnline: isOnline ?? this.isOnline,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Log of network state transitions and handovers
class HandoverEvent {
  final String id;
  final NetworkInterfaceType fromType;
  final NetworkInterfaceType toType;
  final String description;
  final DateTime timestamp;
  final bool wasInFlightRequestPaused;

  const HandoverEvent({
    required this.id,
    required this.fromType,
    required this.toType,
    required this.description,
    required this.timestamp,
    this.wasInFlightRequestPaused = false,
  });
}

/// Lifecycle status for a queued network request
enum RequestStatus {
  idle,
  inProgress,
  queuedPaused,
  retrying,
  completed,
  failed,
  cancelled;

  String get label {
    switch (this) {
      case RequestStatus.idle:
        return 'Pending';
      case RequestStatus.inProgress:
        return 'In Flight';
      case RequestStatus.queuedPaused:
        return 'Queued (Paused)';
      case RequestStatus.retrying:
        return 'Auto Retrying';
      case RequestStatus.completed:
        return 'Completed';
      case RequestStatus.failed:
        return 'Failed';
      case RequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case RequestStatus.idle:
        return Colors.grey;
      case RequestStatus.inProgress:
        return Colors.blue;
      case RequestStatus.queuedPaused:
        return Colors.amber.shade800;
      case RequestStatus.retrying:
        return Colors.deepPurple;
      case RequestStatus.completed:
        return Colors.green;
      case RequestStatus.failed:
        return Colors.red;
      case RequestStatus.cancelled:
        return Colors.blueGrey;
    }
  }

  IconData get icon {
    switch (this) {
      case RequestStatus.idle:
        return Icons.hourglass_empty_rounded;
      case RequestStatus.inProgress:
        return Icons.sync_rounded;
      case RequestStatus.queuedPaused:
        return Icons.pause_circle_outline_rounded;
      case RequestStatus.retrying:
        return Icons.replay_rounded;
      case RequestStatus.completed:
        return Icons.check_circle_outline_rounded;
      case RequestStatus.failed:
        return Icons.error_outline_rounded;
      case RequestStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}

/// Represents a continuous or chunked network payload request
class NetworkRequestItem {
  final String id;
  final String title;
  final int totalChunks;
  int completedChunks;
  RequestStatus status;
  final int totalSizeBytes;
  int retryCount;
  String? lastError;
  final DateTime createdAt;
  DateTime updatedAt;

  NetworkRequestItem({
    required this.id,
    required this.title,
    required this.totalChunks,
    this.completedChunks = 0,
    this.status = RequestStatus.idle,
    required this.totalSizeBytes,
    this.retryCount = 0,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progress =>
      totalChunks > 0 ? (completedChunks / totalChunks).clamp(0.0, 1.0) : 0.0;

  bool get isDone =>
      status == RequestStatus.completed ||
      status == RequestStatus.failed ||
      status == RequestStatus.cancelled;

  bool get isInFlight =>
      status == RequestStatus.inProgress || status == RequestStatus.retrying;

  bool get isQueued => status == RequestStatus.queuedPaused;

  NetworkRequestItem copy() {
    return NetworkRequestItem(
      id: id,
      title: title,
      totalChunks: totalChunks,
      completedChunks: completedChunks,
      status: status,
      totalSizeBytes: totalSizeBytes,
      retryCount: retryCount,
      lastError: lastError,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
