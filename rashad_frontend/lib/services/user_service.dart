import 'package:dio/dio.dart';
import 'package:rashad_frontend/models/user.dart';
import 'package:rashad_frontend/utils/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class UserService {
  User? _currentUser;
  final ApiClient _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'logged_in_user';

  User? get currentUser => _currentUser;

  Future<User> register(String name, String email, String password) async {
    try {
      final response = await _apiClient.post('register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201) {
        final userData = response.data['data'];
        return User.fromJson(userData);
      } else {
        throw Exception(response.data['message'] ?? 'Kayıt başarısız');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      rethrow;
    }
  }


  Future<User> login(String email, String password) async {
    try {
      print('LOGIN: Attempting login for $email');
      final response = await _apiClient.post('login', data: {
        'email': email,
        'password': password,
      });

      print('LOGIN: Response status: ${response.statusCode}');
      print('LOGIN: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final String token = data['token'];
        final Map<String, dynamic> userJson = data['user'];
        
        _currentUser = User.fromJson(userJson);

        // Save to secure storage
        await _storage.write(key: _tokenKey, value: token);
        await _storage.write(key: _userKey, value: jsonEncode(_currentUser!.toJson()));

        return _currentUser!;
      } else {
        throw Exception(response.data['message'] ?? 'Giriş başarısız');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      print('LOGIN ERROR in service: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<User> updateUser(User user, {String? password}) async {
    try {
      final userData = user.toJson();
      // MongoDB _id alanının güncellenmesine izin vermez, bu yüzden body'den çıkarıyoruz
      userData.remove('_id');
      
      if (password != null && password.isNotEmpty) {
        userData['password'] = password;
      }
      
      final response = await _apiClient.put('users/${user.id}', data: userData);
      
      if (response.statusCode == 200) {
        final updatedUser = User.fromJson(response.data['data']);
        if (_currentUser?.id == updatedUser.id) {
          _currentUser = updatedUser;
          await _storage.write(key: _userKey, value: jsonEncode(_currentUser!.toJson()));
        }
        return updatedUser;
      } else {
        throw Exception(response.data['message'] ?? 'Güncelleme başarısız');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      rethrow;
    }
  }

  bool isAdmin() {
    return _currentUser?.role == 'admin';
  }

  void setCurrentUser(User user) {
    _currentUser = user;
  }

  Future<User?> autoLogin() async {
    final token = await _storage.read(key: _tokenKey);
    final userJsonStr = await _storage.read(key: _userKey);

    if (token != null && userJsonStr != null) {
      try {
        final Map<String, dynamic> userJson = jsonDecode(userJsonStr);
        _currentUser = User.fromJson(userJson);
        return _currentUser;
      } catch (e) {
        await logout();
        return null;
      }
    }
    return null;
  }

  Future<List<User>> getUsers() async {
    try {
      final response = await _apiClient.get('users');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Kullanıcılar alınamadı');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      rethrow;
    }
  }

  String _handleError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "Sunucuya bağlanılamadı (Zaman aşımı)";
      case DioExceptionType.connectionError:
        return "İnternet bağlantınızı kontrol edin veya sunucu kapalı olabilir";
      default:
        return "Giriş başarısız. Lütfen bilgilerinizi kontrol edin.";
    }
  }
}
