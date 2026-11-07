import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_clase/pages/login_page.dart';
import 'package:practica_clase/services/auth_service.dart';

class FakeAuthService implements AuthService {
  @override
  Stream<User?> authStateChanges() => const Stream.empty();

  @override
  Future<void> login({required String email, required String password}) async {}

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('muestra error con correo vacío', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: LoginPage(authService: FakeAuthService())),
    );

    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    expect(find.text('El correo es obligatorio'), findsOneWidget);
  });
}
