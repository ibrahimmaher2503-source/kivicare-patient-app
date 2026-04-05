import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/constants.dart';
import '../../utils/rbac_utils.dart';
import 'model/test_order_model.dart';

class TestOrderListController extends GetxController {
  // List state
  Rx<Future<RxList<TestOrder>>> orderFuture = Future(() => RxList<TestOrder>()).obs;
  RxList<TestOrder> orders = RxList<TestOrder>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  // Status filter
  RxString selectedStatus = ''.obs;
  RxList<Map<String, String>> statusFilters = RxList();

  @override
  void onInit() {
    statusFilters = [
      {'key': '', 'label': locale.value.all},
      {'key': 'pending', 'label': locale.value.pending},
      {'key': 'confirmed', 'label': locale.value.confirmed},
      {'key': 'sample_collected', 'label': locale.value.sampleCollected},
      {'key': 'processing', 'label': locale.value.processing},
      {'key': 'completed', 'label': locale.value.completed},
      {'key': 'delivered', 'label': locale.value.delivered},
      {'key': 'cancelled', 'label': locale.value.cancelled},
    ].obs;

    getTestOrders();
    super.onInit();
  }

  Future<void> getTestOrders({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    await orderFuture(
      CoreServiceApis.getTestOrderList(
        page: page.value,
        perPage: Constants.perPageItem,
        orderList: orders,
        status: selectedStatus.value,
        lastPageCallBack: (isLast) => isLastPage(isLast),
      ),
    ).then((value) {
      log('Test orders fetched: ${value.length}');
    }).catchError((e) {
      log("getTestOrders error $e");
      toast(locale.value.somethingWentWrong);
    }).whenComplete(() => isLoading(false));
  }

  void onFilterChanged(String status) {
    selectedStatus(status);
    page(1);
    getTestOrders();
  }

  /// Check if current user has role
  bool hasRole(String role) {
    return loginUserData.value.userRole.contains(role);
  }

  /// Get user's role for filtering
  String? getUserRole() {
    if (hasRole('admin')) return 'admin';
    if (hasRole('doctor')) return 'doctor';
    if (hasRole('lab_technician')) return 'lab_technician';
    if (hasRole('user')) return 'user';
    return null;
  }

  /// Check if user can view order (RBAC check)
  bool canViewOrder(TestOrder order) {
    final userRole = getUserRole();
    if (userRole == 'admin') {
      RBACUtils.logAccessAttempt('TestOrder#${order.id}', true, null);
      return true;
    }

    final userId = loginUserData.value.id;
    if (userRole == 'user') {
      final canAccess = order.patientId == userId;
      RBACUtils.logAccessAttempt(
        'TestOrder#${order.id}',
        canAccess,
        canAccess ? null : 'Patient#$userId cannot access PatientOrder#${order.patientId}',
      );
      return canAccess;
    }
    if (userRole == 'doctor') {
      final canAccess = order.doctorId == userId;
      RBACUtils.logAccessAttempt(
        'TestOrder#${order.id}',
        canAccess,
        canAccess ? null : 'Doctor#$userId cannot access DoctorOrder#${order.doctorId}',
      );
      return canAccess;
    }
    if (userRole == 'lab_technician') {
      RBACUtils.logAccessAttempt('TestOrder#${order.id}', true, null);
      return true; // Backend filters by assigned tech
    }

    RBACUtils.logAccessAttempt('TestOrder#${order.id}', false, 'Invalid role: $userRole');
    return false;
  }

  /// Check if user can cancel order
  bool canCancelOrder(TestOrder order) {
    if (!hasRole('user') && !hasRole('admin')) {
      RBACUtils.logAccessAttempt(
        'TestOrder#${order.id}:cancel',
        false,
        'User does not have required role',
      );
      return false;
    }

    // Only pending and confirmed orders can be cancelled
    if (order.status != 'pending' && order.status != 'confirmed') {
      RBACUtils.logAccessAttempt(
        'TestOrder#${order.id}:cancel',
        false,
        'Order status is ${order.status}, cannot cancel',
      );
      return false;
    }

    // Patient can cancel own orders, admin can cancel any
    if (hasRole('admin')) {
      RBACUtils.logAccessAttempt('TestOrder#${order.id}:cancel', true, null);
      return true;
    }
    if (hasRole('user')) {
      final canAccess = order.patientId == loginUserData.value.id;
      RBACUtils.logAccessAttempt(
        'TestOrder#${order.id}:cancel',
        canAccess,
        canAccess ? null : 'Patient#${loginUserData.value.id} cannot cancel PatientOrder#${order.patientId}',
      );
      return canAccess;
    }

    return false;
  }
}
