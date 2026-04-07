import '../../generated/assets.dart';

class UpiApps {
  String? name;
  String? imagePath;
  String? packageName;

  UpiApps({this.name, this.imagePath, this.packageName});

  List<Map<String, String>> upiAppList = [
    {"name": "PhonePe", "image": Assets.upiPaymentPhonepeIcon, "packageName": "com.phonepe.app"},
    {"name": "Freecharge", "image": Assets.upiPaymentFreecharge, "packageName": "com.freecharge.android"},
    {"name": "Paytm", "image": Assets.upiPaymentPaytm, "packageName": "net.one97.paytm"},
    {"name": "BHIM", "image": Assets.upiPaymentBhmin, "packageName": "in.org.npci.upiapp"},
    {"name": "MobiKwik", "image": Assets.upiPaymentMobikwik, "packageName": "com.mobikwik_new"},
    {"name": "Google Pay", "image": Assets.upiPaymentGpay, "packageName": "com.google.android.apps.nbu.paisa.user"},
    {"name": "Axis Pay", "image": Assets.upiPaymentAxisPay, "packageName": "com.upi.axispay"},
    {"name": "BOB UPI", "image": Assets.upiPaymentBobUpi, "packageName": "com.bankofbaroda.upi"},
    {"name": "Amazon Pay", "image": Assets.upiPaymentAmazonPay, "packageName": "com.amazon.in.payments.merchant.app.android"},
    {"name": "Cred", "image": Assets.upiPaymentCred, "packageName": "com.dreamplug.androidapp"},
  ];
}

class UpiResponse {
  String? packageName;
  String? applicationName;
  String? version;

  UpiResponse({this.packageName, this.applicationName, this.version});

  UpiResponse.fromJson(Map<String, dynamic> json) {
    packageName = json['packageName'];
    applicationName = json['applicationName'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['packageName'] = packageName;
    data['applicationName'] = applicationName;
    data['version'] = version;
    return data;
  }
}
