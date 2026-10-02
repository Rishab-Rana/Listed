import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listed/screen/pass_screen.dart';
import '../core/base_state.dart';
import '../logic/auth_cubit.dart';
import '../logic/reservation_cubit.dart';
import '../models/reservation.dart';

class MyPassesScreen extends StatefulWidget {
  const MyPassesScreen({super.key});

  @override
  State<MyPassesScreen> createState() => _MyPassesScreenState();
}

class _MyPassesScreenState extends State<MyPassesScreen> {
  late final ReservationCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ReservationCubit>();
    final userId = context.read<AuthCubit>().state.data!.uid;
    _cubit.loadForUser(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF17111F),
        elevation: 0,
        title: const Text('My Passes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: BlocBuilder<ReservationCubit, BaseState<List<Reservation>>>(
        bloc: _cubit,
        builder: (context, state) {
          final passes = state.data ?? [];
          return passes.isEmpty ? _emptyState() : _passList(passes);
        },
      ),
    );
  }

  Widget _passList(List<Reservation> passes) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: passes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _miniTicket(passes[index]),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No passes yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.7))),
            const SizedBox(height: 8),
            Text(
              "Reserve your spot on a guestlist or table and it'll show up here — ready to show at the door.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.6, color: Colors.white.withOpacity(0.4)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniTicket(Reservation r) {
    final event = r.event;
    return GestureDetector(
      onTap: () => _reopenPass(context, r),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF201A2B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 74,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: event.gradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
                    const SizedBox(height: 3),
                    Text('${event.venue} · ${event.date}', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
                    const SizedBox(height: 6),
                    const Text('✓ CONFIRMED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF6BBF8C))),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  void _reopenPass(BuildContext context, Reservation r) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PassScreen(
        event: r.event,
        reserveType: r.type,
        partySize: r.partySize,
      )),
    );
  }
}