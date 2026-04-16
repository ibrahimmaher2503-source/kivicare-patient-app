import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import 'components/booking_method_section.dart';
import 'components/doctor_qualification_card.dart';
import 'components/doctor_review_card.dart';
import 'model/unified_doctor_model.dart';
import 'unified_doctor_detail_controller.dart';

/// Unified tabbed doctor detail screen — Book / About / Reviews / Qualifications.
/// Controller loads booking capabilities from 3 parallel API calls on init.
class UnifiedDoctorDetailScreen extends StatelessWidget {
  final UnifiedDoctor doctor;

  const UnifiedDoctorDetailScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UnifiedDoctorDetailController(doctor: doctor));

    return AppScaffoldNew(
      appBartitleText: doctor.fullName,
      hasLeadingWidget: true,
      appBarVerticalSize: Get.height * 0.12,
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: false,
                      labelColor: appColorPrimary,
                      unselectedLabelColor: secondaryTextColor,
                      indicatorColor: appColorPrimary,
                      labelStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      tabs: [
                        Tab(text: locale.value.bookNow),
                        Tab(text: locale.value.about),
                        Tab(text: locale.value.reviews),
                        Tab(text: locale.value.qualification),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _BookTab(controller: controller),
                          _AboutTab(controller: controller),
                          _ReviewsTab(controller: controller),
                          _QualificationsTab(controller: controller),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ─── Tab placeholders (to be implemented in T024-T027) ───────────────────────

class _BookTab extends StatelessWidget {
  final UnifiedDoctorDetailController controller;
  const _BookTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoaderWidget();
      }
      if (controller.capabilities.isEmpty) {
        return Center(
          child: Text(locale.value.noDataFound, style: primaryTextStyle()),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.capabilities.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return BookingMethodSection(
            capability: controller.capabilities[index],
            controller: controller,
          );
        },
      );
    });
  }
}

class _AboutTab extends StatelessWidget {
  final UnifiedDoctorDetailController controller;
  const _AboutTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingDetails.value) {
        return const LoaderWidget();
      }
      final bool dark = isDarkMode.value;
      final doc = controller.doctor;
      final full = controller.fullDoctorData.value;
      final bio = (full?.aboutSelf.isNotEmpty == true)
          ? full!.aboutSelf
          : (full?.description.isNotEmpty == true)
              ? full!.description
              : '';
      final address = full?.address ?? '';
      final facebook = full?.facebookLink ?? '';
      final instagram = full?.instagramLink ?? '';
      final twitter = full?.twitterLink ?? '';
      final hasSocial = facebook.isNotEmpty || instagram.isNotEmpty || twitter.isNotEmpty;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bio.isNotEmpty) ...[
              Text(
                locale.value.about,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: dark ? Colors.white : primaryTextColor,
                ),
              ),
              8.height,
              Text(
                bio,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  height: 1.6,
                  color: secondaryTextColor,
                ),
              ),
              16.height,
            ],
            Text(
              locale.value.contactInfo,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: dark ? Colors.white : primaryTextColor,
              ),
            ),
            12.height,
            if (doc.mobile.isNotEmpty)
              _InfoRow(icon: Icons.phone_rounded, text: doc.mobile, dark: dark),
            if (doc.email.isNotEmpty)
              _InfoRow(icon: Icons.email_rounded, text: doc.email, dark: dark),
            if (address.isNotEmpty)
              _InfoRow(icon: Icons.location_on_rounded, text: address, dark: dark),
            if (hasSocial) ...[
              16.height,
              Text(
                locale.value.socialMedia,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: dark ? Colors.white : primaryTextColor,
                ),
              ),
              12.height,
              Row(
                children: [
                  if (facebook.isNotEmpty)
                    _SocialButton(
                      icon: Icons.facebook_rounded,
                      url: facebook,
                      color: const Color(0xFF1877F2),
                    ),
                  if (instagram.isNotEmpty)
                    _SocialButton(
                      icon: Icons.camera_alt_rounded,
                      url: instagram,
                      color: const Color(0xFFE1306C),
                    ),
                  if (twitter.isNotEmpty)
                    _SocialButton(
                      icon: Icons.alternate_email_rounded,
                      url: twitter,
                      color: const Color(0xFF1DA1F2),
                    ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool dark;

  const _InfoRow({required this.icon, required this.text, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: appColorPrimary),
          8.width,
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: dark ? Colors.white70 : secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String url;
  final Color color;

  const _SocialButton({required this.icon, required this.url, required this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color, size: 28),
      onPressed: () async {
        final uri = Uri.tryParse(url);
        if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  final UnifiedDoctorDetailController controller;
  const _ReviewsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingDetails.value) {
        return const LoaderWidget();
      }
      final reviews = controller.fullDoctorData.value?.reviews ?? [];
      if (reviews.isEmpty) {
        return Center(
          child: Text(locale.value.noDataFound, style: primaryTextStyle()),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => DoctorReviewCard(doctorReviewData: reviews[i]),
      );
    });
  }
}

class _QualificationsTab extends StatelessWidget {
  final UnifiedDoctorDetailController controller;
  const _QualificationsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingDetails.value) {
        return const LoaderWidget();
      }
      final quals = controller.fullDoctorData.value?.qualifications ?? [];
      if (quals.isEmpty) {
        return Center(
          child: Text(locale.value.noDataFound, style: primaryTextStyle()),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: quals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => QualificationCard(qualificationData: quals[i]),
      );
    });
  }
}
