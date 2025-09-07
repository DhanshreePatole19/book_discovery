import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  static bool get isLoggedIn => _auth.currentUser != null;

  // Login method
  static Future<UserCredential?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Clear the manual logout flag on successful login
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('manually_logged_out', false);

      return result;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Register method
  static Future<UserCredential?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Clear the manual logout flag on successful registration
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('manually_logged_out', false);

      return result;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  // Logout method
  static Future<void> logout() async {
    try {
      // First, sign out from Firebase
      await _auth.signOut();

      // Then try to set the manual logout flag
      // If this fails, the logout will still work
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('manually_logged_out', true);
      } catch (e) {
        print('SharedPreferences error during logout: $e');
        // Don't throw error here - logout should still succeed
      }

      print('Logout successful');
    } catch (e) {
      print('Logout error: $e');
      throw e; // Re-throw Firebase Auth errors
    }
  }

   static Future<void> logoutSimple() async {
    try {
      await _auth.signOut();
      print('Simple logout successful');
    } catch (e) {
      print('Simple logout error: $e');
      throw e;
    }
  }

  // Check authentication state
  static Future<bool> checkAuthState() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool hasManuallyLoggedOut = prefs.getBool('manually_logged_out') ?? false;

      // If user manually logged out, return false
      if (hasManuallyLoggedOut) {
        return false;
      }

      // Check Firebase Auth state
      return _auth.currentUser != null;
    } catch (e) {
      print('Auth state check error: $e');
      return false;
    }
  }

  // Listen to auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Clear all auth data (for testing purposes)
  static Future<void> clearAuthData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('manually_logged_out');
    await _auth.signOut();
  }
}
