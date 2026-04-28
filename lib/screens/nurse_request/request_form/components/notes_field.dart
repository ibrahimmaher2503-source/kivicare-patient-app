import 'package:flutter/material.dart';
import 'package:kivicare_patient/main.dart';

class NotesField extends StatelessWidget {
  final TextEditingController controller;

  const NotesField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      maxLength: 2000,
      decoration: InputDecoration(
        labelText: locale.value.patientNotes,
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        counterText: '',
      ),
    );
  }
}
