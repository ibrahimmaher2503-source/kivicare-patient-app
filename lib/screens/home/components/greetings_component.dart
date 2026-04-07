import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import '../../../../main.dart';
import '../../../../utils/app_common.dart';
import '../../../components/cached_image_widget.dart';
import '../../../generated/assets.dart';
import '../../../utils/colors.dart';
import '../../auth/other/notification_screen.dart';
import '../../search/search_hub_screen.dart';
import '../home_controller.dart';

class GreetingsComponent extends StatelessWidget {
  const GreetingsComponent({super.key});

  String get _timeGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  IconData get _timeIcon {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.wb_cloudy_rounded;
    return Icons.nightlight_round;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Avatar + Greeting + Bell ──────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Animated profile avatar
              Obx(
                () => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.7, end: 1.0),
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutBack,
                    builder: (ctx, v, child) =>
                        Transform.scale(scale: v, child: child),
                    child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            appColorAccent.withValues(alpha: 0.95),
                            appColorSecondary.withValues(alpha: 0.75),
                            white.withValues(alpha: 0.35),
                          ],
                          stops: const [0.0, 0.55, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: appColorAccent.withValues(alpha: 0.38),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                        child: CachedImageWidget(
                          url: loginUserData.value.profileImage,
                          fit: BoxFit.cover,
                          width: 46,
                          height: 46,
                          circle: true,
                        ),
                      ),
                    ),
                  ),
                ).visible(loginUserData.value.profileImage.contains("http")),
              ),

              // Greeting text column
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Time-based sub-greeting
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _timeIcon,
                        color: white.withValues(alpha: 0.6),
                        size: 12,
                      ),
                      4.width,
                      Text(
                        _timeGreeting,
                        style: GoogleFonts.plusJakartaSans(
                          color: white.withValues(alpha: 0.65),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  2.height,
                  // Name
                  Obx(
                    () => Text(
                      isLoggedIn.value
                          ? loginUserData.value.userName.validate()
                          : locale.value.guest.validate(),
                      style: GoogleFonts.outfit(
                        color: white,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Location
                  Obx(
                    () => GestureDetector(
                      onLongPress: () =>
                          loginUserData.value.address.copyToClipboard(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CachedImageWidget(
                            url: Assets.imagesLocationPin,
                            height: 12,
                          ),
                          5.width,
                          Text(
                            loginUserData.value.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              color: white.withValues(alpha: 0.65),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ).flexible(),
                        ],
                      ),
                    )
                        .paddingTop(3)
                        .visible(loginUserData.value.address.isNotEmpty),
                  ),
                ],
              ).expand(),

              16.width,

              // Notification bell with improved badge
              GestureDetector(
                onTap: () => doIfLoggedIn(() => Get.to(() => NotificationScreen())),
                behavior: HitTestBehavior.translucent,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: glassTintLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: glassStrokeLight,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.08),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const CachedImageWidget(
                        url: Assets.navigationIcNotifyOutlined,
                        color: Colors.white,
                        height: 22,
                      ),
                    ),
                    Positioned(
                      top: -3,
                      right: -3,
                      child: Obx(
                        () => TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.4, end: 1.0),
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeOutBack,
                          builder: (ctx, v, child) =>
                              Transform.scale(scale: v, child: child),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            constraints:
                                const BoxConstraints(minWidth: 20, minHeight: 20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF57C00), appColorAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: appColorPrimary, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: appColorAccent.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                unreadNotificationCount.value > 99
                                    ? '99+'
                                    : unreadNotificationCount.value.toString(),
                                style: GoogleFonts.plusJakartaSans(
                                  color: white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ).visible(unreadNotificationCount.value > 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).paddingSymmetric(horizontal: 24),

          10.height,

          // ── Row 2: Quick action pills ─────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // Search Care pill
                GestureDetector(
                  onTap: () => Get.to(() => const SearchHubScreen()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: glassTintLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: glassStrokeLight, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_rounded,
                            color: Colors.white, size: 14),
                        6.width,
                        Text(
                          locale.value.searchHere,
                          style: GoogleFonts.plusJakartaSans(
                            color: white.withValues(alpha: 0.92),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                10.width,
                // Upcoming count pill
                Obx(() {
                  final HomeController homeCtrl = Get.find<HomeController>();
                  final count =
                      homeCtrl.dashboardData.value.upcomingAppointment.length;
                  if (!isLoggedIn.value) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: glassTintLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: glassStrokeLight, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.event_available_rounded,
                            color: Colors.white, size: 14),
                        6.width,
                        Text(
                          count > 0
                              ? '$count ${locale.value.upcomingAppointments}'
                              : locale.value.noDataFound,
                          style: GoogleFonts.plusJakartaSans(
                            color: white.withValues(alpha: 0.92),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
