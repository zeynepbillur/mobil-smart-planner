import 'package:flutter/foundation.dart';
import 'package:rashad_frontend/models/task.dart';
import 'package:rashad_frontend/services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('PROVIDER: Loading tasks...');
      _tasks = await _taskService.getTasks();
      print('PROVIDER: Loaded ${_tasks.length} tasks');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('PROVIDER ERROR: Failed to load tasks: $e');
      _error = 'Görevler yüklenemedi';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getAllTasks();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Tüm görevler yüklenemedi';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Task>> getUserTasks(String userId) async {
    try {
      return await _taskService.getTasksByUserId(userId);
    } catch (e) {
      _error = 'Kullanıcı görevleri yüklenemedi';
      notifyListeners();
      return [];
    }
  }

  Future<void> loadTasksByUserId(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasksByUserId(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Görevler yüklenemedi';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTask(Task task) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      print('PROVIDER: Adding task: ${task.title}');
      final newTask = await _taskService.createTask(task);
      print('PROVIDER: Task created successfully: ${newTask.id}');
      
      // Görev listesini yeniden yükle
      await loadTasks();
      
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      print('PROVIDER ERROR: Failed to add task: $e');
      _error = 'Görev eklenemedi: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(Task task) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final updatedTask = await _taskService.updateTask(task);
      
      // Görev listesini yeniden yükle
      await loadTasks();
      
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Görev güncellenemedi: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _taskService.deleteTask(taskId);
      
      // Görev listesini yeniden yükle
      await loadTasks();
      
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Görev silinemedi: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleTaskCompletion(String taskId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      await _taskService.toggleTaskCompletion(task);
      
      // Görev listesini yeniden yükle
      await loadTasks();
      
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Görev durumu değiştirilemedi: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<Task> getTasksByCategory(String categoryId) {
    return _tasks.where((task) => task.categoryId == categoryId).toList();
  }

  List<Task> getTasksByStatus(String status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  List<Task> getOverdueTasks() {
    final now = DateTime.now();
    return _tasks
        .where((task) =>
            task.dueDate.isBefore(now) && task.status != 'completed')
        .toList();
  }

  List<Task> searchTasks(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _tasks
        .where((task) =>
            task.title.toLowerCase().contains(lowercaseQuery) ||
            task.description.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
