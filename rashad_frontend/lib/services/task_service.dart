import 'package:rashad_frontend/models/task.dart';
import 'package:rashad_frontend/utils/api_client.dart';

class TaskService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Task>> getTasks() async {
    try {
      final response = await _apiClient.get('tasks');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Görevler alınamadı');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Task>> getAllTasks() async {
    try {
      final response = await _apiClient.get('tasks/all');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Tüm görevler alınamadı');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Task>> getTasksByUserId(String userId) async {
    try {
      final response = await _apiClient.get('tasks/user/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Kullanıcı görevleri alınamadı');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Task?> getTaskById(String taskId) async {
    try {
      // Backend doesn't have a specific getTaskById yet, using getAll and filtering
      final tasks = await getTasks();
      return tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  Future<Task> createTask(Task task) async {
    try {
      print('Creating task: ${task.toJson()}');
      
      // Backend beklediği format: title, description, dueDate, status, categoryId (optional), programId (optional)
      // userId auth middleware'den alınıyor
      final requestData = {
        'title': task.title,
        'description': task.description,
        'dueDate': task.dueDate.toIso8601String(),
        'status': task.status,
        // categoryId sadece geçerli ObjectId ise gönder, "1" gibi değerler gönderme
        if (task.categoryId != null && task.categoryId != '1' && task.categoryId!.isNotEmpty && task.categoryId!.length == 24) 
          'categoryId': task.categoryId,
        if (task.programId != null && task.programId!.isNotEmpty) 
          'programId': task.programId,
      };
      
      print('Sending task data: $requestData');
      
      final response = await _apiClient.post('tasks', data: requestData);
      
      print('Task response: ${response.statusCode} - ${response.data}');
      
      if (response.statusCode == 201) {
        return Task.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Görev oluşturulamadı');
      }
    } catch (e) {
      print('Task creation error: $e');
      rethrow;
    }
  }

  Future<Task> updateTask(Task task) async {
    try {
      print('Updating task: ${task.id}');
      
      // Backend'e sadece güncellenebilir alanları gönder
      final requestData = {
        'title': task.title,
        'description': task.description,
        'dueDate': task.dueDate.toIso8601String(),
        'status': task.status,
        if (task.categoryId != null && task.categoryId!.isNotEmpty && task.categoryId!.length == 24) 
          'categoryId': task.categoryId,
        if (task.programId != null && task.programId!.isNotEmpty) 
          'programId': task.programId,
      };
      
      print('Update request data: $requestData');
      
      final response = await _apiClient.put('tasks/${task.id}', data: requestData);
      
      print('Update response: ${response.statusCode} - ${response.data}');
      
      if (response.statusCode == 200) {
        return Task.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Görev güncellenemedi');
      }
    } catch (e) {
      print('Task update error: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      final response = await _apiClient.delete('tasks/$taskId');
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Görev silinemedi');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Toggle task completion
  Future<Task> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(
      status: task.status == 'completed' ? 'pending' : 'completed',
      updatedAt: DateTime.now(),
    );
    return await updateTask(updatedTask);
  }

  // Search tasks locally
  Future<List<Task>> searchTasks(String query) async {
    final tasks = await getTasks();
    final lowercaseQuery = query.toLowerCase();
    return tasks
        .where((task) =>
            task.title.toLowerCase().contains(lowercaseQuery) ||
            task.description.toLowerCase().contains(lowercaseQuery))
        .toList();
  }
}
