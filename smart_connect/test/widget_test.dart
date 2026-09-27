// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_connect/auth/auth_service.dart';

void main() {
  test('registers a user and rejects duplicate email addresses', () async {
    final service = AuthService();
    await service.register(
      'John',
      'Doe',
      'person@example.com',
      'password123',
      25,
      'Male',
    );

    expect(
      () => service.register(
        'Jane',
        'Smith',
        'person@example.com',
        'another123',
        30,
        'Female',
      ),
      throwsA(isA<AuthException>()),
    );
  });

  test('logs in only with the registered password', () async {
    final service = AuthService();
    await service.register(
      'John',
      'Doe',
      'person@example.com',
      'password123',
      25,
      'Male',
    );

    expect(
      (await service.login('person@example.com', 'password123')).email,
      'person@example.com',
    );
    expect(
      () => service.login('person@example.com', 'wrongpass'),
      throwsA(isA<AuthException>()),
    );
  });
}
