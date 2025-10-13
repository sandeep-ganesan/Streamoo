import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum loginResult { success, emailNotVerified, error }

class AuthService {
  Future<bool> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    bool completion = false;
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.sendEmailVerification();
        await user.reload();
      }

      return completion = true;
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password does not meet the requirements.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The provided E-Mail is already registered. Please login';
      } else if (e.code == 'invalid-email') {
        message = 'The provided email is invalid.';
      }

      Fluttertoast.showToast(msg: message, timeInSecForIosWeb: 2);
      return completion;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An unexpected error occurred: ${e.toString()}",
        timeInSecForIosWeb: 2,
      );
      return completion;
    }
  }

  Future<loginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        await FirebaseAuth.instance.signOut();
        return loginResult.emailNotVerified;
      }
      return loginResult.success;
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = "The email is not in the correct format. Please try again";
      } else if (e.code == 'user-not-found') {
        message =
            "The entered email ID is not associated with any user. Please Register.";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect Password. Please try again";
      } else if (e.code == 'invalid-credential') {
        message =
            "Invalid credentials provided. Please check your email and password.";
      } else {
        message = "Error : ${e.toString()}, Could not log in";
      }
      Fluttertoast.showToast(msg: message, timeInSecForIosWeb: 2);
      return loginResult.error;
    } catch (e) {
      Fluttertoast.showToast(msg: "Error : ${e.toString()}, Could not log in");
      return loginResult.error;
    }
  }

  Future<void> resendVerification({
    required String email,
    required String password,
  }) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      await FirebaseAuth.instance.signOut();
    }
  }

  Future<bool> passwordReset({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'The provided email is not in a valid format.';
      } else {
        message = 'An error has occured.';
      }
      Fluttertoast.showToast(msg: message, timeInSecForIosWeb: 2);
      return false;
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error : ${e.toString()}',
        timeInSecForIosWeb: 2,
      );
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      await auth.signOut();
      return true;
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'network-request-failed') {
        message = 'No network connected. Please try again.';
      } else {
        message = 'An error has occured.';
      }
      Fluttertoast.showToast(msg: message, timeInSecForIosWeb: 2);
      return false;
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error : ${e.toString()}',
        timeInSecForIosWeb: 2,
      );
      return false;
    }
  }
}
