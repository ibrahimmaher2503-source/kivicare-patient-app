import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/nurse_request_design.dart';

class ServiceDescriptionSection extends StatefulWidget {
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
  State<ServiceDescriptionSection> createState() =>
      _ServiceDescriptionSectionState();
}

class _ServiceDescriptionSectionState
    extends State<ServiceDescriptionSection> {
  bool _isArabic = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LanguageToggle(
          isArabic: _isArabic,
          onSelect: (ar) => setState(() => _isArabic = ar),
        ),
        10.height,
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: _isArabic
              ? Directionality(
                  key: const ValueKey('ar'),
                  textDirection: TextDirection.rtl,
                  child: _buildField(
                    widget.arController,
                    locale.value.serviceDescriptionArabic,
                  ),
                )
              : Directionality(
                  key: const ValueKey('en'),
                  textDirection: TextDirection.ltr,
                  child: _buildField(
                    widget.enController,
                    locale.value.serviceDescriptionEnglish,
                  ),
                ),
        ),
        Obx(() {
          final err = widget.errorMessage.value;
          if (err == null || err.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              err,
              style: const TextStyle(color: cancelStatusColor, fontSize: 12),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      maxLength: 2000,
      decoration: nurseRequestInputDecoration(
        context,
        labelText: label,
        alignLabelWithHint: true,
      ),
      onChanged: (_) => widget.errorMessage.value = null,
    );
  }

  bool isValid() {
    final en = widget.enController.text.trim();
    final ar = widget.arController.text.trim();
    if (en.isEmpty && ar.isEmpty) {
      widget.errorMessage.value = locale.value.atLeastOneDescriptionRequired;
      return false;
    }
    if (en.length > 2000 || ar.length > 2000) {
      widget.errorMessage.value = locale.value.descriptionTooLong;
      return false;
    }
    widget.errorMessage.value = null;
    return true;
  }
}

class _LanguageToggle extends StatelessWidget {
  final bool isArabic;
  final void Function(bool isArabic) onSelect;

  const _LanguageToggle({required this.isArabic, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: nurseRequestSubtleSurface(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: nurseRequestBorderColor(context)),
      ),
      child: Row(
        children: [
          _Tab(label: 'EN', active: !isArabic, onTap: () => onSelect(false)),
          _Tab(label: 'AR', active: isArabic, onTap: () => onSelect(true)),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? gradientStart : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? whiteTextColor : nurseRequestMutedColor(context),
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
