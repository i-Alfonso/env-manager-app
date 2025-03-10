import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';

void main() {
  runApp(
    MaterialApp(
      initialRoute: "/login",
      routes: {
        "/home": (context) => const HomePage(),
        "/login": (context) => const LoginPage(),
      },
    ),
  );
}
