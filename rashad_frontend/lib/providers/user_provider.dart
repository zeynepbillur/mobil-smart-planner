import 'package:flutter/foundation.dart';
import 'package:rashad_frontend/models/user.dart';
import 'package:rashad_frontend/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _userService.getUsers();
    } catch (e) {
      _error = e.toString();
      print('DEBUG: UserProvider loadUsers error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
