import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'local/app_database.dart';
import 'local/product_note_local_data_source.dart';
import 'pages/auth_gate.dart';
import 'remote/product_note_remote_data_source.dart';
import 'repositories/product_note_repository.dart';
import 'services/auth_service.dart';
import 'services/crash/crash_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final crashService = const CrashService();
  await crashService.configure();

  final database = AppDatabase();
  final local = ProductNoteLocalDataSource(database);
  final remote = ProductNoteRemoteDataSource(FirebaseFirestore.instance);
  final noteRepository = ProductNoteRepository(local: local, remote: remote);

  final authService = FirebaseAuthService();

  runApp(
    MyApp(
      noteRepository: noteRepository,
      authService: authService,
      crashService: crashService,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.noteRepository,
    required this.authService,
    required this.crashService,
  });

  final ProductNoteRepository noteRepository;
  final AuthService authService;
  final CrashService crashService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Productos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: AuthGate(
        authService: authService,
        noteRepository: noteRepository,
        crashService: crashService,
      ),
    );
  }
}
