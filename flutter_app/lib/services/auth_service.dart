import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _google = GoogleSignIn();

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStream => _auth.authStateChanges();

  // Email signup
  static Future<UserCredential> signUp(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  // Email login
  static Future<UserCredential> login(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  // Google login
  static Future<UserCredential?> googleSignIn() async {
    final account = await _google.signIn();
    if (account == null) return null;
    final gAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  // Forgot password
  static Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  // Logout
  static Future<void> logout() async {
    await _google.signOut();
    await _auth.signOut();
  }
}
