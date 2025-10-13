import 'package:flutter/material.dart';
import 'package:stream_check/auth/auth_service.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: Padding(
        padding: EdgeInsetsGeometry.fromLTRB(40, 100, 40, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reset your password here',
              style: TextStyle(fontFamily: 'AmaticSC', fontSize: 60),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.all(10),
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () async {
                String email = emailController.text.trim();

                bool confirmation = await AuthService().passwordReset(
                  email: email,
                );

                if (confirmation) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(5),
                        ),
                        title: Text(
                          'Password Reset',
                          style: TextStyle(
                            fontFamily: 'AmaticSC',
                            fontSize: 28,
                          ),
                        ),
                        content: Text(
                          'An email containing instructions to reset your password has been sent. Please check your email and follow its instructions.',
                          style: TextStyle(
                            fontFamily: 'LibertinusSans',
                            fontSize: 16,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
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
                        ],
                      );
                    },
                  );
                }
              },
              child: Text(
                'Reset',
                style: TextStyle(fontFamily: 'LibertinusSans', fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
