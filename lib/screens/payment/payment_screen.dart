import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/auth_apis.dart';
import '../../components/app_scaffold.dart';
import '../../generated/assets.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/price_widget.dart';
import '../dashboard/dashboard_controller.dart';
import 'payment_controller.dart';

class PaymentScreen extends StatelessWidget {
  final bool isQuickBook;
  const PaymentScreen({super.key, this.isQuickBook = false});

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.payment,
      isLoading: paymentController.isLoading,
      appBarVerticalSize: Get.height * 0.12,
      body: RefreshIndicator(
        onRefresh: () async {
          await AuthServiceApis.getUserWallet();
          await getAppConfigurations();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Obx(
            () => RadioGroup<String>(
              groupValue: paymentController.paymentOption.value,
              onChanged: (String? value) {
                if (value == null) return;
                if (value == PaymentMethods.PAYMENT_METHOD_WALLET) {
                  if (userWalletData.value.walletAmount.toStringAsFixed(appCurrency.value.noOfDecimal).toDouble() >= paymentController.payAmount.toStringAsFixed(appCurrency.value.noOfDecimal).toDouble()) {
                    paymentController.paymentOption(value);
                  } else {
                    toast(locale.value.youDontHaveEnoughBalanceToCompleteThePaymentU);
                  }
                } else {
                  paymentController.paymentOption(value);
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "* ${locale.value.noteForCashPaymentPurposesDontUseThePayNowBut}",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: appColorSecondary,
                    letterSpacing: 0.1,
                  ),
                ).paddingTop(16).visible(paymentController.isFromBookingDetail && !paymentController.isAdvancePaymentFailed),
                16.height,
                Text(
                  locale.value.choosePaymentMethod,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: isDarkMode.value ? whiteTextColor : appColorPrimary,
                  ),
                ),
                8.height,
                Text(
                  locale.value.chooseOurConvenientPaymentOptionAndUnlockUnli,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: secondaryTextColor,
                    letterSpacing: 0.1,
                  ),
                ),
                32.height,
                cashAfterService(context).visible(isQuickBook).paddingOnly(bottom: 8),
                Column(
                  children: [
                    if (!paymentController.bookingData.isOnlineService && !paymentController.isFromBookingDetail && !paymentController.bookingData.isEnableAdvancePayment) cashAfterService(context).paddingOnly(bottom: 8),
                    walletPayment(context).paddingOnly(bottom: 8),
                    stripePaymentWidget(context).paddingOnly(bottom: 8).visible(appConfigs.value.stripePay.stripePublickey.isNotEmpty && appConfigs.value.stripePay.stripeSecretkey.isNotEmpty),
                    razorPaymentWidget(context).paddingOnly(bottom: 8).visible(appConfigs.value.razorPay.razorpaySecretkey.isNotEmpty),
                    phonePayPaymentWidget(context).visible(appConfigs.value.phonepe.phonepeAppId.isNotEmpty &&
                        appConfigs.value.phonepe.phonepeMerchantId.isNotEmpty &&
                        appConfigs.value.phonepe.phonepeSaltKey.isNotEmpty &&
                        appConfigs.value.phonepe.phonepeSaltIndex.isNotEmpty),
                    payStackPaymentWidget(context).visible(appConfigs.value.paystackPay.paystackPublickey.isNotEmpty && appConfigs.value.paystackPay.paystackSecretkey.isNotEmpty).paddingOnly(bottom: 8),
                    payPalPaymentWidget(context).visible(appConfigs.value.paypalPay.paypalClientid.isNotEmpty && appConfigs.value.paypalPay.paypalSecretkey.isNotEmpty).paddingOnly(bottom: 8),
                    flutterWavePaymentWidget(context).visible(appConfigs.value.flutterwavePay.flutterwaveSecretkey.isNotEmpty && appConfigs.value.flutterwavePay.flutterwavePublickey.isNotEmpty).paddingOnly(bottom: 8),
                    airtelMoneyPaymentWidget(context).visible(appConfigs.value.airtelMoney.airtelSecretkey.isNotEmpty && appConfigs.value.airtelMoney.airtelClientid.isNotEmpty).paddingOnly(bottom: 8),
                    midtransPay(context).visible(appConfigs.value.midtransPay.midtransClientKey.isNotEmpty).paddingOnly(bottom: 8),
                    sadadPay(context).visible(appConfigs.value.sadadPay.sadadSecretKey.isNotEmpty && appConfigs.value.sadadPay.sadadId.isNotEmpty && appConfigs.value.sadadPay.sadadDomain.isNotEmpty).paddingOnly(bottom: 8),
                    cinetPay(context).visible(appConfigs.value.cinetPay.siteId.isNotEmpty && appConfigs.value.cinetPay.cinetPayAPIKey.isNotEmpty),
                  ],
                ).visible(!isQuickBook)
              ],
            ).paddingSymmetric(horizontal: 16),
            ),
          ),
        ).makeRefreshable,
      ),
      widgetsStackedOverBody: [
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: appColorSecondary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: appTransparentColor,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  paymentController.handleBookNowClick(context, isQuickBook);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Center(
                    child: Text(
                      locale.value.proceed,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: whiteTextColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  /// Builds a payment method card with elevated surface styling
  Widget _buildPaymentMethodCard({
    required BuildContext context,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode.value ? softShadowColorDark : softShadowColor,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Builds a RadioListTile for a payment method with consistent styling
  Widget _buildPaymentRadioTile({
    required BuildContext context,
    required String title,
    required String value,
    required Widget secondaryWidget,
  }) {
    return Obx(
      () => RadioListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 2),
        tileColor: appTransparentColor,
        controlAffinity: ListTileControlAffinity.trailing,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        secondary: secondaryWidget,
        fillColor: WidgetStateProperty.all(appColorSecondary),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: isDarkMode.value ? whiteTextColor : appColorPrimary,
          ),
        ),
        value: value,
      ),
    );
  }

  Widget stripePaymentWidget(BuildContext context) {
    return _buildPaymentMethodCard(
      context: context,
      child: _buildPaymentRadioTile(
        context: context,
        title: "Stripe",
        value: PaymentMethods.PAYMENT_METHOD_STRIPE,
        secondaryWidget: const Image(
          image: AssetImage(Assets.imagesStripeLogo),
          height: 16,
          width: 22,
        ),
      ),
    );
  }

  Widget razorPaymentWidget(BuildContext context) {
    return _buildPaymentMethodCard(
      context: context,
      child: _buildPaymentRadioTile(
        context: context,
        title: "Razor Pay",
        value: PaymentMethods.PAYMENT_METHOD_RAZORPAY,
        secondaryWidget: const Image(
          image: AssetImage(Assets.imagesRazorpayLogo),
          height: 16,
          width: 22,
        ),
      ),
    );
  }

  Widget phonePayPaymentWidget(BuildContext context) {
    return _buildPaymentMethodCard(
      context: context,
      child: _buildPaymentRadioTile(
        context: context,
        title: "PhonePe",
        value: PaymentMethods.PAYMENT_METHOD_PHONEPE,
        secondaryWidget: const Image(
          image: AssetImage(Assets.imagesPhonepeLogo),
          height: 18,
          width: 24,
        ),
      ),
    );
  }

  Widget payStackPaymentWidget(BuildContext context) {
    return _buildPaymentMethodCard(
      context: context,
      child: _buildPaymentRadioTile(
        context: context,
        title: "PayStack",
        value: PaymentMethods.PAYMENT_METHOD_PAYSTACK,
        secondaryWidget: const Image(
          image: AssetImage(Assets.imagesPaystackLogo),
          height: 16,
          width: 22,
        ),
      ),
    );
  }

  Widget payPalPaymentWidget(BuildContext context) {
    return _buildPaymentMethodCard(
      context: context,
      child: _buildPaymentRadioTile(
        context: context,
        title: "PayPal",
        value: PaymentMethods.PAYMENT_METHOD_PAYPAL,
        secondaryWidget: const Image(
          image: AssetImage(Assets.imagesPaypalLogo),
          height: 16,
          width: 22,
        ),
      ),
    );
  }

  Widget flutterWavePaymentWidget(BuildContext context) {
    return _buildPaymentMethodCard(
      context: context,
      child: _buildPaymentRadioTile(
        context: context,
        title: "FlutterWave",
        value: PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE,
        secondaryWidget: const Image(
          image: AssetImage(Assets.imagesFlutterWaveLogo),
          height: 16,
          width: 22,
        ),
      ),
    );
  }

  Widget airtelMoneyPaymentWidget(BuildContext context) {
    return _buildPaymentMethodCard(
      context: context,
      child: _buildPaymentRadioTile(
        context: context,
        title: "Airtel Money",
        value: PaymentMethods.PAYMENT_METHOD_AIRTEL,
        secondaryWidget: const Image(
          image: AssetImage(Assets.imagesAirtelLogo),
          height: 16,
          width: 22,
        ),
      ),
    );
  }

  Widget midtransPay(BuildContext context) {
    return _buildPaymentMethodCard(
      context: context,
      child: _buildPaymentRadioTile(
        context: context,
        title: "Midtrans",
        value: PaymentMethods.PAYMENT_METHOD_MIDTRANS,
        secondaryWidget: const Image(
          image: AssetImage(Assets.imagesMidtransLogo),
          height: 16,
          width: 22,
        ),
      ),
    );
  }

  Widget sadadPay(BuildContext context) {
    return _buildPaymentMethodCard(
      context: context,
      child: Obx(
        () => RadioListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 2),
          tileColor: appTransparentColor,
          controlAffinity: ListTileControlAffinity.trailing,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          secondary: Image(
            color: isDarkMode.value ? white : black,
            image: const AssetImage(Assets.imagesSadadLogo),
            height: 16,
            width: 22,
          ),
          fillColor: WidgetStateProperty.all(appColorSecondary),
          title: Text(
            "Sadad",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
              color: isDarkMode.value ? whiteTextColor : appColorPrimary,
            ),
          ),
          value: PaymentMethods.PAYMENT_METHOD_SADAD,
        ),
      ),
    );
  }

  Widget cinetPay(BuildContext context) {
    return _buildPaymentMethodCard(
      context: context,
      child: _buildPaymentRadioTile(
        context: context,
        title: "CinetPay",
        value: PaymentMethods.PAYMENT_METHOD_CINETPAY,
        secondaryWidget: const Image(
          image: AssetImage(Assets.imagesCinetpayLogo),
          height: 16,
          width: 22,
        ),
      ),
    );
  }

  Widget cashAfterService(BuildContext context) {
    return _buildPaymentMethodCard(
      context: context,
      child: Obx(
        () => RadioListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 2),
          tileColor: appTransparentColor,
          controlAffinity: ListTileControlAffinity.trailing,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          secondary: Image(
            image: const AssetImage(Assets.iconsIcCash),
            color: isDarkMode.value ? appColorSecondary : appColorPrimary,
            height: 18,
            width: 24,
          ),
          fillColor: WidgetStateProperty.all(appColorSecondary),
          title: Text(
            "Cash after service",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
              color: isDarkMode.value ? whiteTextColor : appColorPrimary,
            ),
          ),
          value: PaymentMethods.PAYMENT_METHOD_CASH,
        ),
      ),
    );
  }

  Widget walletPayment(BuildContext context) {
    return _buildPaymentMethodCard(
      context: context,
      child: Obx(
        () => RadioListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 2),
          tileColor: appTransparentColor,
          controlAffinity: ListTileControlAffinity.trailing,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          secondary: Image(
            image: const AssetImage(Assets.iconsIcUnFillWallet),
            color: isDarkMode.value ? appColorSecondary : appColorPrimary,
            height: 18,
            width: 24,
          ),
          fillColor: WidgetStateProperty.all(appColorSecondary),
          title: Row(
            children: [
              Text(
                "Wallet",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                  color: isDarkMode.value ? whiteTextColor : appColorPrimary,
                ),
              ),
              8.width,
              Text(
                "( ",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: completedStatusColor,
                ),
              ),
              PriceWidget(
                price: userWalletData.value.walletAmount,
                color: completedStatusColor,
                size: 14,
                isBoldText: true,
              ),
              Text(
                " )",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: completedStatusColor,
                ),
              ),
            ],
          ),
          value: PaymentMethods.PAYMENT_METHOD_WALLET,
        ),
      ),
    );
  }
}
