import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/auth/welcome_screen.dart';
import 'theme/app_theme.dart';

/// Main entry point for the EventMate application
/// 
/// This initializes the Flutter app and sets up:
/// - System UI overlay style (status bar)
/// - Portrait orientation lock
/// - Error handling
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations (portrait only for better UX on phones)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style (status bar and navigation bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent status bar
      statusBarIconBrightness: Brightness.light, // Light icons for dark AppBar
      statusBarBrightness: Brightness.dark, // For iOS
      systemNavigationBarColor: Colors.white, // Bottom navigation bar color
      systemNavigationBarIconBrightness: Brightness.dark, // Dark icons for white nav bar
    ),
  );
  
  // Run the app
  runApp(const EventMateApp());
}

/// Root widget of the EventMate application
/// 
/// This is a stateless widget that sets up:
/// - MaterialApp configuration
/// - App theme
/// - Initial route (Welcome screen)
/// - Debug banner settings
class EventMateApp extends StatelessWidget {
  const EventMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App configuration
      title: 'EventMate',
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: AppTheme.lightTheme,
      
      // Dark theme (optional - currently same as light)
      // darkTheme: AppTheme.darkTheme,
      // themeMode: ThemeMode.system, // Follows system setting
      
      // Initial route
      home: const WelcomeScreen(),
      
      // Material 3 configuration
      // This is already set in AppTheme but can be explicitly stated
      // useMaterial3: true,
      
      // Localization (can be added later for multi-language support)
      // locale: const Locale('en', 'US'),
      // supportedLocales: const [
      //   Locale('en', 'US'),
      // ],
    );
  }
}