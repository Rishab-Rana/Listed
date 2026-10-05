import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../logic/events_cubit.dart';
import '../models/event_item.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});
  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _venueController = TextEditingController();
  final _capacityController = TextEditingController();
  final _notesController = TextEditingController();
  File? _coverImage;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _guestlistEnabled = true;
  bool _tablesEnabled = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _capacityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _coverImage = File(picked.path));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 22, minute: 0),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF17111F),
        elevation: 0,
        title: const Text(
            'New night', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2237),
                      borderRadius: BorderRadius.circular(14),
                      image: _coverImage != null
                          ? DecorationImage(
                          image: FileImage(_coverImage!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _coverImage == null
                        ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_a_photo,
                              color: Colors.white.withOpacity(0.4), size: 28),
                          const SizedBox(height: 8),
                          Text('Add cover photo', style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13)),
                        ],
                      ),
                    )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                _textField('Event title', _titleController,
                    hint: 'e.g. SATURDAY SESSIONS'),
                const SizedBox(height: 16),
                _textField('Venue', _venueController, hint: 'Venue name'),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickDate,
                  child: _pickerField('Date', _selectedDate == null
                      ? 'Select date'
                      : DateFormat('E, d MMM yyyy').format(_selectedDate!)),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickTime,
                  child: _pickerField('Time', _selectedTime == null
                      ? 'Select time'
                      : _selectedTime!.format(context)),
                ),
                const SizedBox(height: 16),
                _textField(
                    'Guestlist capacity', _capacityController, hint: 'e.g. 100',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                _toggleRow(
                    'Guestlist', 'Open free-entry list', _guestlistEnabled, (
                    val) => setState(() => _guestlistEnabled = val)),
                _toggleRow(
                    'Tables', 'Accept table reservations', _tablesEnabled, (
                    val) => setState(() => _tablesEnabled = val)),
                const SizedBox(height: 16),
                _textField('Entry notes', _notesController,
                    hint: 'e.g. Smart casuals, ID mandatory'),
                const SizedBox(height: 28),
                _publishButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pickerField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white.withOpacity(0.5),
            letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          height: 52,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFF2A2237),
              borderRadius: BorderRadius.circular(14)),
          child: Text(value, style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _textField(String label, TextEditingController controller,
      {String? hint, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white.withOpacity(0.5),
            letterSpacing: 0.5)),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
          ),
          validator: (value) {
            if (value == null || value
                .trim()
                .isEmpty) return 'Required';
            return null;
          },
        ),
      ],
    );
  }

  Widget _toggleRow(String title, String subtitle, bool value,
      ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white)),
                Text(subtitle, style: TextStyle(
                    fontSize: 11, color: Colors.white.withOpacity(0.4))),
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
        onPressed: _isSaving ? null : _handlePublish,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE63888),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isSaving
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Publish night', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Future<void> _handlePublish() async {
    if (_isSaving)
      return; // guards against a tap landing before setState rebuilds
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a date and time')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final eventDateTime = DateTime(
      _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
      _selectedTime!.hour, _selectedTime!.minute,
    );

    final newEvent = EventItem(
      id: '',
      title: _titleController.text.toUpperCase(),
      venue: _venueController.text,
      area: 'Gurugram',
      eventDateTime: eventDateTime,
      tag: 'Just Listed',
      capacity: int.tryParse(_capacityController.text) ?? 100,
      reserved: 0,
      notes: _notesController.text,
      gradient: const [Color(0xFFE63888), Color(0xFF4A2166)],
      guestlistEnabled: _guestlistEnabled,
      tableEnabled: _tablesEnabled,
    );

    final cubit = context.read<EventsCubit>();
    await cubit.addEvent(newEvent);

    if (_coverImage != null) {
      final saved = (cubit.state.data ?? []).firstWhere((e) =>
      e.title == newEvent.title);
      await cubit.attachCoverImage(saved.id, _coverImage!);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }
}