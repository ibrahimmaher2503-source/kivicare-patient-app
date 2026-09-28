import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import '../../../../main.dart';
import '../../../../utils/app_common.dart';
import '../../../components/cached_image_widget.dart';
import '../../../generated/assets.dart';
import '../../../utils/colors.dart';
import '../../auth/other/notification_screen.dart';

import '../../pharmacy/cart/cart_screen.dart';
import '../../pharmacy/pharmacy_controller.dart';

class GreetingsComponent extends StatelessWidget {
  const GreetingsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final pharmacyController = Get.find<PharmacyController>();

    return SizedBox(
      width: Get.width,
      child: Row(
        children: [
          const _GreetingAvatar(),
          12.width,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  '👋 ${locale.value.hey}${isLoggedIn.value && loginUserData.value.userName.validate().isNotEmpty ? ', ${loginUserData.value.userName.validate()}' : ''}',
                  style: boldTextStyle(color: white, size: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              2.height,
              Obx(
                () => loginUserData.value.address.isNotEmpty
                    ? GestureDetector(
                        onLongPress: () =>
                            loginUserData.value.address.copyToClipboard(),
                        child: Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 14, color: white.withValues(alpha: 0.75)),
                            4.width,
                            Text(
                              loginUserData.value.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: secondaryTextStyle(
                                  color: white.withValues(alpha: 0.85),
                                  size: 13),
                            ).flexible(),
                          ],
                        ),
                      )
                    : Text(
                        locale.value.quicklyBookYourAppointmentNow,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: secondaryTextStyle(
                            color: white.withValues(alpha: 0.75), size: 12),
                      ),
              ),
            ],
          ).expand(),
          12.width,
          _GreetingActionButton(
            semanticLabel: locale.value.cart,
            onTap: () => doIfLoggedIn(() => Get.to(() => CartScreen())),
            badgeCount: pharmacyController.cartCount,
            child: const Icon(Icons.shopping_cart_outlined,
                color: Colors.white, size: 22),
          ),
          10.width,
          _GreetingActionButton(
            semanticLabel: locale.value.notifications,
            onTap: () => doIfLoggedIn(() => Get.to(() => NotificationScreen())),
            badgeCount: unreadNotificationCount,
            child: const CachedImageWidget(
              url: Assets.navigationIcNotifyOutlined,
              color: Colors.white,
              height: 22,
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 20),
    );
  }
}

/// Circular avatar in the home top bar. Shows the user's photo when logged in,
/// otherwise a default user glyph inside a soft translucent ring.
class _GreetingAvatar extends StatelessWidget {
  const _GreetingAvatar();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasImage = loginUserData.value.profileImage.contains('http');
      return Container(
        width: 46,
        height: 46,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.30), width: 1),
        ),
        child: hasImage
            ? CachedImageWidget(
                url: loginUserData.value.profileImage,
                fit: BoxFit.cover,
                width: 46,
                height: 46,
                circle: true,
              )
            : const Icon(Icons.person_rounded, color: Colors.white, size: 26),
      );
    });
  }
}

/// Rounded translucent icon button used for the top-bar actions (cart, bell),
/// with an optional count badge.
class _GreetingActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final RxInt badgeCount;
  final String semanticLabel;

  const _GreetingActionButton({
    required this.onTap,
    required this.child,
    required this.badgeCount,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Tooltip(
          message: semanticLabel,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: SizedBox.square(
                dimension: 48,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                            width: 1),
                      ),
                      child: child,
                    ),
                    PositionedDirectional(
                      top: -5,
                      end: -5,
                      child: Obx(
                        () => Container(
                          padding: const EdgeInsets.all(5),
                          decoration: boxDecorationDefault(
                            color: appColorSecondary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.4),
                          ),
                          child: Text(
                            badgeCount.value > 99
                                ? '99+'
                                : badgeCount.value.toString(),
                            style: secondaryTextStyle(color: white, size: 12),
                          ),
                        ).visible(badgeCount.value > 0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
