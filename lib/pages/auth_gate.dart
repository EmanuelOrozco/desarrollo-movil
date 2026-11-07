import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../product_screen.dart';
import '../repositories/product_note_repository.dart';
import '../services/auth_service.dart';
import '../services/crash/crash_service.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.authService,
    required this.noteRepository,
    required this.crashService,
  });

  final AuthService authService;
  final ProductNoteRepository noteRepository;
  final CrashService crashService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('No fue posible validar la sesión')),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return LoginPage(authService: authService);
        }

        unawaited(crashService.setUserIdentifier(user.uid));

        return ProductScreen(
          noteRepository: noteRepository,
          authService: authService,
          crashService: crashService,
        );
      },
    );
  }
}
