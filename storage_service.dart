import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'task.dart';

class StorageService {
  static const _key = 'estudia_tasks';

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) => Task.fromJson(s)).toList();
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, tasks.map((t) => t.toJson()).toList());
  }
}
