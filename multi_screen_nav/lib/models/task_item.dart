class TaskItem {
  final String id;
  final String title;
  final String category;
  bool isCompleted;
  final String note;

  TaskItem({
    required this.id,
    required this.title,
    required this.category,
    this.isCompleted = false,
    this.note = '',
  });

  TaskItem copyWith({
    String? id,
    String? title,
    String? category,
    bool? isCompleted,
    String? note,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      note: note ?? this.note,
    );
  }
}
