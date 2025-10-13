import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stream_check/auth/login_screen.dart';
import 'package:stream_check/home_screen.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: Future.value(FirebaseAuth.instance.currentUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/streamoo_logo.png'),
                  const SizedBox(height: 40),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          );
        } else {
          if (snapshot.data != null) {
            // User is signed in
            return HomeScreen();
          } else {
            // No user signed in
            return LoginScreen();
          }
        }
      },
    );
  }
}
