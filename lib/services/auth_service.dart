import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? currentUser;

  Future<User?> signInAdmin() async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: 'admin123@gmail.com',
        password: 'admin123',
      );
      currentUser = cred.user;
      return currentUser;
    } catch (e) {
      print('Admin login failed: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    currentUser = null;
  }
}
