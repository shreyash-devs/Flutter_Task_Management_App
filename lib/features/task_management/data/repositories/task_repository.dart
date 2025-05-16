import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
import '../../domain/repositories/task_repository_interface.dart';

class TaskRepository implements TaskRepositoryInterface {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TaskRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _userTasksCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      print('TaskRepository: No user logged in');
      throw Exception('User not logged in');
    }
    print('TaskRepository: Getting tasks for user: $uid');
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  Future<void> addTask(Task task) async {
    try {
      await _userTasksCollection.add(task.toMap());
      print('TaskRepository: Task added successfully');
    } catch (e) {
      print('TaskRepository: Error adding task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _userTasksCollection.doc(task.id).update(task.toMap());
      print('TaskRepository: Task updated successfully');
    } catch (e) {
      print('TaskRepository: Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _userTasksCollection.doc(taskId).delete();
      print('TaskRepository: Task deleted successfully');
    } catch (e) {
      print('TaskRepository: Error deleting task: $e');
      rethrow;
    }
  }

  Stream<List<Task>> getTasksStream() {
    try {
      return _userTasksCollection.snapshots().map((snapshot) {
        print('TaskRepository: Received ${snapshot.docs.length} tasks');
        return snapshot.docs
            .map((doc) => Task.fromMap(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('TaskRepository: Error getting tasks stream: $e');
      rethrow;
    }
  }

  Future<Task?> getTaskById(String taskId) async {
    try {
      final doc = await _userTasksCollection.doc(taskId).get();
      if (doc.exists) {
        print('TaskRepository: Found task with ID: $taskId');
        return Task.fromMap(doc.data()!, doc.id);
      }
      print('TaskRepository: No task found with ID: $taskId');
      return null;
    } catch (e) {
      print('TaskRepository: Error getting task by ID: $e');
      rethrow;
    }
  }
}
