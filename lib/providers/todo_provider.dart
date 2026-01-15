
import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../models/profile.dart';
import '../services/local_storage_service.dart';

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];
  List<Profile> _profiles = [];
  final LocalStorageService _storageService = LocalStorageService();
  bool _isLoading = true;

  List<Todo> get todos => _todos;
  List<Profile> get profiles => _profiles;
  List<Todo> get generalTodos => _todos.where((t) => t.category == 'general').toList();
  List<Todo> get groceries => _todos.where((t) => t.category == 'grocery').toList();
  bool get isLoading => _isLoading;

  TodoProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();
    
    _profiles = await _storageService.loadProfiles();
    if (_profiles.isEmpty) {
      _profiles = [
        Profile(id: '1', name: 'Alex', initial: 'A', colorValue: 0xFFEF6C00),
        Profile(id: '2', name: 'Brian', initial: 'B', colorValue: 0xFF42A5F5),
        Profile(id: '3', name: 'Elena', initial: 'E', colorValue: 0xFFEF5350),
        Profile(id: '4', name: 'Frank', initial: 'F', colorValue: 0xFF1565C0),
      ];
      await _storageService.saveProfiles(_profiles);
    }

    _todos = await _storageService.loadTodos();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTodo(String title, {String category = 'general', String? profileId}) async {
    final newTodo = Todo(
      id: DateTime.now().toString(),
      title: title,
      category: category,
      profileId: profileId ?? (category == 'general' && _profiles.isNotEmpty ? _profiles.first.id : null),
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

  Future<void> resetData() async {
    _isLoading = true;
    notifyListeners();
    
    // Clear existing data
    _todos.clear();
    _profiles.clear();
    await _storageService.saveTodos([]);
    await _storageService.saveProfiles([]);
    
    // Reload defaults
    await _loadData();
  }
}
