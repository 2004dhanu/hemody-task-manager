import 'package:cloud_firestore/cloud_firestore.dart';

class Task {

  String id;
  String title;
  String description;
  DateTime? dueDate;
  bool completed;
  int priority;       // 0=Low, 1=Medium, 2=High
  String category;    // 'Personal', 'Work', 'Health', 'Finance', 'Other'

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    this.dueDate,
    this.priority = 1,
    this.category = 'Personal',
  });

  factory Task.fromMap(Map<String, dynamic> data, String id) {
    return Task(
      id: id,
      title: data['title'] ?? "",
      description: data['description'] ?? "",
      completed: data['completed'] ?? false,
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      priority: data['priority'] ?? 1,
      category: data['category'] ?? 'Personal',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "completed": completed,
      "dueDate": dueDate,
      "priority": priority,
      "category": category,
    };
  }
}