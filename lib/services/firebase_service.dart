import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:technostrelka_2025/models/task.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получение текущего пользователя
  User? get currentUser => _auth.currentUser;

  // Регистрация
  Future<UserCredential> registerWithEmail(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Вход
  Future<UserCredential> loginWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Выход
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // Получение задач пользователя
  Stream<List<Task>> getUserTasks() {
    final userId = currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
        });
  }

  // Добавление задачи
  Future<void> addTask(Task task) async {
    final userId = currentUser?.uid;
    if (userId == null) {
      throw Exception('Пользователь не авторизован');
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .add(task.toFirestore());
  }

  // Обновление задачи
  Future<void> updateTask(Task task) async {
    final userId = currentUser?.uid;
    if (userId == null) {
      throw Exception('Пользователь не авторизован');
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(task.id)
        .update(task.toFirestore());
  }

  // Удаление задачи
  Future<void> deleteTask(String taskId) async {
    final userId = currentUser?.uid;
    if (userId == null) {
      throw Exception('Пользователь не авторизован');
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }
}
