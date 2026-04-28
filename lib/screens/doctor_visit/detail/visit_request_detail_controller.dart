import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../api/doctor_visit_apis.dart';
import '../models/visit_request_model.dart';

class VisitRequestDetailController extends GetxController {
  final String referenceNumber;

  VisitRequestDetailController({required this.referenceNumber});

  final Rxn<VisitRequestModel> request = Rxn<VisitRequestModel>();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequest();
  }

  Future<void> fetchRequest() async {
    isLoading(true);
    error('');
    try {
      final result = await DoctorVisitApis.getRequestByReference(referenceNumber);
      request.value = result;
    } catch (e) {
      error(e.toString());
      toast(e.toString());
    } finally {
      isLoading(false);
    }
  }

  @override
  Future<void> refresh() => fetchRequest();
}
