import 'package:abroadready/features/auth/data/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'service_locator.dart';

Future<void> setupDependencies() async {
  _registerExternalDependencies();
  _registerDataSources();
  _registerRepositories();
  _registerUseCases();
  _registerPresentationLayer();
}

void _registerExternalDependencies() {
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
}

void _registerDataSources() {
  sl.registerLazySingleton<AuthService>(
    () => AuthService(firebaseAuth: sl(), firestore: sl()),
  );
}

void _registerRepositories() {
  // Add repository registrations here.
}

void _registerUseCases() {
  // Add use case registrations here.
}

void _registerPresentationLayer() {
  // Add state management registrations here.
}
