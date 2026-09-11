import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedChip = 0;
  final List<String> _chips = ['All', 'Tonight', 'This weekend', 'Guestlist open', 'Tables'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📍 Gurugram, Delhi NCR',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tonight's Lineup",
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.person, color: Colors.white),
                          style: IconButton.styleFrom(backgroundColor: const Color(0xFF2A2237), shape: const CircleBorder()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _searchBar(),
                    const SizedBox(height: 14),
                    _chipRow(),
                  ],
                ),
              ),
              // featured row + event list go here — next chunk
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2237),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white54, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search venues, nights, areas',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipRow() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedChip == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedChip = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE63888).withOpacity(0.15) : const Color(0xFF2A2237),
                border: Border.all(color: isSelected ? const Color(0xFFE63888) : Colors.transparent, width: 1.5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                _chips[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFFE63888) : Colors.white70,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}