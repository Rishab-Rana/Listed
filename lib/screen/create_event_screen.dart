import 'package:flutter/material.dart';
import '../models/event_item.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _venueController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _notesController = TextEditingController();

  bool _guestlistEnabled = true;
  bool _tablesEnabled = true;

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _capacityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF17111F),
        elevation: 0,
        title: const Text('New night', style: TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _textField('Event title', _titleController, hint: 'e.g. SATURDAY SESSIONS'),
                const SizedBox(height: 16),
                _textField('Venue', _venueController, hint: 'Venue name'),
                const SizedBox(height: 16),
                _textField('Date', _dateController, hint: 'e.g. Sat, 20 Sep'),
                const SizedBox(height: 16),
                _textField('Time', _timeController, hint: 'e.g. 10:00 PM – 3:00 AM'),
                const SizedBox(height: 16),
                _textField('Guestlist capacity', _capacityController, hint: 'e.g. 100', keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                _toggleRow('Guestlist', 'Open free-entry list', _guestlistEnabled, (val) => setState(() => _guestlistEnabled = val)),
                _toggleRow('Tables', 'Accept table reservations', _tablesEnabled, (val) => setState(() => _tablesEnabled = val)),
                const SizedBox(height: 16),
                _textField('Entry notes', _notesController, hint: 'e.g. Smart casuals, ID mandatory'),
                const SizedBox(height: 28),
                _publishButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller, {String? hint, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.5), letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
            filled: true,
            fillColor: const Color(0xFF2A2237),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Required';
            return null;
          },
        ),
      ],
    );
  }

  Widget _toggleRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFE63888),
          ),
        ],
      ),
    );
  }

  Widget _publishButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _handlePublish,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE63888),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text('Publish night', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  void _handlePublish() {
    if (_formKey.currentState!.validate()) {
      final newEvent = EventItem(
        title: _titleController.text.toUpperCase(),
        venue: _venueController.text,
        area: 'Gurugram',
        date: _dateController.text,
        time: _timeController.text,
        tag: 'Just Listed',
        capacity: int.tryParse(_capacityController.text) ?? 100,
        reserved: 0,
        notes: _notesController.text,
        gradient: const [Color(0xFFE63888), Color(0xFF4A2166)],
      );
      dummyEvents.insert(0, newEvent);
      Navigator.pop(context);
    }
  }
}