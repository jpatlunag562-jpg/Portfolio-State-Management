import 'package:flutter/material.dart';
import '../models/activity_item.dart';

class ActivityCard extends StatelessWidget {
  final ActivityItem activity;
  final bool isCompleted;
  final VoidCallback? onCompletedToggle;

  const ActivityCard({
    super.key,
    required this.activity,
    this.isCompleted = false,
    this.onCompletedToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: activity.isAvailable ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: activity.isAvailable
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : theme.disabledColor.withValues(alpha: 0.15),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (activity.isAvailable) {
            Navigator.pushNamed(context, activity.route);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${activity.title} will be available in future laboratory modules.',
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Category badge, Activity Number, and Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: activity.isAvailable
                          ? theme.colorScheme.primaryContainer
                          : theme.disabledColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Lab ${activity.activityNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: activity.isAvailable
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.disabledColor,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        activity.category,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (activity.isAvailable)
                    IconButton(
                      tooltip: isCompleted
                          ? 'Mark as incomplete'
                          : 'Mark as completed',
                      icon: Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.check_circle_outline_rounded,
                        color: isCompleted
                            ? Colors.green
                            : theme.colorScheme.outline,
                        size: 24,
                      ),
                      onPressed: onCompletedToggle,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Upcoming',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Icon + Title & Subtitle
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: activity.isAvailable
                        ? theme.colorScheme.primary.withValues(alpha: 0.12)
                        : theme.disabledColor.withValues(alpha: 0.08),
                    child: Icon(
                      activity.icon,
                      color: activity.isAvailable
                          ? theme.colorScheme.primary
                          : theme.disabledColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activity.subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(
                              alpha: 0.8,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Description
              Text(
                activity.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Bottom Action Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    activity.isAvailable ? 'Open Activity' : 'Locked',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: activity.isAvailable
                          ? theme.colorScheme.primary
                          : theme.disabledColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    activity.isAvailable
                        ? Icons.arrow_forward_rounded
                        : Icons.lock_outline_rounded,
                    size: 16,
                    color: activity.isAvailable
                        ? theme.colorScheme.primary
                        : theme.disabledColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
