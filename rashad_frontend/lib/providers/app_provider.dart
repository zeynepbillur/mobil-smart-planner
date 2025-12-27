import 'package:flutter/foundation.dart';

class AppProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String _selectedLanguage = 'tr';

  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }
}
