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

class GreetingsComponent extends StatelessWidget {
  const GreetingsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      child: Row(
        children: [
          // Profile avatar with gradient ring
          Obx(
            () => Padding(
              padding: const EdgeInsetsDirectional.only(end: 14),
              child: Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      appColorAccent.withValues(alpha: 0.8),
                      appColorSecondary.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: appColorAccent.withValues(alpha: 0.2),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white12,
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
            ).visible(loginUserData.value.profileImage.contains("http")),
          ),

          // Greeting text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${locale.value.hey}, ',
                        style: GoogleFonts.plusJakartaSans(
                          color: white.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.1,
                        ),
                      ),
                      TextSpan(
                        text: isLoggedIn.value ? loginUserData.value.userName.validate() : locale.value.guest.validate(),
                        style: GoogleFonts.outfit(
                          color: white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Obx(
                () => GestureDetector(
                  onLongPress: () {
                    loginUserData.value.address.copyToClipboard();
                  },
                  child: Row(
                    children: [
                      const CachedImageWidget(
                        url: Assets.imagesLocationPin,
                        height: 14,
                      ),
                      8.width,
                      Text(
                        loginUserData.value.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          color: white.withValues(alpha: 0.75),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ).flexible(),
                    ],
                  ),
                ).paddingTop(6).visible(loginUserData.value.address.isNotEmpty),
              ),
            ],
          ).expand(),
          16.width,

          // Notification bell with glass effect
          GestureDetector(
            onTap: () {
              doIfLoggedIn(() {
                Get.to(() => NotificationScreen());
              });
            },
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
                        color: Colors.white.withValues(alpha: 0.06),
                        blurRadius: 8,
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
                  top: -2,
                  right: -2,
                  child: Obx(
                    () => Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [appColorAccent, Color(0xFFF57C00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: appColorPrimary, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: appColorAccent.withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          unreadNotificationCount.value.toString(),
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
                )
              ],
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 24),
    );
  }
}
