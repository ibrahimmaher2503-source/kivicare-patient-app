import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import 'model/doctor_visit_request_model.dart';

class DoctorVisitDetailController extends GetxController {
  final String referenceNumber;

  DoctorVisitDetailController({required this.referenceNumber});

  final Rx<DoctorVisitRequest?> request = Rx<DoctorVisitRequest?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  bool get isAdmin {
    final roles = loginUserData.value.userRole;
    return roles.contains('admin') || roles.contains('receptionist');
  }

  bool get isAssignedDoctor {
    final roles = loginUserData.value.userRole;
    if (!roles.contains('doctor')) return false;
    return request.value?.assignedDoctor?.id == loginUserData.value.id;
  }

  bool get canUpdateStatus => isAdmin || isAssignedDoctor;
  bool get canAssignDoctor => isAdmin;

  @override
  void onInit() {
    super.onInit();
    loadDetail();
  }

  Future<void> loadDetail() async {
    isLoading(true);
    errorMessage.value = '';

    await CoreServiceApis.getDoctorVisitRequestDetail(reference: referenceNumber).then((value) {
      request.value = value;
    }).catchError((e) {
      errorMessage.value = e.toString();
      toast(e.toString());
    }).whenComplete(() {
      isLoading(false);
    });
  }

  Future<void> updateStatus(String newStatus, {String? cancellationReason, String? note}) async {
    isLoading(true);

    final body = <String, dynamic>{'status': newStatus};
    if (cancellationReason != null && cancellationReason.isNotEmpty) {
      body['cancellation_reason'] = cancellationReason;
    }
    if (note != null && note.isNotEmpty) {
      body['note'] = note;
    }

    await CoreServiceApis.updateDoctorVisitRequestStatus(
      reference: referenceNumber,
      request: body,
    ).then((value) {
      request.value = value;
      toast(locale.value.visitRequestUpdated);
    }).catchError((e) {
      toast(e.toString());
    }).whenComplete(() {
      isLoading(false);
    });
  }

  Future<void> assignDoctor(int doctorId) async {
    isLoading(true);

    await CoreServiceApis.assignDoctorToVisitRequest(
      reference: referenceNumber,
      request: {'doctor_id': doctorId},
    ).then((value) {
      request.value = value;
      toast(locale.value.doctorAssigned);
    }).catchError((e) {
      toast(e.toString());
    }).whenComplete(() {
      isLoading(false);
    });
  }
}
