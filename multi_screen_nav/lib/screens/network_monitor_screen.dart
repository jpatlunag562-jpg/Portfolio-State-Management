import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/network_models.dart';
import '../providers/network_monitor_provider.dart';

class NetworkMonitorScreen extends StatefulWidget {
  const NetworkMonitorScreen({super.key});

  @override
  State<NetworkMonitorScreen> createState() => _NetworkMonitorScreenState();
}

class _NetworkMonitorScreenState extends State<NetworkMonitorScreen> {
  double _customChunkCount = 40;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final netProvider = context.watch<NetworkMonitorProvider>();
    final currentStatus = netProvider.currentStatus;

    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Network Monitor & Handover',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Clear completed requests',
            icon: const Icon(Icons.cleaning_services_rounded),
            onPressed: netProvider.requests.any((r) => r.isDone)
                ? () => netProvider.clearFinishedRequests()
                : null,
          ),
          IconButton(
            tooltip: 'Reset Handover Log',
            icon: const Icon(Icons.history_toggle_off_rounded),
            onPressed: netProvider.handoverHistory.isNotEmpty
                ? () => netProvider.clearHandoverHistory()
                : null,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          const maxContentWidth = 1120.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero Real-time Interface Status Banner
                    _buildActiveInterfaceHero(context, netProvider, currentStatus),
                    const SizedBox(height: 18),

                    // Quick Summary Metrics Cards
                    _buildMetricsRow(context, netProvider, isWide),
                    const SizedBox(height: 18),

                    // Handover Simulator & Live Controls Console
                    _buildSimulatorControls(context, netProvider),
                    const SizedBox(height: 20),

                    // Continuous Request Dispatcher
                    _buildRequestDispatcherCard(context, netProvider),
                    const SizedBox(height: 20),

                    // Two column layout on wide screens, stacked on mobile
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: _buildRequestQueueSection(context, netProvider),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            flex: 5,
                            child: _buildHandoverHistoryLog(context, netProvider),
                          ),
                        ],
                      )
                    else ...[
                      _buildRequestQueueSection(context, netProvider),
                      const SizedBox(height: 20),
                      _buildHandoverHistoryLog(context, netProvider),
                    ],

                    const SizedBox(height: 24),
                    _buildArchitectureExplainer(context, theme),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Real-time Hero Interface Banner
  Widget _buildActiveInterfaceHero(
    BuildContext context,
    NetworkMonitorProvider netProvider,
    NetworkStatusInfo status,
  ) {
    final theme = Theme.of(context);
    final color = status.type.color;
    final isOnline = status.isOnline;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: isDark ? 0.22 : 0.12),
            color.withValues(alpha: isDark ? 0.08 : 0.03),
          ],
        ),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.5 : 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Badges: Stream Mode Badge + Online/Offline Status Pill (Responsive Wrap)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              // Stream mode badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      netProvider.isSimulationMode
                          ? Icons.science_rounded
                          : Icons.sensors_rounded,
                      size: 15,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      netProvider.isSimulationMode
                          ? 'Simulation Mode'
                          : 'Live Hardware Stream',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Online / Offline Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isOnline
                      ? Colors.green.withValues(alpha: 0.16)
                      : Colors.red.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isOnline ? Colors.green : Colors.red,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? 'ONLINE' : 'OFFLINE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isOnline ? Colors.green : Colors.red,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Main Interface Row: Network Icon + Name & Carrier
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Interface Icon with Glowing Aura
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.18),
                  border: Border.all(
                    color: color.withValues(alpha: 0.45),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(status.type.icon, color: color, size: 28),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.type.displayName.toUpperCase(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: color,
                        letterSpacing: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      status.networkName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Responsive 2x2 micro-metrics grid
          Row(
            children: [
              Expanded(
                child: _buildHeroMetricTile(
                  icon: Icons.tag_rounded,
                  label: 'Assigned IP',
                  value: status.ipAddress,
                  accentColor: color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHeroMetricTile(
                  icon: Icons.speed_rounded,
                  label: 'Network Latency',
                  value: isOnline ? '${status.latencyMs} ms' : 'N/A',
                  badgeText: isOnline
                      ? (status.latencyMs < 25 ? 'Fast' : 'Normal')
                      : 'Offline',
                  badgeColor: isOnline
                      ? (status.latencyMs < 25 ? Colors.green : Colors.orange)
                      : Colors.red,
                  accentColor: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildHeroMetricTile(
                  icon: Icons.sync_alt_rounded,
                  label: 'Handovers Detected',
                  value: '${netProvider.totalHandoversDetected} handovers',
                  accentColor: color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHeroMetricTile(
                  icon: Icons.access_time_rounded,
                  label: 'Last Timestamp',
                  value:
                      '${status.timestamp.hour.toString().padLeft(2, '0')}:${status.timestamp.minute.toString().padLeft(2, '0')}:${status.timestamp.second.toString().padLeft(2, '0')}',
                  accentColor: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetricTile({
    required IconData icon,
    required String label,
    required String value,
    String? badgeText,
    Color? badgeColor,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badgeText != null && badgeColor != null) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Metrics Summary Row
  Widget _buildMetricsRow(
    BuildContext context,
    NetworkMonitorProvider netProvider,
    bool isWide,
  ) {
    final inFlight = netProvider.inFlightRequestsCount;
    final queued = netProvider.queuedRequestsCount;
    final completed = netProvider.completedRequestsCount;

    final cards = [
      _buildModernStatCard(
        title: 'Active In-Flight',
        value: '$inFlight',
        subtitle: inFlight > 0 ? 'Streaming packets' : 'Queue idle',
        color: const Color(0xFF0288D1),
        icon: Icons.sync_rounded,
        isActive: inFlight > 0,
      ),
      _buildModernStatCard(
        title: 'Queued (Paused)',
        value: '$queued',
        subtitle: queued > 0 ? 'Held safely for recovery' : 'Zero held requests',
        color: const Color(0xFFF57C00),
        icon: Icons.pause_circle_outline_rounded,
        isActive: queued > 0,
      ),
      _buildModernStatCard(
        title: 'Successfully Completed',
        value: '$completed',
        subtitle: '100% data integrity',
        color: const Color(0xFF2E7D32),
        icon: Icons.check_circle_outline_rounded,
        isActive: completed > 0,
      ),
    ];

    if (isWide) {
      return Row(
        children: cards
            .map((c) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: c,
                  ),
                ))
            .toList(),
      );
    }

    return Column(
      children: cards
          .map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: c,
              ))
          .toList(),
    );
  }

  Widget _buildModernStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
    required bool isActive,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: color.withValues(alpha: isActive ? 0.45 : 0.2),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handover Simulator & Live Controls Console
  Widget _buildSimulatorControls(
    BuildContext context,
    NetworkMonitorProvider netProvider,
  ) {
    final theme = Theme.of(context);
    final isSim = netProvider.isSimulationMode;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Mode Switcher Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Handover & Testing Console',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isSim ? 'Simulation' : 'Live Stream',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSim
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                ),
                Switch(
                  value: isSim,
                  onChanged: (val) => netProvider.setSimulationMode(val),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Switch between Wi-Fi and Cellular to trigger handovers, or drop the connection to test in-flight request pausing and automatic recovery upon reconnection.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Interface Buttons Grid
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildInterfaceActionButton(
                  label: 'Wi-Fi 5GHz',
                  icon: Icons.wifi_rounded,
                  color: NetworkInterfaceType.wifi.color,
                  isSelected:
                      netProvider.currentStatus.type == NetworkInterfaceType.wifi,
                  onPressed: () =>
                      netProvider.simulateInterface(NetworkInterfaceType.wifi),
                ),
                _buildInterfaceActionButton(
                  label: 'Cellular 5G',
                  icon: Icons.signal_cellular_alt_rounded,
                  color: NetworkInterfaceType.cellular.color,
                  isSelected:
                      netProvider.currentStatus.type == NetworkInterfaceType.cellular,
                  onPressed: () => netProvider
                      .simulateInterface(NetworkInterfaceType.cellular),
                ),
                _buildInterfaceActionButton(
                  label: 'Ethernet',
                  icon: Icons.settings_ethernet_rounded,
                  color: NetworkInterfaceType.ethernet.color,
                  isSelected:
                      netProvider.currentStatus.type == NetworkInterfaceType.ethernet,
                  onPressed: () => netProvider
                      .simulateInterface(NetworkInterfaceType.ethernet),
                ),
                _buildInterfaceActionButton(
                  label: 'Drop Connection (Offline)',
                  icon: Icons.wifi_off_rounded,
                  color: NetworkInterfaceType.none.color,
                  isSelected:
                      netProvider.currentStatus.type == NetworkInterfaceType.none,
                  onPressed: () =>
                      netProvider.simulateInterface(NetworkInterfaceType.none),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Quick Handover Callout Bar
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => netProvider.simulateQuickHandover(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.swap_horiz_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Handover (Wi-Fi ↔ Cellular)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            'Migrate active socket IP from ${netProvider.currentStatus.type == NetworkInterfaceType.wifi ? 'Wi-Fi to 5G' : 'Cellular to Wi-Fi'} instantly',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterfaceActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return FilledButton.tonalIcon(
      style: FilledButton.styleFrom(
        backgroundColor: isSelected
            ? color.withValues(alpha: 0.25)
            : color.withValues(alpha: 0.1),
        foregroundColor: color,
        side: isSelected ? BorderSide(color: color, width: 1.5) : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        ),
      ),
    );
  }

  /// Continuous Request Dispatcher Section
  Widget _buildRequestDispatcherCard(
    BuildContext context,
    NetworkMonitorProvider netProvider,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.cloud_upload_outlined,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Continuous Request Dispatcher',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Simulate continuous or long-running multi-chunk dataset transmissions. Try dropping the network midway through a transmission to observe automatic queuing!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Dispatch Action Buttons
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    netProvider.enqueueRequest(
                      title: 'Telemetry Stream (Lab Activity 3)',
                      totalChunks: 30,
                      totalSizeBytes: 750 * 1024,
                    );
                  },
                  icon: const Icon(Icons.sensors_rounded, size: 18),
                  label: const Text('Fetch Telemetry (30 chunks)'),
                ),
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    netProvider.enqueueRequest(
                      title: 'Large Geospatial Dataset Download',
                      totalChunks: 60,
                      totalSizeBytes: 3 * 1024 * 1024,
                    );
                  },
                  icon: const Icon(Icons.public_rounded, size: 18),
                  label: const Text('Fetch Large Dataset (60 chunks)'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => netProvider.enqueueSampleBatch(),
                  icon: const Icon(Icons.playlist_add_rounded, size: 18),
                  label: const Text('Dispatch Batch (3 Requests)'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // Custom Chunk Dispatch Slider
            Row(
              children: [
                const Icon(Icons.tune_rounded, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Custom: ${_customChunkCount.toInt()} Chunks (${(_customChunkCount * 25).toInt()} KB)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    netProvider.enqueueRequest(
                      title: 'Custom Stream (${_customChunkCount.toInt()} Chunks)',
                      totalChunks: _customChunkCount.toInt(),
                      totalSizeBytes: (_customChunkCount * 25 * 1024).toInt(),
                    );
                  },
                  child: const Text('Dispatch Custom', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
            Slider(
              value: _customChunkCount,
              min: 10,
              max: 100,
              divisions: 18,
              label: '${_customChunkCount.toInt()} chunks',
              onChanged: (val) {
                setState(() {
                  _customChunkCount = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Request Queue Section
  Widget _buildRequestQueueSection(
    BuildContext context,
    NetworkMonitorProvider netProvider,
  ) {
    final theme = Theme.of(context);
    final requests = netProvider.requests;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.queue_rounded,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Request Queue & Resiliency',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${requests.length} Requests',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (requests.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.cloud_queue_rounded,
                          size: 52, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No requests currently in flight or queue',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Use the dispatcher above to simulate long-running transmissions.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requests.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return _buildRequestItemTile(context, netProvider, req);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestItemTile(
    BuildContext context,
    NetworkMonitorProvider netProvider,
    NetworkRequestItem req,
  ) {
    final theme = Theme.of(context);
    final statusColor = req.status.color;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(req.status.icon, color: statusColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${req.id} • ${(req.totalSizeBytes / 1024).toStringAsFixed(0)} KB payload',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  req.status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
              if (req.retryCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Retries: ${req.retryCount}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
              ],
              // Action Buttons
              if (req.isQueued)
                IconButton(
                  tooltip: 'Manual Retry / Resume',
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.green),
                  onPressed: () => netProvider.retryRequest(req.id),
                )
              else if (req.isInFlight)
                IconButton(
                  tooltip: 'Pause',
                  icon: const Icon(Icons.pause_rounded, color: Colors.orange),
                  onPressed: () => netProvider.pauseRequest(req.id),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: req.progress,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${req.completedChunks} / ${req.totalChunks} chunks (${(req.progress * 100).toStringAsFixed(0)}%)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              if (req.lastError != null)
                Expanded(
                  child: Text(
                    req.lastError!,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: req.isQueued ? Colors.orange.shade800 : Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Handover History & Transition Log
  Widget _buildHandoverHistoryLog(
    BuildContext context,
    NetworkMonitorProvider netProvider,
  ) {
    final theme = Theme.of(context);
    final history = netProvider.handoverHistory;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.history_edu_rounded,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Handover & State Log',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (history.isNotEmpty)
                  Text(
                    '${history.length} events',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
            if (history.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Center(
                  child: Text(
                    'No network handovers recorded yet.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF14171A) : const Color(0xFFF7F9FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: history.length,
                    separatorBuilder: (context, index) => const Divider(height: 12),
                    itemBuilder: (context, index) {
                      final event = history[index];
                      final timeStr =
                          '${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}:${event.timestamp.second.toString().padLeft(2, '0')}';

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[900] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              timeStr,
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.cyanAccent : Colors.blueGrey[800],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            event.wasInFlightRequestPaused
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_outline_rounded,
                            size: 14,
                            color: event.wasInFlightRequestPaused
                                ? Colors.orange.shade800
                                : theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Explainer Card on Handover Architecture
  Widget _buildArchitectureExplainer(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.phonelink_ring_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Network Stream & Handover Resiliency Pipeline',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '• Real-time Stream Listener: Subscribed to `connectivity_plus` to listen for network state transitions (Wi-Fi, Cellular, Offline).\n'
                  '• IP Migration & Handover Interception: Catches socket disconnects and interface changes midway without throwing unhandled exceptions.\n'
                  '• Request Queuing: In-flight multi-part requests automatically transition into a safe Queued/Paused state.\n'
                  '• Graceful Recovery: As soon as a valid connection (Wi-Fi or Cellular) is re-established, the queue manager drains and resumes pending chunks seamlessly.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.45,
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
