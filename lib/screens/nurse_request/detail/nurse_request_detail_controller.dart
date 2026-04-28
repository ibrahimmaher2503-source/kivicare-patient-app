import 'package:get/get.dart';
import 'package:kivicare_patient/api/nurse_request_apis.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/nurse_request_model.dart';

class NurseRequestDetailController extends GetxController {
  final int requestId;
  final Rxn<NurseRequestModel> request = Rxn<NurseRequestModel>();
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  NurseRequestDetailController({required this.requestId});

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    isLoading(true);
    error.value = null;
    try {
      final result = await NurseRequestApis.detail(id: requestId);
      request.value = result;
    } catch (e) {
      if (request.value == null) {
        error.value = e.toString();
      } else {
        toast(e.toString());
      }
    } finally {
      isLoading(false);
    }
  }
}
