import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stream_check/firebase_options.dart';
import 'package:stream_check/main_init.dart';
import 'package:stream_check/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await appInit();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 210, 214, 217),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        // Define your dark theme here
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 44, 44, 48),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
