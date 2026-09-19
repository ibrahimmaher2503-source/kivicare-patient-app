import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../api/icu_apis.dart';
import '../../../main.dart';
import '../../../network/network_utils.dart';
import '../../../utils/common_base.dart';
import '../models/hospital_model.dart';

class HospitalDetailController extends GetxController {
  final int hospitalId;
  final hospital = Rxn<Hospital>();
  final isLoading = false.obs;

  HospitalDetailController({required this.hospitalId});

  @override
  void onInit() {
    super.onInit();
    getHospitalDetail();
  }

  Future<void> getHospitalDetail() async {
    isLoading(true);
    try {
      hospital.value = await IcuApis.getHospitalDetail(hospitalId);
    } catch (e) {
      toast(sanitizeBackendMessage(
          e, locale.value.somethingWentWrongPleaseTryAgainLater));
    } finally {
      isLoading(false);
    }
  }

  Future<void> callPhone() async {
    if (hospital.value?.phone.validate().isNotEmpty ?? false) {
      final phoneNumber = hospital.value!.phone!;
      final uri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await Clipboard.setData(ClipboardData(text: phoneNumber));
        toast(locale.value.copied);
      }
    }
  }

  Future<void> callEmergencyPhone() async {
    if (hospital.value?.emergencyPhone.validate().isNotEmpty ?? false) {
      final phoneNumber = hospital.value!.emergencyPhone!;
      final uri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await Clipboard.setData(ClipboardData(text: phoneNumber));
        toast(locale.value.copied);
      }
    }
  }

  void openInMaps() {
    if (hospital.value?.latitude != null && hospital.value?.longitude != null) {
      launchMap('${hospital.value!.latitude},${hospital.value!.longitude}');
    }
  }
}
