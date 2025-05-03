import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login Method
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception("No user found for that email.");
      } else if (e.code == 'wrong-password') {
        throw Exception("Wrong password provided.");
      } else {
        throw Exception(e.message ?? "Login failed.");
      }
    }
  }
}
