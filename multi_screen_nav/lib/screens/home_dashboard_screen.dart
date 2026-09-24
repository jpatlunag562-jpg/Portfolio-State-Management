import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/activity_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/user_banner.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lab Compilation Hub',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            onPressed: () => appState.toggleTheme(),
          ),
          IconButton(
            tooltip: 'Settings & Profile',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      drawer: _AppDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;
          final maxContentWidth = 1100.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Banner (StatelessWidget displaying global profile state)
                    const UserBanner(),
                    const SizedBox(height: 20),

                    // Responsive Statistics Cards
                    _buildStatsGrid(context, appState, isWide),
                    const SizedBox(height: 28),

                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Laboratory Activities',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Select an activity module to launch or review progress.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/settings'),
                          icon: const Icon(Icons.tune_rounded, size: 18),
                          label: const Text('Configure'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Activity Cards List / Grid (Responsive)
                    _buildActivitiesGrid(context, appState, isWide),
                    const SizedBox(height: 28),

                    // App Architecture Footer Card
                    _buildArchitectureNote(context, theme),
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

  Widget _buildStatsGrid(
    BuildContext context,
    AppStateProvider appState,
    bool isWide,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cards = [
      StatCard(
        title: 'Compilation Modules',
        value: '${appState.activities.length} Activities',
        subtitle: 'Master Repository',
        icon: Icons.folder_special_rounded,
        color: theme.colorScheme.primary,
      ),
      StatCard(
        title: 'Completed Labs',
        value: '${appState.completedActivitiesCount} of ${appState.activities.where((a) => a.isAvailable).length}',
        subtitle: 'Interactive Status',
        icon: Icons.task_alt_rounded,
        color: Colors.green,
      ),
      StatCard(
        title: 'Active Theme',
        value: isDark ? 'Dark Mode' : 'Light Mode',
        subtitle: 'Global State Sync',
        icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
        color: Colors.orange,
      ),
    ];

    if (isWide) {
      return Row(
        children: cards
            .map((card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: card,
                  ),
                ))
            .toList(),
      );
    }

    return Column(
      children: cards
          .map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: card,
              ))
          .toList(),
    );
  }

  Widget _buildActivitiesGrid(
    BuildContext context,
    AppStateProvider appState,
    bool isWide,
  ) {
    final activities = appState.activities;

    if (isWide) {
      // 2 Columns on wide screens
      final List<Widget> rows = [];
      for (int i = 0; i < activities.length; i += 2) {
        final first = activities[i];
        final second = (i + 1 < activities.length) ? activities[i + 1] : null;

        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ActivityCard(
                    activity: first,
                    isCompleted: appState.isActivityCompleted(first.id),
                    onCompletedToggle: () =>
                        appState.toggleActivityCompleted(first.id),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: second != null
                      ? ActivityCard(
                          activity: second,
                          isCompleted: appState.isActivityCompleted(second.id),
                          onCompletedToggle: () =>
                              appState.toggleActivityCompleted(second.id),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      }
      return Column(children: rows);
    }

    // 1 Column on standard / mobile screens
    return Column(
      children: activities.map((activity) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ActivityCard(
            activity: activity,
            isCompleted: appState.isActivityCompleted(activity.id),
            onCompletedToggle: () =>
                appState.toggleActivityCompleted(activity.id),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildArchitectureNote(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.architecture_rounded,
            color: theme.colorScheme.primary,
            size: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Declarative & Responsive Architecture',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '• StatelessWidget: Used for reusable presentational components (ActivityCard, StatCard, UserBanner).\n'
                  '• StatefulWidget: Used for local interactive state in Activity 1 (GPA Estimator) and Activity 2 (Milestone Tracker).\n'
                  '• Provider State Management: Global theme mode, student identity, and status synchronizer.\n'
                  '• Responsive Layouts: Flex, Column, Row, LayoutBuilder for adaptive rendering on any screen size.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.45,
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.85),
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

class _AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              appState.studentName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text('${appState.studentId} • ${appState.courseAndYear}'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: theme.colorScheme.surface,
              child: Text(
                appState.studentName.isNotEmpty
                    ? appState.studentName
                        .split(' ')
                        .map((e) => e.isNotEmpty ? e[0] : '')
                        .take(2)
                        .join()
                    : 'ST',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded),
            title: const Text('Home Dashboard'),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: const Text('Lab 1: Grade & GPA Estimator'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/activity1');
            },
          ),
          ListTile(
            leading: const Icon(Icons.checklist_rtl_rounded),
            title: const Text('Lab 2: Milestone Tracker'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/activity2');
            },
          ),
          ListTile(
            leading: const Icon(Icons.network_check_rounded),
            title: const Text('Lab 3: Active Network Monitor'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/network-monitor');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_rounded),
            title: const Text('Settings & Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            title: Text(
              theme.brightness == Brightness.dark
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
            ),
            onTap: () {
              appState.toggleTheme();
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About Compilation App'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'Laboratory Master Compilation',
                applicationVersion: 'v1.0.0',
                applicationLegalese: 'Developed with Flutter & Provider',
                children: [
                  const SizedBox(height: 12),
                  Text('Student: ${appState.studentName} (${appState.studentId})'),
                  Text('Department: ${appState.institution}'),
                  const SizedBox(height: 8),
                  const Text(
                    'This application serves as the master compilation container for all future laboratory exercises and activities.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
