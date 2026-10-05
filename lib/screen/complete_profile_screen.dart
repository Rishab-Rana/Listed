import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../logic/user_cubit.dart';
import 'main_shell.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'Male';
  File? _photo;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    String? photoUrl;
    if (_photo != null) {
      photoUrl = await context.read<UserCubit>().uploadProfilePhoto(_photo!);
    }

    await context.read<UserCubit>().completeProfile(
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      gender: _gender,
      photoUrl: photoUrl,
    );

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(settings: const RouteSettings(name: '/main'), builder: (_) => const MainShell()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17111F),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                const Text('Tell us about you', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Takes 30 seconds — only once.', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
                const SizedBox(height: 32),
                _photoPicker(),
                const SizedBox(height: 28),
                _fieldLabel('Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration('Your full name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                ),
                const SizedBox(height: 18),
                _fieldLabel('Age'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration('e.g. 24'),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 18 || n > 100) return 'Enter a valid age (18+)';
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _fieldLabel('Gender'),
                const SizedBox(height: 8),
                _genderSelector(),
                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE63888),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSaving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _photoPicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickPhoto,
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2A2237),
            image: _photo != null ? DecorationImage(image: FileImage(_photo!), fit: BoxFit.cover) : null,
          ),
          child: _photo == null
              ? Icon(Icons.add_a_photo, color: Colors.white.withOpacity(0.4), size: 26)
              : null,
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(text.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.5), letterSpacing: 0.5));
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
      filled: true,
      fillColor: const Color(0xFF2A2237),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    );
  }

  Widget _genderSelector() {
    final options = ['Male', 'Female', 'Other'];
    return Row(
      children: options.map((option) {
        final isSelected = _gender == option;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _gender = option),
            child: Container(
              margin: EdgeInsets.only(right: option != options.last ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE63888).withOpacity(0.1) : const Color(0xFF2A2237),
                border: Border.all(color: isSelected ? const Color(0xFFE63888) : Colors.transparent, width: 1.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(option, style: TextStyle(color: isSelected ? const Color(0xFFE63888) : Colors.white70, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        );
      }).toList(),
    );
  }
}