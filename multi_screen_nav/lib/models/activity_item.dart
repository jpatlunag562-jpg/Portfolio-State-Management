import 'package:flutter/material.dart';

class ActivityItem {
  final String id;
  final int activityNumber;
  final String title;
  final String subtitle;
  final String description;
  final String category;
  final IconData icon;
  final String route;
  final String badgeText;
  final bool isAvailable;

  const ActivityItem({
    required this.id,
    required this.activityNumber,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.icon,
    required this.route,
    required this.badgeText,
    this.isAvailable = true,
  });
}
