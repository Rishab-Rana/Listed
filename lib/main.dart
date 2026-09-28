import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listed/screen/login_screen.dart';
import 'data/events_repository.dart';
import 'logic/events_cubit.dart';
import 'logic/reservation_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => EventsCubit(EventsRepository())..loadEvents()),
        BlocProvider(create: (_) => ReservationCubit()),
      ],
      child: const ListedApp(),
    ),
  );
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
      home: LoginScreen()
    );
  }
}