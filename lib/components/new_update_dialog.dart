import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/utils/colors.dart';
import '../generated/assets.dart';
import '../main.dart';
import '/utils/app_common.dart';
import 'package:url_launcher/url_launcher.dart';
import '../configs.dart';
import '../utils/common_base.dart';
import '../utils/update_store_link.dart';

class NewUpdateDialog extends StatelessWidget {
  final bool canClose;
  const NewUpdateDialog({super.key, this.canClose = true});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: Get.width - 16,
          constraints: BoxConstraints(maxHeight: Get.height * 0.6),
          child: AnimatedScrollView(
            listAnimationType: ListAnimationType.FadeIn,
            children: [
              60.height,
              Text(locale.value.newUpdate, style: primaryTextStyle(size: 18)),
              8.height,
              Text(
                  "${locale.value.anUpdateTo}  $APP_NAME ${locale.value.isAvailableGoTo}",
                  style: secondaryTextStyle(),
                  textAlign: TextAlign.left),
              24.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (canClose) ...[
                    AppButton(
                      text: locale.value.later,
                      textStyle: appButtonTextStyleGray,
                      color: isDarkMode.value
                          ? appColorSecondary.withValues(alpha: 0.5)
                          : appColorPrimary,
                      onTap: Get.back,
                    ).expand(),
                    32.width,
                  ],
                  AppButton(
                    text: locale.value.updateNow,
                    textStyle: appButtonTextStyleWhite,
                    onTap: () => _openStore(canClose: canClose),
                  ).expand(),
                ],
              ),
            ],
          ).paddingSymmetric(horizontal: 16, vertical: 24),
        ),
        Positioned(
          top: -42,
          child: Image.asset(Assets.imagesForceUpdate,
              height: 100, width: 100, fit: BoxFit.cover),
        ),
      ],
    );
  }

  Future<void> _openStore({required bool canClose}) async {
    String candidate = '';
    if (isAndroid) {
      candidate = APP_PLAY_STORE_URL.trim().isNotEmpty
          ? APP_PLAY_STORE_URL
          : '${getSocialMediaLink(LinkProvider.PLAY_STORE)}${await getPackageName()}';
    } else if (isIOS) {
      final backendUrl =
          appConfigs.value.patientAppUrl.patientAppAppStore.trim();
      candidate = backendUrl.isNotEmpty ? backendUrl : APP_APPSTORE_URL;
    }

    final uri = validatedStoreUri(candidate);
    if (uri == null) {
      toast(locale.value.updateLinkUnavailable);
      return;
    }

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      toast(locale.value.updateLinkUnavailable);
      return;
    }
    if (canClose && Get.isDialogOpen == true) Get.back();
  }
}
