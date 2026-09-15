import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listed/screen/login_screen.dart';
import 'package:listed/screen/main_shell.dart';

import 'logic/events_cubit.dart';

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
      // home: const MainShell(),
      home: BlocProvider(
        create: (_) => EventsCubit()..loadEvents(),
        child: const LoginScreen(),
      ),
    );
  }
}