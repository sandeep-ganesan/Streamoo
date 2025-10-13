import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_check/auth/auth_service.dart';
import 'package:stream_check/auth/login_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    if (uid == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        title: const Text(
          'Delete account?',
          style: TextStyle(fontFamily: 'AmaticSC'),
        ),
        content: const Text(
          'This will remove your account and all your data. This action cannot be undone.',
          style: TextStyle(fontFamily: 'LibertinusSans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'LibertinusSans'),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(fontFamily: 'LibertinusSans'),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
      final streamsSnap = await userDoc.collection('streams').get();
      for (final d in streamsSnap.docs) {
        await d.reference.delete();
      }
      await userDoc.delete();
      await user!.delete();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: e.code == 'requires-recent-login'
            ? 'Please log in again to delete your account.'
            : 'Delete failed: ${e.message ?? e.code}',
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: 'Delete failed: $e',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Hello!')));
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);

    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 100, 40, 40),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: docRef.snapshots(),
          builder: (context, snap) {
            String friendlyName = user?.displayName ?? user?.email ?? 'there';
            if (snap.hasData && snap.data!.exists) {
              final data = snap.data!.data();
              final fromFs = (data?['displayName'] ?? data?['name']) as String?;
              if (fromFs != null && fromFs.trim().isNotEmpty) {
                friendlyName = fromFs.trim();
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, \n$friendlyName',
                  style: const TextStyle(fontFamily: 'AmaticSC', fontSize: 60),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.all(10),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () async {
                    bool success = await AuthService().logout();

                    if (success) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    }
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontFamily: 'LibertinusSans',
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.all(10),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _deleteAccount,
                  child: const Text(
                    'Delete Account',
                    style: TextStyle(
                      fontFamily: 'LibertinusSans',
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
