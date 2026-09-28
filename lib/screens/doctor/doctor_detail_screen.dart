import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/cached_image_widget.dart';
import '../../components/loader_widget.dart';
import '../../generated/assets.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import '../../utils/empty_error_state_widget.dart';
import '../slots/booking_form_screen.dart';
import 'components/doctor_qualification_card.dart';
import 'components/doctor_review_card.dart';
import 'components/doctor_service_card.dart';
import 'doctor_detail_controller.dart';
import 'model/doctor_detail_model.dart';
import 'model/doctor_list_res.dart';

class DoctorDetailScreen extends StatelessWidget {
  DoctorDetailScreen({super.key});

  final DoctorDetailController doctorDetailCont =
      Get.put(DoctorDetailController());

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _pageColor(context),
        bottomNavigationBar: _BookingBar(cont: doctorDetailCont),
        body: Stack(
          children: [
            RefreshIndicator(
              color: appColorSecondary,
              onRefresh: () => doctorDetailCont.init(showLoader: false),
              child: Obx(
                () => SnapHelperWidget(
                  future: doctorDetailCont.getDoctorDetail.value,
                  errorBuilder: (error) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 120),
                      children: [
                        NoDataWidget(
                          title: locale.value.somethingWentWrongPleaseTryAgainLater,
                          retryText: locale.value.reload,
                          imageWidget: const ErrorStateWidget(),
                          onRetry: doctorDetailCont.init,
                        ),
                      ],
                    );
                  },
                  loadingWidget: const LoaderWidget(),
                  onSuccess: (_) {
                    final doctor = doctorDetailCont.doctorData.value;
                    return _DoctorDetailContent(doctor: doctor);
                  },
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: context.statusBarHeight + 72,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        appColorPrimary.withValues(alpha: 0.32),
                        appColorPrimary.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              start: 16,
              top: context.statusBarHeight + 10,
              child: _CircleNavButton(
                icon: Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.arrow_back_ios_new_rounded,
                onTap: Get.back,
              ),
            ),
            Obx(
              () => LoaderWidget(isBlurBackground: true)
                  .center()
                  .visible(doctorDetailCont.isLoading.value),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Main content scroll
// ─────────────────────────────────────────────────────────────

class _DoctorDetailContent extends StatelessWidget {
  final Doctor doctor;

  const _DoctorDetailContent({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final heroHeight =
        (MediaQuery.sizeOf(context).height * 0.36).clamp(292.0, 350.0);
    final aboutText = parseHtmlString(doctor.aboutSelf).trim();

    return AnimatedScrollView(
      listAnimationType: ListAnimationType.None,
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: heroHeight + 108,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _DoctorHeroImage(doctor: doctor, height: heroHeight),
              Positioned(
                left: 20,
                right: 20,
                top: heroHeight - 72,
                child: _FadeSlideIn(
                  index: 0,
                  child: _IdentityCard(doctor: doctor),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (aboutText.isNotEmpty) ...[
                _FadeSlideIn(
                  index: 1,
                  child: _AboutCard(text: aboutText),
                ),
                28.height,
              ],
              _FadeSlideIn(
                index: 2,
                child: const _ServicesSection(),
              ),
              28.height,
              _FadeSlideIn(
                index: 3,
                child: const _ReviewsSection(),
              ),
              if (doctor.qualifications.isNotEmpty) ...[
                28.height,
                _FadeSlideIn(
                  index: 4,
                  child: _QualificationsSection(
                    qualifications: doctor.qualifications,
                  ),
                ),
              ],
              // Bottom clearance for the sticky booking bar
              100.height,
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sticky booking CTA
// ─────────────────────────────────────────────────────────────

class _BookingBar extends StatelessWidget {
  final DoctorDetailController cont;

  const _BookingBar({required this.cont});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final doctor = cont.doctorData.value;
      final isReady = !doctor.id.isNegative;

      return Container(
        decoration: BoxDecoration(
          color: _surfaceColor(context),
          boxShadow: [
            BoxShadow(
              color: isDarkMode.value
                  ? Colors.black.withValues(alpha: 0.22)
                  : softShadowColorMedium,
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isReady
                    ? () {
                        currentSelectedDoctor(doctor);
                        Get.to(() => BookingFormScreen());
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColorPrimary,
                  foregroundColor: const Color(0xFFF0F6FF),
                  disabledBackgroundColor:
                      appColorPrimary.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Obx(
                  () => Text(
                    locale.value.bookAppointment,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────
// Inline sections
// ─────────────────────────────────────────────────────────────

class _SectionBlock extends StatelessWidget {
  final String title;
  final String? count;
  final Widget child;

  const _SectionBlock({
    required this.title,
    this.count,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: _titleColor(context),
                  fontSize: 17,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (count != null) ...[
                8.width,
                _MetaPill(text: count!),
              ],
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection();

  @override
  Widget build(BuildContext context) {
    final cont = Get.find<DoctorDetailController>();

    return Obx(() {
      final services = cont.serviceList;
      final total = cont.doctorData.value.totalServices;
      final isLastPage = cont.isServicesLastPage.value;
      final isLoading = cont.isServicesLoading.value;

      return _SectionBlock(
        title: locale.value.services,
        count: total > 0 ? total.toString() : null,
        child: services.isEmpty
            ? _SectionEmptyRow(
                message: locale.value.noServicesFoundAtAMoment,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...services.map(
                    (service) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DoctorServiceCard(serviceElement: service),
                    ),
                  ),
                  if (!isLastPage)
                    _LoadMoreButton(
                      isLoading: isLoading,
                      onTap: isLoading
                          ? null
                          : () {
                              cont.servicesPage(cont.servicesPage.value + 1);
                              cont.getServiceList(showLoader: false);
                            },
                    ),
                ],
              ),
      );
    });
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection();

  @override
  Widget build(BuildContext context) {
    final cont = Get.find<DoctorDetailController>();

    return Obx(() {
      final reviews = cont.inlineReviewList;
      final total = cont.doctorData.value.totalReviews;
      final isLastPage = cont.isReviewsLastPage.value;
      final isLoading = cont.isReviewsLoading.value;

      return _SectionBlock(
        title: locale.value.reviews,
        count: total > 0 ? total.toString() : null,
        child: reviews.isEmpty
            ? _SectionEmptyRow(
                message: locale.value.noReviewsFoundAtAMoment,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...reviews.map(
                    (review) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DoctorReviewCard(doctorReviewData: review),
                    ),
                  ),
                  if (!isLastPage)
                    _LoadMoreButton(
                      isLoading: isLoading,
                      onTap: isLoading ? null : cont.loadMoreReviews,
                    ),
                ],
              ),
      );
    });
  }
}

class _QualificationsSection extends StatelessWidget {
  final List<Qualifications> qualifications;

  const _QualificationsSection({required this.qualifications});

  @override
  Widget build(BuildContext context) {
    return _SectionBlock(
      title: locale.value.qualification,
      count: qualifications.length.toString(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: qualifications
            .map(
              (q) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: QualificationCard(qualificationData: q),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _LoadMoreButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: appColorSecondary,
            ),
          ),
        ),
      );
    }

    return Center(
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: appColorSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        child: Obx(
          () => Text(
            locale.value.viewAll,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionEmptyRow extends StatelessWidget {
  final String message;

  const _SectionEmptyRow({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        message,
        style: TextStyle(
          color: _mutedColor(context),
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Hero & identity (unchanged)
// ─────────────────────────────────────────────────────────────

class _DoctorHeroImage extends StatelessWidget {
  final Doctor doctor;
  final double height;

  const _DoctorHeroImage({required this.doctor, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: _heroBaseColor(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedImageWidget(
            url: doctor.profileImage,
            firstName: doctor.firstName,
            lastName: doctor.lastName,
            fit: BoxFit.cover,
            height: height,
            width: Get.width,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  appColorPrimary.withValues(alpha: 0.36),
                  appColorPrimary.withValues(alpha: 0.14),
                  appColorPrimary.withValues(alpha: 0.48),
                ],
                stops: const [0, 0.34, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final Doctor doctor;

  const _IdentityCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final hasSocialLinks = doctor.twitterLink.isNotEmpty ||
        doctor.dribbbleLink.isNotEmpty ||
        doctor.facebookLink.isNotEmpty ||
        doctor.instagramLink.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: _softSurfaceDecoration(context, radiusValue: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            doctor.fullName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _titleColor(context),
                              fontSize: 22,
                              height: 1.12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        8.width,
                        const CachedImageWidget(
                          url: Assets.iconsIcVerified,
                          width: 18,
                          height: 18,
                        ),
                      ],
                    ).visible(doctor.fullName.isNotEmpty),
                    if (doctor.expert.isNotEmpty) ...[
                      8.height,
                      Text(
                        doctor.expert,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _mutedColor(context),
                          fontSize: 14,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              14.width,
              _RatingPill(rating: doctor.averageRating),
            ],
          ),
          if (hasSocialLinks) ...[
            18.height,
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SocialIconButton(
                  iconPath: Assets.socialMediaIcX,
                  tooltip: 'X',
                  url: doctor.twitterLink,
                ),
                _SocialIconButton(
                  iconPath: Assets.socialMediaIcDribble,
                  tooltip: 'Dribbble',
                  url: doctor.dribbbleLink,
                ),
                _SocialIconButton(
                  iconPath: Assets.socialMediaIcFb,
                  tooltip: 'Facebook',
                  url: doctor.facebookLink,
                ),
                _SocialIconButton(
                  iconPath: Assets.socialMediaIcInsta,
                  tooltip: 'Instagram',
                  url: doctor.instagramLink,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final num rating;

  const _RatingPill({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode.value
            ? const Color(0xFF223047)
            : const Color(0xFFFFF6E5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CachedImageWidget(
            url: Assets.iconsIcStarFilled,
            color: checkoutStatusColor,
            height: 13,
          ),
          6.width,
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color:
                  isDarkMode.value ? const Color(0xFFFFDCA2) : appColorPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final String iconPath;
  final String tooltip;
  final String url;

  const _SocialIconButton({
    required this.iconPath,
    required this.tooltip,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const SizedBox.shrink();

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () =>
              commonLaunchUrl(url, launchMode: LaunchMode.externalApplication),
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDarkMode.value
                  ? const Color(0xFF202C40)
                  : const Color(0xFFF1F5F7),
              shape: BoxShape.circle,
            ),
            child: CachedImageWidget(
              url: iconPath,
              height: 15,
              fit: BoxFit.fitHeight,
              color: isDarkMode.value ? textSecondaryDark : appColorSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final String text;

  const _AboutCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: _softSurfaceDecoration(context, radiusValue: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: locale.value.aboutMyself),
          12.height,
          ReadMoreText(
            text,
            trimLines: 4,
            style: TextStyle(
              color: _bodyColor(context),
              fontSize: 15,
              height: 1.58,
              fontWeight: FontWeight.w400,
            ),
            colorClickableText: appColorSecondary,
            trimMode: TrimMode.Line,
            trimCollapsedText: " ${locale.value.readMore}",
            trimExpandedText: " ${locale.value.readLess}",
            locale: Localizations.localeOf(context),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────

class _MetaPill extends StatelessWidget {
  final String text;

  const _MetaPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode.value
            ? const Color(0xFF27364C)
            : const Color(0xFFF1F5F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _mutedColor(context),
          fontSize: 12,
          height: 1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: _titleColor(context),
        fontSize: 17,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _CircleNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF061A3B).withValues(alpha: 0.55),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: appColorPrimary.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: const Color(0xFFF8FAFB)),
        ),
      ),
    );
  }
}

class _FadeSlideIn extends StatelessWidget {
  final int index;
  final Widget child;

  const _FadeSlideIn({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final disableMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: disableMotion
          ? Duration.zero
          : Duration(milliseconds: 420 + (index * 60)),
      curve: Curves.easeOutQuart,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Decoration & color helpers
// ─────────────────────────────────────────────────────────────

BoxDecoration _softSurfaceDecoration(BuildContext context,
    {required double radiusValue}) {
  return BoxDecoration(
    color: _surfaceColor(context),
    borderRadius: BorderRadius.circular(radiusValue),
    boxShadow: [
      BoxShadow(
        color: isDarkMode.value
            ? Colors.black.withValues(alpha: 0.18)
            : softShadowColorMedium,
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ],
  );
}

Color _pageColor(BuildContext context) {
  return isDarkMode.value ? appScreenBackgroundDark : const Color(0xFFF6F8F9);
}

Color _surfaceColor(BuildContext context) {
  return isDarkMode.value ? surfaceElevatedDark : const Color(0xFFFEFFFF);
}

Color _heroBaseColor(BuildContext context) {
  return isDarkMode.value
      ? appBackgroundSecondaryColorDark
      : const Color(0xFFE7F1F1);
}

Color _titleColor(BuildContext context) {
  return isDarkMode.value ? textPrimaryDark : primaryTextColor;
}

Color _bodyColor(BuildContext context) {
  return isDarkMode.value ? textSecondaryDark : const Color(0xFF4E5B64);
}

Color _mutedColor(BuildContext context) {
  return isDarkMode.value ? textTertiaryDark : const Color(0xFF75818A);
}
