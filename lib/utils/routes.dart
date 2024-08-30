import 'package:flutter/material.dart';
import '../screens/home_page.dart';

Route createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const Home(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}