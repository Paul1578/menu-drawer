import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:menubar/src/pages/auth/login.dart'; 
import 'package:menubar/src/pages/config/theme_notifier.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  
  // ignore: unused_local_variable
  final prefs = await SharedPreferences.getInstance();
  final themeNotifier = ThemeNotifier();
  await themeNotifier.loadThemePreference(); 

  runApp(
    ChangeNotifierProvider(
      create: (context) => themeNotifier,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) {
        return MaterialApp(
          title: 'Proyecto Demo',
          debugShowCheckedModeBanner: false,
          theme: themeNotifier.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          home: const LoginPage(), 
        );
      },
    );
  }
}
