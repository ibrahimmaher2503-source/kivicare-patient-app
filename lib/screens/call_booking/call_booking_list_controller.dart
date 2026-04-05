import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../utils/constants.dart';
import 'model/call_booking_model.dart';

class CallBookingListController extends GetxController {
  // List state
  Rx<Future<RxList<CallBooking>>> bookingFuture = Future(() => RxList<CallBooking>()).obs;
  RxList<CallBooking> bookings = RxList<CallBooking>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  @override
  void onInit() {
    getBookings();
    super.onInit();
  }

  Future<void> getBookings({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    await bookingFuture(
      CoreServiceApis.getCallBookingList(
        page: page.value,
        perPage: Constants.perPageItem,
        bookingList: bookings,
        lastPageCallBack: (isLast) => isLastPage(isLast),
      ),
    ).then((value) {
      log('Call bookings fetched: ${value.length}');
    }).catchError((e) {
      log("getBookings error $e");
    }).whenComplete(() => isLoading(false));
  }
}
