
import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../services/local_storage_service.dart';

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];
  final LocalStorageService _storageService = LocalStorageService();
  bool _isLoading = true;

  List<Todo> get todos => _todos;
  List<Todo> get generalTodos => _todos.where((t) => t.category == 'general').toList();
  List<Todo> get groceries => _todos.where((t) => t.category == 'grocery').toList();
  bool get isLoading => _isLoading;

  TodoProvider() {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    _isLoading = true;
    notifyListeners();
    _todos = await _storageService.loadTodos();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTodo(String title, {String category = 'general'}) async {
    final newTodo = Todo(
      id: DateTime.now().toString(),
      title: title,
      category: category,
      createdAt: DateTime.now(),
    );
    _todos.add(newTodo);
    notifyListeners();
    await _storageService.saveTodos(_todos);
  }

  Future<void> toggleTodoStatus(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index].isCompleted = !_todos[index].isCompleted;
      notifyListeners();
      await _storageService.saveTodos(_todos);
    }
  }

  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
    await _storageService.saveTodos(_todos);
  }
}
