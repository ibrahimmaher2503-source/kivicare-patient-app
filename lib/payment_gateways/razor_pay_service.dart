import 'package:nb_utils/nb_utils.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../configs.dart';
import '../main.dart';
import '../network/network_utils.dart';
import '../utils/app_common.dart';
import '../utils/colors.dart';

class RazorPayService {
  static late Razorpay razorPay;
  static late String razorKeys;
  num totalAmount = 0;
  int bookingId = 0;
  late Function(Map<String, dynamic>) onComplete;

  void init({
    required String razorKey,
    required num totalAmount,
    required Function(Map<String, dynamic>) onComplete,
  }) {
    razorPay = Razorpay();
    razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
    razorKeys = razorKey;
    this.totalAmount = totalAmount;
    this.onComplete = onComplete;
  }

  Future handlePaymentSuccess(PaymentSuccessResponse response) async {
    onComplete.call({
      'transaction_id': response.paymentId,
    });
  }

  void handlePaymentError(PaymentFailureResponse response) {
    toast(
        sanitizeBackendMessage(
          response.message,
          locale.value.transactionFailed,
        ),
        print: true);
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    if (response.walletName != null) {
      toast(sanitizeBackendMessage(
        response.walletName,
        locale.value.transactionFailed,
      ));
    }
  }

  void razorPayCheckout() async {
    var options = {
      'key': appConfigs.value.razorPay.razorpaySecretkey,
      'amount': (totalAmount * 100).toInt(),
      'name': APP_NAME,
      'theme.color': appColorPrimary.toHex(),
      'description': APP_NAME,
      'image': APP_LOGO_URL,
      'currency': isIqonicProduct ? "INR" : appCurrency.value.currencyCode,
      'prefill': {
        'contact': loginUserData.value.mobile,
        'email': loginUserData.value.email
      },
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      razorPay.open(options);
    } catch (e) {
      log(e.toString());
      toast(sanitizeBackendMessage(e, locale.value.transactionFailed));
    }
  }
}
