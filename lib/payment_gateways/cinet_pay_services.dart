import 'package:flutter/material.dart';

class CinetPayServices {
  num totalAmount;
  Function(Map) onComplete;

  CinetPayServices({
    required this.totalAmount,
    required this.onComplete,
  });

  Future<void> payWithCinetPay({required BuildContext context}) async {
    throw UnsupportedError(
      'CinetPay is disabled until transactions and verified callbacks are created server-side.',
    );
  }
}
