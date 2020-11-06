import 'package:firebase_auth/firebase_auth.dart' as auth;


class AuthMethods {
  auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

  Future logout() async {
    _firebaseAuth.signOut();
  }

  auth.User getCurrentUser(){
    return _firebaseAuth.currentUser;
  }

  Future<auth.User> emailSignUp(String email, String password) async {
    try {
      auth.UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      return result.user;
    } catch (e) {
      print("Something went wrong" + e.toString());
      return null;
    }
  }

  Future<auth.User> emailSignIn(String email, String password) async {
    try {
      auth.UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      return result.user;
    } catch (e) {
      print("Something went wrong" + e.toString());
      return null;
    }
  }
}
