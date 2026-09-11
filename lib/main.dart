import 'package:flutter/material.dart';
import 'package:listed/screen/login_screen.dart';

void main() {
  runApp(const ListedApp());
}

class ListedApp extends StatelessWidget {
  const ListedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Listed',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF17111F),
        useMaterial3: true,
      ),
      home: const Scaffold(body: Center(child: LoginScreen())),
    );
  }
}
