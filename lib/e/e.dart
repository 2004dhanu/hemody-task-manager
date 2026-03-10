import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:herodydemo/model/task_model.dart';

class FirebaseService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user tasks
  Stream<List<Task>> getTasks() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection("tasks")
        .where("userId", isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Add new task — now includes priority and category
  Future<void> addTask(
    String title,
    String description,
    DateTime? dueDate, {
    int priority = 1,
    String category = 'Personal',
  }) async {
    final uid = _auth.currentUser!.uid;
    await _firestore.collection("tasks").add({
      "title": title,
      "description": description,
      "completed": false,
      "dueDate": dueDate,
      "priority": priority,
      "category": category,
      "userId": uid,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// Update full task
  Future<void> updateTask(Task task) async {
    await _firestore
        .collection("tasks")
        .doc(task.id)
        .update(task.toMap());
  }

  /// Delete task
  Future<void> deleteTask(String id) async {
    await _firestore
        .collection("tasks")
        .doc(id)
        .delete();
  }

  /// Edit task fields — now includes priority and category
  Future<void> editTask(
    String id,
    String title,
    String description,
    DateTime? dueDate, {
    int? priority,
    String? category,
  }) async {
    final Map<String, dynamic> updates = {
      "title": title,
      "description": description,
      "dueDate": dueDate,
    };
    if (priority != null) updates["priority"] = priority;
    if (category != null) updates["category"] = category;

    await _firestore.collection("tasks").doc(id).update(updates);
  }
}