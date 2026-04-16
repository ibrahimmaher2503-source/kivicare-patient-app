import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../utils/constants.dart';
import 'model/independent_booking_model.dart';

class IndependentBookingListController extends GetxController {
  // List state
  Rx<Future<RxList<IndependentBooking>>> bookingFuture = Future(() => RxList<IndependentBooking>()).obs;
  RxList<IndependentBooking> bookings = RxList<IndependentBooking>();
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
      CoreServiceApis.getIndependentBookingList(
        page: page.value,
        perPage: Constants.perPageItem,
        bookingList: bookings,
        lastPageCallBack: (isLast) => isLastPage(isLast),
      ),
    ).then((value) {
      log('Independent bookings fetched: ${value.length}');
    }).catchError((e) {
      log("getBookings error $e");
    }).whenComplete(() => isLoading(false));
  }
}
