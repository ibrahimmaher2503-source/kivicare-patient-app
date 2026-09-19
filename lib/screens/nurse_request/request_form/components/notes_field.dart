import 'package:flutter/material.dart';
import 'package:kivicare_patient/main.dart';

import '../../components/nurse_request_design.dart';

class NotesField extends StatelessWidget {
  final TextEditingController controller;

  const NotesField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      maxLength: 2000,
      decoration: nurseRequestInputDecoration(
        context,
        labelText: locale.value.patientNotes,
        alignLabelWithHint: true,
      ),
    );
  }
}
