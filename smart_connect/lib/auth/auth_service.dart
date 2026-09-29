import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'user.dart';
import '../services/database_service.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}

// Firebase Authentication service
class AuthService {
  final DatabaseService _database = DatabaseService();
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  User? getCurrentUser() {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return User(
      firstName: firebaseUser.displayName?.split(' ')[0] ?? '',
      lastName: firebaseUser.displayName?.split(' ').skip(1).join(' ') ?? '',
      email: firebaseUser.email ?? '',
      password: '',
      age: 0,
      gender: '',
    );
  }

  void deleteAccount(String email) {
    final user = _auth.currentUser;
    if (user != null) {
      _database.deleteUserData(user.uid);
      user.delete();
    }
  }

  Future<User> register(
    String firstName,
    String lastName,
    String email,
    String password,
    int age,
    String gender,
  ) async {
    try {
      print('Firebase Auth: Attempting to register user with email: $email');
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('Firebase Auth: User created successfully: ${credential.user?.uid}');
      
      await credential.user?.updateDisplayName('$firstName $lastName');
      // Save user data to Realtime Database
      if (credential.user?.uid != null) {
        print('Firebase Auth: About to save user data to database');
        try {
          await _database.saveUserData(
            userId: credential.user!.uid,
            firstName: firstName,
            lastName: lastName,
            email: email,
            age: age,
            gender: gender,
          );
          print('Firebase Auth: User data saved to database successfully');
        } catch (e) {
          print('Firebase Auth: Database save failed - $e');
          // Don't throw - allow registration to succeed even if database fails
        }
      } else {
        print('Firebase Auth: User UID is null, skipping database save');
      }
      return User(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        age: age,
        gender: gender,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      if (e.code == 'email-already-in-use') {
        throw const AuthException('That email is already registered.');
      } else if (e.code == 'weak-password') {
        throw const AuthException('The password provided is too weak.');
      } else {
        throw AuthException(e.message ?? 'Registration failed.');
      }
    } catch (e) {
      print('Unexpected error during registration: $e');
      throw AuthException('Registration failed: $e');
    }
  }

  Future<User> login(String email, String password) async {
    try {
      print('Firebase Auth: Attempting to login user with email: $email');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('Login failed.');
      }
      
      print('Firebase Auth: Login successful for user: ${firebaseUser.uid}');
      
      final displayName = firebaseUser.displayName ?? '';
      final nameParts = displayName.split(' ');
      
      return User(
        firstName: nameParts.isNotEmpty ? nameParts[0] : '',
        lastName: nameParts.length > 1 ? nameParts.skip(1).join(' ') : '',
        email: firebaseUser.email ?? email,
        password: password,
        age: 0,
        gender: '',
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw const AuthException('Email or password is incorrect.');
      } else {
        throw AuthException(e.message ?? 'Login failed.');
      }
    } catch (e) {
      print('Unexpected error during login: $e');
      throw AuthException('Login failed: $e');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
