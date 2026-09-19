import 'package:flutter/material.dart';
import 'package:kivicare_patient/main.dart';

import '../../components/nurse_request_design.dart';

class ContactSection extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;

  const ContactSection({super.key, required this.controller, this.errorText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLength: 20,
      keyboardType: TextInputType.phone,
      decoration: nurseRequestInputDecoration(
        context,
        labelText: '${locale.value.contactPhone} *',
        errorText: errorText,
      ),
    );
  }
}
