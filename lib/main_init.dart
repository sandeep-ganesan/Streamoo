import 'package:firebase_core/firebase_core.dart';
import 'package:stream_check/services/fcm_token_service.dart';
import 'package:stream_check/services/push_background_handler.dart';

Future<void> appInit() async {
  await Firebase.initializeApp();
  await PushHandler.init();
  await FCMTokenService.init();
}
