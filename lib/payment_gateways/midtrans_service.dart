class MidtransService {
  num totalAmount = 0;
  int serviceId = 0;
  num servicePrice = 0;
  String serviceName = '';
  late Function(Map<String, dynamic>) onComplete;
  late Function(bool) loaderOnOFF;

  void initialize({
    required num totalAmount,
    required Function(Map<String, dynamic>) onComplete,
    required Function(bool) loaderOnOFF,
  }) {
    this.totalAmount = totalAmount;
    this.onComplete = onComplete;
    this.loaderOnOFF = loaderOnOFF;
  }

  Future midtransPaymentCheckout() async {
    throw UnsupportedError(
      'Midtrans is disabled until payment sessions and callbacks are handled server-side.',
    );
  }
}
