// ignore_for_file: unused_import

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workmanager/workmanager.dart';

import 'splash_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'sign_up_screen.dart';
import 'map_screen.dart';
import 'charging_types_screen.dart';
import 'charging_station_list_screen.dart';
import 'profile_screen.dart'; // ✅ Import ProfileScreen
import 'work_manager_service.dart'; // Import WorkManager service

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Initialize WorkManager
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false, // Set to true only for debugging
  );

  // Register periodic task to update charging stations
  Workmanager().registerPeriodicTask(
    "ev_update_task",
    "update_ev_stations",
    frequency: const Duration(hours: 1), // Runs every 1 hour
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/map': (context) => MapScreen(),
        '/charging_types': (context) => const ChargingTypesScreen(),
        '/charging_stations': (context) => const ChargingStationListScreen(),
        '/profile': (context) => const ProfileScreen(), // ✅ Add profile route
      },
    );
  }
}
