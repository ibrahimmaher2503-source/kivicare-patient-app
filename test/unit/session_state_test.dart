import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/pharmacy/pharmacy_controller.dart';
import 'package:kivicare_patient/utils/app_common.dart';

void main() {
  test('registered session state is cleared exactly at the account boundary',
      () async {
    var calls = 0;
    void clearer() => calls++;

    registerSessionStateClearer(clearer);
    await clearSessionScopedState();
    unregisterSessionStateClearer(clearer);
    await clearSessionScopedState();

    expect(calls, 1);
  });

  test('pharmacy cached state can be reset before another user signs in', () {
    final controller = PharmacyController();
    controller.cartCount(3);
    controller.unreadNotificationsCount(4);
    controller.cachedCart.value = <String, dynamic>{'user': 1};
    controller.isLoading(true);

    controller.clearSessionState();

    expect(controller.cartCount.value, 0);
    expect(controller.unreadNotificationsCount.value, 0);
    expect(controller.cachedCart.value, isNull);
    expect(controller.isLoading.value, isFalse);
  });
}
