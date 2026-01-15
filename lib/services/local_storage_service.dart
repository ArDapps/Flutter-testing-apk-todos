
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';
import '../models/profile.dart';

class LocalStorageService {
  static const String _todosKey = 'todos';
  static const String _profilesKey = 'profiles';
  static const String _onboardingKey = 'has_seen_onboarding';
  static const String _fontSizeKey = 'font_size_scale';

  Future<void> saveTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      todos.map((todo) => todo.toJson()).toList(),
    );
    await prefs.setString(_todosKey, encodedData);
  }

  Future<List<Todo>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_todosKey);
    if (encodedData == null) {
      return [];
    }
    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.map((item) => Todo.fromJson(item)).toList();
  }

  Future<void> saveProfiles(List<Profile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      profiles.map((profile) => profile.toJson()).toList(),
    );
    await prefs.setString(_profilesKey, encodedData);
  }

  Future<List<Profile>> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_profilesKey);
    if (encodedData == null) {
      return [];
    }
    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.map((item) => Profile.fromJson(item)).toList();
  }

  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  Future<void> clearOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
  }

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> saveFontSize(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, scale);
  }

  Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? 1.0;
  }
}
