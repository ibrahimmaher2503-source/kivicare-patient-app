import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../network/network_utils.dart';
import '../utils/app_common.dart';

class PayStackService {
  PaystackPlugin paystackPlugin = PaystackPlugin();
  num totalAmount = 0;
  late Function(Map<String, dynamic>) onComplete;
  late Function(bool) loderOnOFF;

  void init(
      {required num totalAmount,
      required Function(Map<String, dynamic>) onComplete,
      required Function(bool) loderOnOFF}) {
    paystackPlugin.initialize(
        publicKey: appConfigs.value.paystackPay.paystackPublickey.validate());
    this.totalAmount = totalAmount;
    this.onComplete = onComplete;
    this.loderOnOFF = loderOnOFF;
  }

  Future checkout() async {
    loderOnOFF(true);
    int price = totalAmount.toInt() * 100;
    Charge charge = Charge()
      ..amount = price
      ..reference = 'ref_${DateTime.now().millisecondsSinceEpoch}'
      ..email = loginUserData.value.email
      ..currency = appCurrency.value.currencyCode;

    try {
      CheckoutResponse response = await paystackPlugin.checkout(
        Get.context!,
        method: CheckoutMethod.card,
        charge: charge,
      );

      if (response.status == true) {
        onComplete.call({
          'transaction_id': response.reference.validate(),
        });
      } else {
        toast(
            sanitizeBackendMessage(
              response.message,
              locale.value.transactionFailed,
            ),
            print: true);
      }
    } catch (e) {
      toast(sanitizeBackendMessage(e, locale.value.transactionFailed));
    } finally {
      loderOnOFF(false);
    }
  }
}
