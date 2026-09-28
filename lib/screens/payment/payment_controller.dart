import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/api/core_apis.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/screens/booking/components/confirm_booking_bottomsheet.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/auth_apis.dart';
import '../../configs.dart';
import '../../payment_gateways/airtel_money/airtel_money_service.dart';
import '../../payment_gateways/cinet_pay_services.dart';
import '../../payment_gateways/flutter_wave_service.dart';
import '../../payment_gateways/midtrans_service.dart';
import '../../payment_gateways/pay_pal_service.dart';
import '../../payment_gateways/pay_stack_service.dart';
import '../../payment_gateways/phone_pe/phone_pe_service.dart';
import '../../payment_gateways/razor_pay_service.dart';
import '../../payment_gateways/sadad_services.dart';
import '../../payment_gateways/stripe_services.dart';
import '../../utils/app_common.dart';
import '../../utils/common_base.dart';
import '../../utils/constants.dart';
import '../../network/critical_operation.dart';
import '../../network/network_utils.dart';
import '../../components/operation_verification_screen.dart';
import '../booking/appointments_controller.dart';
import '../booking/appointments_screen.dart';
import '../booking/model/booking_req.dart';
import '../booking/model/save_payment_req.dart';
import '../dashboard/dashboard_controller.dart';
import '../dashboard/dashboard_screen.dart';
import 'booking_success_screen.dart';

class PaymentController extends GetxController {
  bool isFromBookingDetail;
  bool isAdvancePaymentFailed;
  bool isRemainingPayment;
  num? amount;
  int? bid;

  PaymentController({
    this.isFromBookingDetail = false,
    this.isAdvancePaymentFailed = false,
    this.isRemainingPayment = false,
    this.amount,
    this.bid,
  });

  //
  BookingReq bookingData = BookingReq();
  RxString paymentOption = PaymentMethods.PAYMENT_METHOD_CASH.obs;
  TextEditingController optionalCont = TextEditingController();
  RxBool isLoading = false.obs;
  RxBool isPaymentRequestInFlight = false.obs;

  RazorPayService razorPayService = RazorPayService();
  PayStackService paystackServices = PayStackService();
  FlutterWaveService flutterWaveServices = FlutterWaveService();
  PayPalService payPalService = PayPalService();
  MidtransService midtransPay = MidtransService();

  num get payAmount => isFromBookingDetail && amount.validate() > 0
      ? amount.validate()
      : bookingData.isEnableAdvancePayment
          ? bookingData.advancePayableAmount
          : bookingData.totalAmount;

  int get bookId => isFromBookingDetail && bid.validate() > 0
      ? bid.validate()
      : saveBookingRes.value.saveBookingResData.id;

  Future<void> savePaymentApi({
    required int bid,
    required String txnId,
    required String paymentType,
  }) async {
    if (isPaymentRequestInFlight.value) return;
    isPaymentRequestInFlight(true);
    isLoading(true);
    hideKeyBoardWithoutContext();
    final request = SavePaymentReq(
      id: bid,
      externalTransactionId: txnId,
      transactionType: paymentType,
      taxPercentage: appConfigs.value.exclusiveTaxList,
      paymentStatus: paymentType == PaymentMethods.PAYMENT_METHOD_CASH ||
              bookingData.isEnableAdvancePayment ||
              (isFromBookingDetail && isAdvancePaymentFailed)
          ? 0
          : 1,
      advancePaymentAmount: (isFromBookingDetail && isAdvancePaymentFailed)
          ? payAmount
          : bookingData.advancePayableAmount,
      advancePaymentStatus: (isFromBookingDetail && isAdvancePaymentFailed)
          ? 1
          : bookingData.isEnableAdvancePayment.getIntBool(),
      remainingPaymentAmount: isRemainingPayment ? payAmount : 0,
    ).toJson();
    final fingerprintRequest = {
      ...request,
      'tax_percentage':
          appConfigs.value.exclusiveTaxList.map((tax) => tax.toJson()).toList(),
    };
    final scope = '$bid:$paymentType';
    String? operationKey;
    try {
      operationKey = await CriticalOperationStore.begin(
        CriticalOperationType.payment,
        scope: scope,
        requestFingerprint: criticalOperationFingerprint(fingerprintRequest),
      );
      await CoreServiceApis.savePayment(
        request: request,
        idempotencyKey: operationKey,
      );
      await CriticalOperationStore.complete(
        CriticalOperationType.payment,
        scope: scope,
      );
      if (isFromBookingDetail) {
        Get.back(result: true);
      } else {
        onPaymentSuccess();
      }
    } on AmbiguousRequestOutcomeException {
      Get.off(
        () => OperationVerificationScreen(
          recordsScreen: () => AppointmentsScreen(),
          operationType: CriticalOperationType.payment,
          operationKey: operationKey,
        ),
      );
    } on PendingCriticalOperationException {
      Get.off(
        () => OperationVerificationScreen(
          recordsScreen: () => AppointmentsScreen(),
          operationType: CriticalOperationType.payment,
          operationKey: operationKey ??
              CriticalOperationStore.pendingKey(CriticalOperationType.payment,
                  scope: scope),
        ),
      );
    } catch (e) {
      // If an online gateway already charged the user, losing this call means
      // money taken with no payment recorded — offer a retry instead of
      // failing silently.
      final bool gatewayCharged = txnId.trim().isNotEmpty &&
          paymentType != PaymentMethods.PAYMENT_METHOD_CASH &&
          paymentType != PaymentMethods.PAYMENT_METHOD_WALLET;
      if (gatewayCharged && Get.context != null) {
        showConfirmDialogCustom(
          Get.context!,
          title: locale.value.paymentConfirmationFailedRetry,
          positiveText: locale.value.retry,
          negativeText: locale.value.cancel,
          primaryColor: Get.context!.primaryColor,
          barrierDismissible: false,
          onAccept: (_) {
            savePaymentApi(bid: bid, txnId: txnId, paymentType: paymentType);
          },
          onCancel: (_) {
            toast(
                "${locale.value.pleaseContactSupportWithTransactionId} $txnId",
                print: true);
          },
        );
      } else {
        toast(
          sanitizeBackendMessage(
              e, locale.value.somethingWentWrongPleaseTryAgainLater),
          print: true,
        );
      }
    } finally {
      isLoading(false);
      isPaymentRequestInFlight(false);
    }
  }

  void handleBookNowClick(BuildContext context, bool isQuickBook) {
    if (isLoading.value || isPaymentRequestInFlight.value) return;
    if (isFromBookingDetail) {
      payWithSelectedOption(context, isCashPayment: false);
    } else {
      Get.bottomSheet(
        isScrollControlled: true,
        enableDrag: true,
        ConfirmBookingBottomSheet(
          isQuickBook: isQuickBook,
          serviceName: bookingData.serviceName.validate(),
          dateTime:
              "${bookingData.appointmentDate.validate()} - ${bookingData.appointmentTime.validate()}",
          price: payAmount,
          titleText: locale.value.wouldYouLikeToProceedAndConfirmPayment,
          onConfirm: () {
            Get.back();
            if (saveBookingRes.value.saveBookingResData.id <= 0) {
              saveBooking(context);
            } else {
              payWithSelectedOption(context);
            }
          },
        ),
      );
    }
  }

  void payWithSelectedOption(BuildContext context,
      {bool isCashPayment = true}) {
    if (!isFromBookingDetail && bookId <= 0) {
      isLoading(false);
      toast(locale.value.somethingWentWrong);
      return;
    }
    final isServerSafeMethod =
        paymentOption.value == PaymentMethods.PAYMENT_METHOD_CASH ||
            paymentOption.value == PaymentMethods.PAYMENT_METHOD_WALLET;
    if (!isServerSafeMethod) {
      isLoading(false);
      toast(locale.value.onlinePaymentUnavailable);
      return;
    }
    if (paymentOption.value == PaymentMethods.PAYMENT_METHOD_STRIPE) {
      payWithStripe(context);
    } else if (paymentOption.value == PaymentMethods.PAYMENT_METHOD_RAZORPAY) {
      payWithRazorPay(context);
    } else if (paymentOption.value == PaymentMethods.PAYMENT_METHOD_PHONEPE) {
      payWithPhonepe(context);
    } else if (paymentOption.value == PaymentMethods.PAYMENT_METHOD_PAYSTACK) {
      payWithPayStack();
    } else if (paymentOption.value ==
        PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE) {
      payWithFlutterWave(context);
    } else if (paymentOption.value == PaymentMethods.PAYMENT_METHOD_PAYPAL) {
      payWithPaypal(context);
    } else if (paymentOption.value == PaymentMethods.PAYMENT_METHOD_AIRTEL) {
      payWithAirtelMoney(context);
    } else if (paymentOption.value == PaymentMethods.PAYMENT_METHOD_MIDTRANS) {
      payWithMidtrans();
    } else if (paymentOption.value == PaymentMethods.PAYMENT_METHOD_SADAD) {
      payWithSadad(context);
    } else if (paymentOption.value == PaymentMethods.PAYMENT_METHOD_CINETPAY) {
      payWithCinetPay(context);
    } else if (paymentOption.value == PaymentMethods.PAYMENT_METHOD_WALLET) {
      payWithWallet(context);
    } else if (paymentOption.value == PaymentMethods.PAYMENT_METHOD_CASH &&
        isCashPayment) {
      payWithCash(context);
    }
  }

  Future<void> payWithStripe(BuildContext context) async {
    await StripeServices.stripePaymentMethod(
      loderOnOFF: (p0) {
        isLoading(p0);
      },
      amount: payAmount,
      onComplete: (res) {
        savePaymentApi(
          bid: bookId,
          paymentType: PaymentMethods.PAYMENT_METHOD_STRIPE,
          txnId: res["transaction_id"],
        );
      },
    );
  }

  Future<void> payWithRazorPay(BuildContext context) async {
    isLoading(true);
    razorPayService.init(
      razorKey: appConfigs.value.razorPay.razorpaySecretkey,
      totalAmount: payAmount,
      onComplete: (res) {
        savePaymentApi(
          bid: bookId,
          paymentType: PaymentMethods.PAYMENT_METHOD_RAZORPAY,
          txnId: res["transaction_id"],
        );
      },
    );
    await Future.delayed(const Duration(seconds: 1));
    razorPayService.razorPayCheckout();
    await Future.delayed(const Duration(seconds: 2));
    isLoading(false);
  }

  Future<void> payWithPhonepe(BuildContext context) async {
    PhonePeServices peServices = PhonePeServices(
      totalAmount: payAmount,
      bookingId: bookId,
      onComplete: (res) {
        savePaymentApi(
          bid: bookId,
          paymentType: PaymentMethods.PAYMENT_METHOD_PHONEPE,
          txnId: res["transaction_id"],
        );
      },
    );

    peServices.phonePeCheckout(context);
  }

  Future<void> payWithPayStack() async {
    isLoading(true);
    paystackServices.init(
      loderOnOFF: (p0) {
        isLoading(p0);
      },
      totalAmount: payAmount,
      onComplete: (res) {
        savePaymentApi(
          bid: bookId,
          paymentType: PaymentMethods.PAYMENT_METHOD_PAYSTACK,
          txnId: res["transaction_id"],
        );
      },
    );
    await Future.delayed(const Duration(seconds: 1));
    isLoading(false);
    if (Get.context != null) {
      paystackServices.checkout();
    } else {
      toast(locale.value.paymentContextUnavailable);
    }
  }

  Future<void> payWithFlutterWave(BuildContext context) async {
    isLoading(true);
    flutterWaveServices.checkout(
      ctx: context,
      loderOnOFF: (p0) {
        isLoading(p0);
      },
      totalAmount: payAmount,
      isTestMode: appConfigs.value.flutterwavePay.flutterwavePublickey
          .toLowerCase()
          .contains("test"),
      onComplete: (res) {
        savePaymentApi(
          bid: bookId,
          paymentType: PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE,
          txnId: res["transaction_id"],
        );
      },
    );
    await Future.delayed(const Duration(seconds: 1));
    isLoading(false);
  }

  void payWithPaypal(BuildContext context) {
    isLoading(true);
    payPalService.paypalCheckOut(
      context: context,
      loderOnOFF: (p0) {
        isLoading(p0);
      },
      totalAmount: payAmount,
      onComplete: (res) {
        savePaymentApi(
          bid: bookId,
          paymentType: PaymentMethods.PAYMENT_METHOD_PAYPAL,
          txnId: res["transaction_id"],
        );
      },
    );
  }

  Future<void> payWithAirtelMoney(BuildContext context) async {
    isLoading(true);
    showInDialog(
      context,
      contentPadding: EdgeInsets.zero,
      barrierDismissible: false,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 4, 4, 8),
              width: Get.width,
              decoration: boxDecorationDefault(
                color: context.primaryColor,
                borderRadius:
                    radiusOnly(topRight: defaultRadius, topLeft: defaultRadius),
              ),
              child: Row(
                children: [
                  Text("${locale.value.payment}: Airtel Money",
                          style: boldTextStyle(color: Colors.white))
                      .expand(),
                  const CloseButton(color: Colors.white),
                ],
              ),
            ),
            16.height,
            AirtelMoneyDialog(
              bookingId: bookId,
              amount: payAmount,
              reference: APP_NAME,
              onComplete: (res) {
                savePaymentApi(
                  bid: bookId,
                  paymentType: PaymentMethods.PAYMENT_METHOD_AIRTEL,
                  txnId: res["transaction_id"],
                );
              },
            )
          ],
        );
      },
    ).then((value) => isLoading(false));
  }

  void payWithMidtrans() async {
    isLoading(true);
    midtransPay.initialize(
      totalAmount: payAmount,
      onComplete: (res) {
        savePaymentApi(
          bid: bookId,
          paymentType: PaymentMethods.PAYMENT_METHOD_MIDTRANS,
          txnId: res["transaction_id"],
        );
      },
      loaderOnOFF: (v) {
        isLoading(v);
      },
    );
    await Future.delayed(const Duration(seconds: 1));
    midtransPay.midtransPaymentCheckout();
    await Future.delayed(const Duration(seconds: 2));
    isLoading(false);
  }

  void payWithSadad(BuildContext context) async {
    SadadServices sadadServices = SadadServices(
      totalAmount: payAmount,
      onComplete: (res) {
        savePaymentApi(
          bid: bookId,
          paymentType: PaymentMethods.PAYMENT_METHOD_SADAD,
          txnId: res["transaction_id"],
        );
      },
    );
    sadadServices.payWithSadad(context);
  }

  void payWithCinetPay(BuildContext context) async {
    CinetPayServices cinetPay = CinetPayServices(
      totalAmount: payAmount,
      onComplete: (res) {
        savePaymentApi(
          bid: bookId,
          paymentType: PaymentMethods.PAYMENT_METHOD_CINETPAY,
          txnId: res["transaction_id"],
        );
      },
    );
    cinetPay.payWithCinetPay(context: context);
  }

  Future<void> payWithCash(BuildContext context) async {
    savePaymentApi(
      bid: bookId,
      paymentType: PaymentMethods.PAYMENT_METHOD_CASH,
      txnId:
          isFromBookingDetail && bid.validate() > 0 ? "#${bid.validate()}" : "",
    );
  }

  Future<void> payWithWallet(BuildContext context) async {
    // Re-validate at pay time — the balance check at radio-select time may be
    // stale by the time the user confirms.
    if (userWalletData.value.walletAmount
            .toStringAsFixed(appCurrency.value.noOfDecimal)
            .toDouble() <
        payAmount.toStringAsFixed(appCurrency.value.noOfDecimal).toDouble()) {
      toast(locale.value.youDontHaveEnoughBalanceToCompleteThePaymentU);
      return;
    }
    savePaymentApi(
      bid: bookId,
      paymentType: PaymentMethods.PAYMENT_METHOD_WALLET,
      txnId:
          isFromBookingDetail && bid.validate() > 0 ? "#${bid.validate()}" : "",
    );
  }

  Future<void> saveBooking(BuildContext context,
      {List<PlatformFile>? files}) async {
    if (isLoading.value) return;
    isLoading(true);
    final request = bookingData.isIndependent
        ? bookingData.toIndependentJson()
        : bookingData.toJson();
    final requestFingerprint = criticalOperationFingerprint({
      ...request,
      'files': bookingData.files
          .map((file) => {'name': file.name, 'size': file.size})
          .toList(),
    });
    final operationScope = bookingData.isIndependent ? 'independent' : null;
    String? operationKey;
    try {
      operationKey = await CriticalOperationStore.begin(
        CriticalOperationType.appointment,
        scope: operationScope,
        requestFingerprint: requestFingerprint,
      );
      if (bookingData.isIndependent) {
        saveBookingRes(await CoreServiceApis.bookIndependentService(
          request: request,
          idempotencyKey: operationKey,
        ));
      } else {
        await CoreServiceApis.bookServiceApi(
          request: request,
          files: bookingData.files,
          idempotencyKey: operationKey,
          onSuccess: () {},
          loaderOff: () => isLoading(false),
        );
      }
      await CriticalOperationStore.complete(
        CriticalOperationType.appointment,
        scope: operationScope,
      );
      if (!context.mounted) return;
      if (bookingData.isIndependent) {
        onPaymentSuccess();
      } else {
        payWithSelectedOption(context);
      }
    } on AmbiguousRequestOutcomeException {
      isLoading(false);
      Get.off(
        () => OperationVerificationScreen(
          recordsScreen: () => AppointmentsScreen(),
          operationType: CriticalOperationType.appointment,
          operationKey: operationKey,
        ),
      );
    } on PendingCriticalOperationException {
      isLoading(false);
      Get.off(
        () => OperationVerificationScreen(
          recordsScreen: () => AppointmentsScreen(),
          operationType: CriticalOperationType.appointment,
          operationKey: operationKey ??
              CriticalOperationStore.pendingKey(
                CriticalOperationType.appointment,
                scope: operationScope,
              ),
        ),
      );
    } catch (e) {
      await CriticalOperationStore.complete(
        CriticalOperationType.appointment,
        scope: operationScope,
      );
      isLoading(false);
      toast(
        sanitizeBackendMessage(
            e, locale.value.somethingWentWrongPleaseTryAgainLater),
        print: true,
      );
    }
  }

  void onPaymentSuccess() async {
    isLoading(false);
    reLoadBookingsOnDashboard();
    await Future.delayed(const Duration(milliseconds: 300));
    Get.offUntil(
        GetPageRoute(
            page: () => BookingSuccessScreen(),
            binding: BindingsBuilder(() {
              setStatusBarColor(transparentColor,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.dark);
            })),
        (route) => route.isFirst || route.settings.name == '/$DashboardScreen');
  }

  @override
  void onClose() {
    optionalCont.dispose();
    super.onClose();
  }
}

void reLoadBookingsOnDashboard() {
  try {
    AppointmentsController aCont = Get.find();
    aCont.getAppointmentList();
  } catch (e) {
    log('E: $e');
  }
  try {
    DashboardController dashboardController = Get.find();
    dashboardController.currentIndex(1);
    dashboardController.reloadBottomTabs();
  } catch (e) {
    log('E: $e');
  }
  AuthServiceApis.getUserWallet();
}
