import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/main.dart';
import 'package:nb_utils/nb_utils.dart';

class ServiceDescriptionSection extends StatelessWidget {
  final TextEditingController enController;
  final TextEditingController arController;
  final RxnString errorMessage;

  const ServiceDescriptionSection({
    super.key,
    required this.enController,
    required this.arController,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: TextFormField(
            controller: enController,
            maxLines: 4,
            maxLength: 2000,
            decoration: InputDecoration(
              labelText: locale.value.serviceDescriptionEnglish,
              alignLabelWithHint: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              counterText: '',
            ),
            onChanged: (_) => errorMessage.value = null,
          ),
        ),
        8.height,
        Directionality(
          textDirection: TextDirection.rtl,
          child: TextFormField(
            controller: arController,
            maxLines: 4,
            maxLength: 2000,
            decoration: InputDecoration(
              labelText: locale.value.serviceDescriptionArabic,
              alignLabelWithHint: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              counterText: '',
            ),
            onChanged: (_) => errorMessage.value = null,
          ),
        ),
        Obx(() {
          final err = errorMessage.value;
          if (err == null || err.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(err, style: const TextStyle(color: Colors.red, fontSize: 12)),
          );
        }),
      ],
    );
  }

  bool isValid() {
    final en = enController.text.trim();
    final ar = arController.text.trim();
    if (en.isEmpty && ar.isEmpty) {
      errorMessage.value = locale.value.atLeastOneDescriptionRequired;
      return false;
    }
    if (en.length > 2000) {
      errorMessage.value = locale.value.descriptionTooLong;
      return false;
    }
    if (ar.length > 2000) {
      errorMessage.value = locale.value.descriptionTooLong;
      return false;
    }
    errorMessage.value = null;
    return true;
  }
}
