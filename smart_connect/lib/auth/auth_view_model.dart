import 'package:flutter/foundation.dart';

import 'auth_service.dart';
import 'user.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._service);

  final AuthService _service;
  User? user;
  bool isLoading = false;
  String? errorMessage;

  Future<bool> register(
    String firstName,
    String lastName,
    String email,
    String password,
    int age,
    String gender,
  ) async {
    return _run(
      () =>
          _service.register(firstName, lastName, email, password, age, gender),
    );
  }

  Future<bool> login(String email, String password) async {
    return _run(() => _service.login(email, password));
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<void> logout() async {
    await _service.logout();
    user = null;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    final currentUser = user;
    if (currentUser != null) _service.deleteAccount(currentUser.email);
    logout();
  }

  Future<bool> _run(Future<User> Function() operation) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      user = await operation();
      return true;
    } on AuthException catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
