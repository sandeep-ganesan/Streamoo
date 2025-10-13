import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMTokenService {
  static StreamSubscription? _authSub;

  static Future<void> init() async {
    // iOS permission prompt is ignored on Android; harmless to call once.
    await FirebaseMessaging.instance.requestPermission();

    // Register immediately if signed in.
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _registerCurrentToken(user.uid);
    }

    // Listen for login/logout and token refresh.
    _authSub?.cancel();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((u) async {
      if (u == null) return;
      await _registerCurrentToken(u.uid);
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await _saveToken(uid, token);
    });
  }

  static Future<void> _registerCurrentToken(String uid) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;
    await _saveToken(uid, token);
  }

  static Future<void> _saveToken(String uid, String token) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final arr =
          (snap.data()?['fcmTokens'] as List?)?.cast<String>() ?? <String>[];
      if (!arr.contains(token)) {
        arr.add(token);
        tx.set(userRef, {'fcmTokens': arr}, SetOptions(merge: true));
      }
    });

    final subRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('fcmTokens')
        .doc(token);

    await subRef.set({
      'token': token,
      'platform': 'android',
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  static Future<void> dispose() async {
    await _authSub?.cancel();
    _authSub = null;
  }
}
