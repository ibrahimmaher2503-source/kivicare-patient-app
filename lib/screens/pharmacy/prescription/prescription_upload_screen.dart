import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/pharmacy_apis.dart';
import '../../../components/app_scaffold.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../utils/pharmacy_constants.dart';
import 'prescription_list_screen.dart';

class PrescriptionUploadController extends GetxController {
  RxList<File> selectedImages = <File>[].obs;
  TextEditingController notesController = TextEditingController();
  RxBool isUploading = false.obs;
  final ImagePicker _imagePicker = ImagePicker();

  void pickImage(bool isCamera) async {
    if (selectedImages.length >= PharmacyConstants.maxPrescriptionImages) {
      toast(locale.value.maxImageLimitReached);
      return;
    }

    final pickedFile = await _imagePicker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85);
    if (pickedFile != null) {
      selectedImages.add(File(pickedFile.path));
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  Future<void> submitPrescription() async {
    if (selectedImages.isEmpty) {
      toast(locale.value.uploadPrescriptionInstructions);
      return;
    }

    isUploading(true);
    try {
      await PharmacyApis.uploadPrescriptionAsync(
        imagePaths: selectedImages.map((e) => e.path).toList(),
        notes: notesController.text,
      );
      toast(locale.value.successfullyAdded);
      Get.off(() => PrescriptionListScreen());
    } catch (e) {
      toast(e.toString());
    } finally {
      if (!isClosed) isUploading(false);
    }
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}

class PrescriptionUploadScreen extends StatelessWidget {
  PrescriptionUploadScreen({super.key});

  final PrescriptionUploadController controller =
      Get.put(PrescriptionUploadController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.uploadPrescription,
      isLoading: controller.isUploading,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(locale.value.uploadPrescriptionInstructions,
                style: secondaryTextStyle()),
            const SizedBox(height: 16),
            _buildImageGrid(context),
            const SizedBox(height: 24),
            Text(locale.value.notesOptional, style: boldTextStyle()),
            const SizedBox(height: 8),
            AppTextField(
              controller: controller.notesController,
              textFieldType: TextFieldType.MULTILINE,
              maxLines: 5,
              minLines: 3,
              decoration: inputDecoration(context,
                  hintText: locale.value.pharmacyNotesForPharmacy),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: locale.value.submitPrescription,
              color: appColorSecondary,
              textColor: Colors.white,
              width: Get.width,
              shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onTap: controller.submitPrescription,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    return Obx(() => Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ...controller.selectedImages.asMap().entries.map((entry) {
              int index = entry.key;
              File file = entry.value;
              return Stack(
                children: [
                  Image.file(file, height: 100, width: 100, fit: BoxFit.cover)
                      .cornerRadiusWithClipRRect(12),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => controller.removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              );
            }),
            if (controller.selectedImages.length <
                PharmacyConstants.maxPrescriptionImages)
              GestureDetector(
                onTap: () => _showImageSourceDialog(context),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: boxDecorationDefault(
                    color: lightPrimaryColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: appColorPrimary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo_outlined,
                          color: appColorPrimary),
                      const SizedBox(height: 4),
                      Text(locale.value.add,
                          style: const TextStyle(
                              fontSize: 12, color: appColorPrimary)),
                    ],
                  ),
                ),
              ),
          ],
        ));
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(locale.value.chooseImageSource,
                  style: boldTextStyle(size: 18)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceOption(
                      Icons.camera_alt_outlined, locale.value.camera, () {
                    Get.back();
                    controller.pickImage(true);
                  }),
                  _buildSourceOption(
                      Icons.photo_library_outlined, locale.value.gallery, () {
                    Get.back();
                    controller.pickImage(false);
                  }),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSourceOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: boxDecorationDefault(
                color: lightPrimaryColor, shape: BoxShape.circle),
            child: Icon(icon, color: appColorPrimary, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: primaryTextStyle()),
        ],
      ),
    );
  }
}
