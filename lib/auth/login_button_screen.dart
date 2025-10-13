import 'package:flutter/material.dart';
import 'package:stream_check/auth/auth_service.dart';
import 'package:stream_check/auth/password_reset_screen.dart';
import 'package:stream_check/home_screen.dart';

class LoginButtonScreen extends StatefulWidget {
  const LoginButtonScreen({super.key});

  @override
  State<LoginButtonScreen> createState() => _LoginButtonScreenState();
}

class _LoginButtonScreenState extends State<LoginButtonScreen> {
  bool obscureText = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: Padding(
        padding: EdgeInsets.fromLTRB(40, 100, 40, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back!',
              style: TextStyle(fontFamily: 'AmaticSC', fontSize: 60),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 50),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: obscureText,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String email = emailController.text.trim();
                String password = passwordController.text.trim();

                final result = await AuthService().login(
                  email: email,
                  password: password,
                );

                if (result == loginResult.success) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (Route<dynamic> route) => false,
                  );
                } else if (result == loginResult.emailNotVerified) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        title: Text(
                          'Email Verification',
                          style: TextStyle(
                            fontFamily: 'AmaticSC',
                            fontSize: 28,
                          ),
                        ),
                        content: Text(
                          'An email has been sent to your given email address, please verify your email before logging in.',
                          style: TextStyle(
                            fontFamily: 'LibertinusSans',
                            fontSize: 16,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'OK',
                              style: TextStyle(
                                fontFamily: 'LibertinusSans',
                                fontSize: 18,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              AuthService().resendVerification(
                                email: email,
                                password: password,
                              );
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Resend Email',
                              style: TextStyle(
                                fontFamily: 'LibertinusSans',
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
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
                style: TextStyle(fontFamily: 'LibertinusSans', fontSize: 18),
              ),
            ),
            const SizedBox(height: 25),
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return PasswordResetScreen();
                    },
                  ),
                );
              },
              child: Center(child: Text('Can\'t sign in?')),
            ),
          ],
        ),
      ),
    );
  }
}
