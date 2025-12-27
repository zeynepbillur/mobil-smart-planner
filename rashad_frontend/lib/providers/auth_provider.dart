import 'package:flutter/foundation.dart';
import 'package:rashad_frontend/models/user.dart';
import 'package:rashad_frontend/services/user_service.dart';

class AuthProvider with ChangeNotifier {
  final UserService _userService = UserService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';

  Future<bool> autoLogin() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _userService.autoLogin();
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _userService.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('LOGIN ERROR: $e');
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userService.register(name, email, password);
      // Kayıt başarılıysa direkt login olmasını sağlayalım
      return await login(email, password);
    } catch (e) {
      print('REGISTER ERROR: $e');
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.logout();
      _currentUser = null;
      _error = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void switchUser(User user) {
    _currentUser = user;
    _userService.setCurrentUser(user);
    notifyListeners();
  }

  Future<void> updateCurrentUser(User updatedUser, {String? password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _userService.updateUser(updatedUser, password: password);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Kullanıcı güncellenemedi';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
