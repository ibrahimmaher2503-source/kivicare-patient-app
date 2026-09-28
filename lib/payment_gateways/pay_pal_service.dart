import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../configs.dart';
import '../main.dart';
import '../network/network_utils.dart';
import '../utils/app_common.dart';

class PayPalService {
  Future paypalCheckOut(
      {required BuildContext context,
      required num totalAmount,
      required Function(Map<String, dynamic>) onComplete,
      required Function(bool) loderOnOFF}) async {
    loderOnOFF(true);
    String payPalClientId =
        appConfigs.value.paypalPay.paypalClientid.validate();
    String secretKey = appConfigs.value.paypalPay.paypalSecretkey.validate();
    PaypalCheckout(
      sandboxMode: (!kReleaseMode || isIqonicProduct),
      clientId: payPalClientId,
      secretKey: secretKey,
      returnURL: "junedr375.github.io/junedr375-payment/",
      cancelURL: "junedr375.github.io/junedr375-payment/error.html",
      transactions: [
        {
          "amount": {
            "total": totalAmount,
            "currency": isIqonicProduct
                ? payPalSupportedCurrency
                : appCurrency.value.currencyCode,
            "details": {
              "subtotal": totalAmount,
              "shipping": '0',
              "shipping_discount": 0
            }
          },
          "description":
              'Name: ${loginUserData.value.userName} - Email: ${loginUserData.value.email}',
        }
      ],
      note: " - ",
      onSuccess: (Map params) async {
        log("onSuccess: $params");
        loderOnOFF(false);
        if (params['message'] is String) {
          toast(sanitizeBackendMessage(
              params['message'], locale.value.transactionFailed));
        }
        onComplete.call({
          'transaction_id': params['data']['id'],
        });
      },
      onError: (error) {
        log("onError: $error");
        loderOnOFF(false);
        toast(sanitizeBackendMessage(error, locale.value.transactionFailed));
        Get.back();
      },
      onCancel: (params) {
        log("cancelled: $params");
        toast(locale.value.transactionCancelled);
        loderOnOFF(false);
      },
    )
        .launch(context)
        .whenComplete(() => loderOnOFF(false))
        .onError((e, stackTrace) {
      toast(sanitizeBackendMessage(e, locale.value.transactionFailed));
      loderOnOFF(false);
    });
  }
}
