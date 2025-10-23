import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/auth/welcome_screen.dart';
import 'theme/app_theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const EventMateApp());
}

class EventMateApp extends StatelessWidget {
  const EventMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'EventMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      
      // Dark theme (optional - currently same as light)
      // darkTheme: AppTheme.darkTheme,
      // themeMode: ThemeMode.system,
      home: const WelcomeScreen(),
      // useMaterial3: true,
      

    );
  }
}