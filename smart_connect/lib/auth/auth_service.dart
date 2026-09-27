import 'user.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}

// This in-memory service stands in for a remote authentication backend.
class AuthService {
  final Map<String, User> _users = {};

  void deleteAccount(String email) {
    _users.remove(email);
  }

  Future<User> register(
    String firstName,
    String lastName,
    String email,
    String password,
    int age,
    String gender,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (_users.containsKey(email)) {
      throw const AuthException('That email is already registered.');
    }
    final user = User(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      age: age,
      gender: gender,
    );
    _users[email] = user;
    return user;
  }

  Future<User> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final user = _users[email];
    if (user == null || user.password != password) {
      throw const AuthException('Email or password is incorrect.');
    }
    return user;
  }
}
