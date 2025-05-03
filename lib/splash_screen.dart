// ignore_for_file: unused_import, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  void _checkUser() async {
    await Future.delayed(
        const Duration(seconds: 2)); // Show splash for 2 seconds
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // If the user is already logged in, navigate to the home screen
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // If no user is logged in, navigate to the login screen
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/ev_charge.jpeg', // Replace with your splash image path
          fit: BoxFit.cover, // Adjusts image to fit the screen
        ),
      ),
    );
  }
}
