import 'package:flutter/material.dart';
import 'package:stream_check/auth/auth_service.dart';

class RegisterButtonScreen extends StatefulWidget {
  const RegisterButtonScreen({super.key});

  @override
  State<RegisterButtonScreen> createState() => _RegisterButtonScreenState();
}

class _RegisterButtonScreenState extends State<RegisterButtonScreen> {
  bool obscureText = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: Padding(
        padding: EdgeInsets.fromLTRB(40, 70, 40, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Join Us Here!',
              style: TextStyle(fontFamily: 'AmaticSC', fontSize: 60),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 10),
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
                String name = nameController.text.trim();
                String email = emailController.text.trim();
                String password = passwordController.text.trim();

                bool confirmation = await AuthService().signup(
                  email: email,
                  password: password,
                  name: name,
                );

                if (confirmation) {
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
              style: ElevatedButton.styleFrom(
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.all(10),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                'Register',
                style: TextStyle(fontFamily: 'LibertinusSans', fontSize: 18),
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Password Requirements: ',
              style: TextStyle(fontFamily: 'AmaticSC', fontSize: 26),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsetsGeometry.fromLTRB(25, 0, 0, 0),
              child: Text(
                '\u2022 contains atleast 8 characters',
                style: TextStyle(fontFamily: 'EduCursive', fontSize: 14),
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.fromLTRB(25, 0, 0, 0),
              child: Text(
                '\u2022 contains atleast one uppercase letter',
                style: TextStyle(fontFamily: 'EduCursive', fontSize: 14),
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.fromLTRB(25, 0, 0, 0),
              child: Text(
                '\u2022 contains atleast one lowercase letter',
                style: TextStyle(fontFamily: 'EduCursive', fontSize: 14),
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.fromLTRB(25, 0, 0, 0),
              child: Text(
                '\u2022 contains atleast one number',
                style: TextStyle(fontFamily: 'EduCursive', fontSize: 14),
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.fromLTRB(25, 0, 0, 0),
              child: Text(
                '\u2022 contains atleast one symbol',
                style: TextStyle(fontFamily: 'EduCursive', fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
