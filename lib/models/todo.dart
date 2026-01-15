
class Todo {
  final String id;
  final String title;
  bool isCompleted;
  final String category;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.category = 'general',
    required this.createdAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'],
      category: json['category'] ?? 'general',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
