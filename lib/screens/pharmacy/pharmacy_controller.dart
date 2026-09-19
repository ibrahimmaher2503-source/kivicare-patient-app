import 'package:get/get.dart';
import '../../api/pharmacy_apis.dart';
import '../../utils/app_common.dart';
import 'package:nb_utils/nb_utils.dart';

class PharmacyController extends GetxController {
  RxInt cartCount = 0.obs;
  RxInt unreadNotificationsCount = 0.obs;
  RxBool isLoading = false.obs;

  /// Cached full cart response. CartScreen and CheckoutScreen can read
  /// `Get.find<PharmacyController>().cachedCart.value` to avoid independent
  /// fetches instead of calling PharmacyApis.getCart() on their own.
  Rx<dynamic> cachedCart = Rx<dynamic>(null);
  late final void Function() _sessionStateClearer;

  /// Ensures a single permanent instance is registered. Call this from the
  /// app entry point (or wherever the pharmacy module is first accessed) so
  /// that all screens can safely call `Get.find<PharmacyController>()`.
  static PharmacyController ensureRegistered() {
    if (!Get.isRegistered<PharmacyController>()) {
      Get.put(PharmacyController(), permanent: true);
    }
    return Get.find<PharmacyController>();
  }

  @override
  void onInit() {
    super.onInit();
    _sessionStateClearer = clearSessionState;
    registerSessionStateClearer(_sessionStateClearer);
    if (isLoggedIn.value) {
      refreshPharmacyState();
    }
  }

  Future<void> refreshPharmacyState() async {
    isLoading(true);
    await Future.wait([
      updateCartCount(),
      updateUnreadNotificationsCount(),
    ]).whenComplete(() => isLoading(false));
  }

  Future<void> updateCartCount() async {
    try {
      final response = await PharmacyApis.getCart();
      if (response != null && response['data'] != null) {
        // Cache the full cart payload so screens can reuse it without
        // a second network call (addresses W3 — no shared cart state).
        cachedCart.value = response;
        cartCount(response['data']['items']?.length ?? 0);
      }
    } catch (e) {
      log('Error updating cart count: $e');
    }
  }

  Future<void> updateUnreadNotificationsCount() async {
    try {
      final response = await PharmacyApis.getUnreadNotificationsCount();
      if (response != null && response['data'] != null) {
        unreadNotificationsCount(response['data']['unread_count'] ?? 0);
      }
    } catch (e) {
      log('Error updating unread notifications count: $e');
    }
  }

  void incrementCartCount() => cartCount.value++;
  void decrementCartCount() => cartCount.value > 0 ? cartCount.value-- : null;
  void resetCartCount() => cartCount(0);

  void clearCartAfterOrder() {
    cartCount(0);
    cachedCart.value = null;
  }

  void clearSessionState() {
    cartCount(0);
    unreadNotificationsCount(0);
    cachedCart.value = null;
    isLoading(false);
  }

  @override
  void onClose() {
    unregisterSessionStateClearer(_sessionStateClearer);
    super.onClose();
  }
}
