import 'package:flutter/material.dart';
import 'package:stream_check/auth/login_button_screen.dart';
import 'package:stream_check/auth/register_button_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/login_cat.png'),
              const SizedBox(height: 40),
              Text(
                'Streamoo',
                style: TextStyle(fontFamily: 'AmaticSC', fontSize: 50),
              ),
              const SizedBox(height: 13),
              Text(
                'This is an application designed to help you view if your favorite streamers are live or not in a simplified manner.',
                style: TextStyle(fontFamily: 'EduCursive'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 70),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return LoginButtonScreen();
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.all(10),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 20, fontFamily: 'LibertinusSans'),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return RegisterButtonScreen();
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.all(10),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'Register',
                  style: TextStyle(fontSize: 20, fontFamily: 'LibertinusSans'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
