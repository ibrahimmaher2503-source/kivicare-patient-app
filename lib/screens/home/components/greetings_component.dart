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
          Obx(
            () => Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: appColorAccent.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              child: CachedImageWidget(
                url: loginUserData.value.profileImage,
                fit: BoxFit.cover,
                width: 46,
                height: 46,
                circle: true,
              ),
            ).paddingRight(12).visible(loginUserData.value.profileImage.contains("http")),
          ),
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
                        style: primaryTextStyle(color: white.withValues(alpha: 0.85), size: 15),
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
                      Text(loginUserData.value.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: secondaryTextStyle(color: white.withValues(alpha: 0.8), size: 13)).flexible(),
                    ],
                  ),
                ).paddingTop(6).visible(loginUserData.value.address.isNotEmpty),
              ),
            ],
          ).expand(),
          16.width,
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const CachedImageWidget(
                    url: Assets.navigationIcNotifyOutlined,
                    color: Colors.white,
                    height: 22,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Obx(
                    () => Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      decoration: BoxDecoration(
                        color: appColorAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: appColorPrimary, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          unreadNotificationCount.value.toString(),
                          style: boldTextStyle(color: white, size: 9),
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
