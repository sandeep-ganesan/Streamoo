import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:home_widget/home_widget.dart';
import 'package:stream_check/widget/live_widget_controller.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final data = message.data;
  if (data['type'] == 'streams_updated') {
    final uid = data['uid'];
    if (uid is String && uid.isNotEmpty) {
      await LiveWidgetController.updateFromFirestore(uid);
    }
  }
}

class PushHandler {
  static StreamSubscription<RemoteMessage>? _sub;

  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    _sub?.cancel();
    _sub = FirebaseMessaging.onMessage.listen((msg) async {
      final data = msg.data;
      if (data['type'] == 'streams_updated') {
        final uid = data['uid'];
        if (uid is String && uid.isNotEmpty) {
          await LiveWidgetController.updateFromFirestore(uid);
        }
      }
    });

    await HomeWidget.setAppGroupId(''); // Android: keep empty
  }

  static Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}
