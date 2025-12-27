class AppConstants {
  // App Information
  static const String appName = 'Task Manager';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Görevlerinizi Yönetin';

  // API Configuration (for future use)
  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserData = 'user_data';
  static const String keyThemeMode = 'theme_mode';

  // Task Status
  static const String statusPending = 'pending';
  static const String statusInProgress = 'in-progress';
  static const String statusCompleted = 'completed';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';

  // Program Status
  static const String programActive = 'active';
  static const String programPlanning = 'planning';
  static const String programCompleted = 'completed';
  static const String programArchived = 'archived';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Date Formats
  static const String dateFormat = 'dd.MM.yyyy';
  static const String dateTimeFormat = 'dd.MM.yyyy HH:mm';
  static const String timeFormat = 'HH:mm';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);

  // Splash Screen
  static const Duration splashDuration = Duration(seconds: 3);

  // Debounce Duration
  static const Duration debounceDuration = Duration(milliseconds: 500);
}
