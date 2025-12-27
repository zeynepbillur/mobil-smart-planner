import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rashad_frontend/screens/splash_screen.dart';
import 'package:rashad_frontend/screens/login_screen.dart';
import 'package:rashad_frontend/screens/dashboard_screen.dart';
import 'package:rashad_frontend/providers/auth_provider.dart';
import 'package:rashad_frontend/providers/task_provider.dart';
import 'package:rashad_frontend/providers/app_provider.dart';
import 'package:rashad_frontend/providers/program_provider.dart';
import 'package:rashad_frontend/providers/user_provider.dart';
import 'package:rashad_frontend/utils/app_colors.dart';
import 'package:rashad_frontend/utils/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => ProgramProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: TaskManagerApp(),
    ),
  );
}

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryColor,
              brightness: Brightness.dark,
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              secondary: AppColors.accentColor,
              onSecondary: Colors.black,
              background: AppColors.background,
              surface: AppColors.surface,
              error: AppColors.error,
            ),
            scaffoldBackgroundColor: AppColors.background,
            cardTheme: CardThemeData(
              elevation: 4,
              color: AppColors.cardBackground,
              shadowColor: Colors.black.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            appBarTheme: AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.textPrimary,
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 4,
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.textHint),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.textHint.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: AppColors.surface,
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintStyle: TextStyle(color: AppColors.textHint),
            ),
            dividerTheme: DividerThemeData(
              color: AppColors.textHint.withOpacity(0.2),
              thickness: 1,
            ),
          ),
          home: AuthWrapper(),
          routes: {
            '/login': (context) => LoginScreen(),
            '/dashboard': (context) => DashboardScreen(),
            '/splash': (context) => SplashScreen(),
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = await authProvider.autoLogin();
    
    if (mounted) {
      setState(() {
        _isChecking = false;
      });
      
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Container();
  }
}
