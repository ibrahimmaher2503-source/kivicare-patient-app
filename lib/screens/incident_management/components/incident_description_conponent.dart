import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';

class IncidentDescriptionComponent extends StatelessWidget {
  final String title;
  final String description;

  const IncidentDescriptionComponent({super.key, required this.description, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: isDarkMode.value ? Colors.white : primaryTextColor,
          ),
        ),
        8.height,
        Text(
          description,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            letterSpacing: 0.1,
            color: secondaryTextColor,
          ),
        ),
      ],
    );
  }
}
