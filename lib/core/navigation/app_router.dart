import 'package:abroadready/core/firestore/schemas/university_schema.dart';
import 'package:abroadready/core/navigation/app_routes.dart';
import 'package:abroadready/features/auth/presentation/screens/login_screen.dart';
import 'package:abroadready/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:abroadready/features/home/presentation/screens/home_screen.dart';
import 'package:abroadready/features/home/presentation/screens/profile_screen.dart';
import 'package:abroadready/features/home/presentation/screens/university_detail_screen.dart';
import 'package:abroadready/features/home/presentation/screens/university_list_screen.dart';
import 'package:abroadready/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:abroadready/features/profile_setup/presentation/screens/profile_setup_screen.dart';
import 'package:abroadready/features/search/presentation/screens/university_search_screen.dart';
import 'package:abroadready/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.welcome:
        return _page(const WelcomeScreen(), settings);
      case AppRoutes.home:
        return _page(const HomeScreen(), settings);
      case AppRoutes.universityList:
        return _page(const UniversityListScreen(), settings);
      case AppRoutes.universitySearch:
        return _page(const UniversitySearchScreen(), settings);
      case AppRoutes.login:
        return _page(const LoginScreen(), settings);
      case AppRoutes.signUp:
        return _page(const SignUpScreen(), settings);
      case AppRoutes.profileSetup:
        return _page(const ProfileSetupScreen(), settings);
      case AppRoutes.profile:
        return _page(const ProfileScreen(), settings);
      case AppRoutes.universityDetail:
        final university = settings.arguments as UniversityEntity;
        return _page(UniversityDetailScreen(university: university), settings);
      case AppRoutes.splash:
      default:
        return _page(const SplashScreen(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _page(
    Widget child,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => child,
      settings: settings,
    );
  }
}
