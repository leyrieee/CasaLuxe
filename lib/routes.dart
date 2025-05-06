import 'package:casaluxe/screens/main_layout.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/account_screen.dart';
import 'screens/bookings_screen.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (context) => const SplashScreen(),
  '/onboarding': (context) => const OnboardingScreen(),
  '/login': (context) => const LoginScreen(),
  '/home': (context) => const MainLayout(),
  '/profile': (context) => const Placeholder(), // dynamic version used in code
  '/phone-auth': (context) =>
      const Placeholder(), // dynamic version used in code
  '/account': (context) => const AccountScreen(),
  '/bookings': (context) => const BookingsScreen(),
};
