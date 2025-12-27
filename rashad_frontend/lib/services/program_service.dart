import 'package:dio/dio.dart';
import 'package:rashad_frontend/models/program.dart';
import 'package:rashad_frontend/models/task.dart';
import 'package:rashad_frontend/utils/api_client.dart';

class ProgramService {
  final ApiClient _apiClient = ApiClient();

  // Get all programs for the current user
  Future<List<Program>> getPrograms() async {
    try {
      final response = await _apiClient.get('programs');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Program.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Oturumunuz sona erdi. Lütfen tekrar giriş yapın.');
      } else {
        throw Exception(response.data['message'] ?? 'Programlar alınamadı');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response!.data['message'] ?? 'Bir hata oluştu';
        throw Exception(message);
      } else {
        throw Exception('Sunucuya bağlanılamadı. Backend çalışıyor mu?');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get program by ID (Note: using getPrograms and filtering since backend doesn't have details endpoint)
  Future<Program?> getProgramById(String programId) async {
    try {
      final programs = await getPrograms();
      return programs.firstWhere((prog) => prog.id == programId);
    } catch (e) {
      return null;
    }
  }

  // Get tasks of a specific program
  Future<List<Task>> getProgramTasks(String programId) async {
    try {
      final response = await _apiClient.get('programs/$programId/tasks');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Program görevleri alınamadı');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Program> createProgram(Program program) async {
    try {
      print('Creating program with data: ${program.toJson()}');
      
      // Backend sadece name, description, isPublic bekliyor
      // ownerId auth middleware'den alınıyor
      final requestData = {
        'name': program.name,
        'description': program.description,
        'isPublic': program.isPublic,
      };
      
      print('Sending to backend: $requestData');
      
      final response = await _apiClient.post('programs', data: requestData);
      
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      if (response.statusCode == 201) {
        return Program.fromJson(response.data['data']);
      } else if (response.statusCode == 401) {
        throw Exception('Oturumunuz sona erdi. Lütfen tekrar giriş yapın.');
      } else {
        throw Exception(response.data['message'] ?? 'Program oluşturulamadı');
      }
    } on DioException catch (e) {
      print('Program creation DioException: ${e.response?.data}');
      if (e.response != null) {
        final message = e.response!.data['message'] ?? 'Program oluşturulamadı';
        throw Exception(message);
      } else {
        throw Exception('Sunucuya bağlanılamadı. Backend çalışıyor mu?');
      }
    } catch (e) {
      print('Program creation error: $e');
      rethrow;
    }
  }

  Future<void> approveUser(String programId, String userId) async {
    try {
      final response = await _apiClient.post('programs/approve-user', data: {
        'programId': programId,
        'userId': userId,
      });
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Kullanıcı onaylanamadı');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update program (Admin/Owner only)
  Future<Program> updateProgram(Program program) async {
    try {
      final requestData = {
        'name': program.name,
        'description': program.description,
        'isPublic': program.isPublic,
      };
      
      final response = await _apiClient.put('programs/${program.id}', data: requestData);
      
      if (response.statusCode == 200) {
        return Program.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Program güncellenemedi');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Join program by code
  Future<Program> joinProgram(String code) async {
    try {
      final response = await _apiClient.post('programs/join', data: {'code': code});
      
      if (response.statusCode == 200) {
        return Program.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Programa katılınamadı');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response!.data['message'] ?? 'Programa katılınamadı';
        throw Exception(message);
      } else {
        throw Exception('Sunucuya bağlanılamadı. Backend çalışıyor mu?');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete program (Admin/Owner only)
  Future<void> deleteProgram(String programId) async {
    try {
      final response = await _apiClient.delete('programs/$programId');
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Program silinemedi');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response!.data['message'] ?? 'Program silinemedi';
        throw Exception(message);
      } else {
        throw Exception('Sunucuya bağlanılamadı. Backend çalışıyor mu?');
      }
    } catch (e) {
      rethrow;
    }
  }
}
