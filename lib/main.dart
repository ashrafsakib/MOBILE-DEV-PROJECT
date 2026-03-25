import 'package:abroadready/core/navigation/app_router.dart';
import 'package:abroadready/core/navigation/app_routes.dart';
import 'package:abroadready/core/theme/app_theme.dart';
import 'package:abroadready/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AbroadReady',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.abroadReadyTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
