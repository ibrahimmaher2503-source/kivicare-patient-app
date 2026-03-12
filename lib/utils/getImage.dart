// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import 'app_common.dart';
import 'colors.dart';

class GetImage {
  ImageSource imageSource;
  Function path;

  GetImage(this.imageSource, {required this.path(String imgPath, String imgName, XFile pickedFile)}) {
    getImage();
  }

  Future getImage() async {
    var pickedFile = await ImagePicker().pickImage(source: imageSource, imageQuality: 100);

    if (pickedFile != null) {
      log('imgFile path: ${pickedFile.path}');
      path(pickedFile.path, pickedFile.name, pickedFile);
    }
  }
}

class GetMultipleImage {
  Function path;

  GetMultipleImage({required this.path(List<XFile> pickedFiles)}) {
    getImage();
  }

  Future getImage() async {
    var pickedFile = await ImagePicker().pickMultiImage(imageQuality: 100);
    path(pickedFile);
  }
}

/// Shows a styled Clinical Luxury bottom sheet for choosing between
/// camera and gallery image sources. Calls [onImageSelected] with the
/// picked file details.
///
/// Usage:
/// ```dart
/// showImagePickerSheet(
///   context: context,
///   onImageSelected: (path, name, file) { ... },
/// );
/// ```
void showImagePickerSheet({
  required BuildContext context,
  required Function(String imgPath, String imgName, XFile pickedFile) onImageSelected,
  String? title,
  String? cameraLabel,
  String? galleryLabel,
}) {
  final bool dark = isDarkMode.value;
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) {
      return Container(
        decoration: BoxDecoration(
          color: dark ? surfaceElevatedDark : surfaceElevated,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: dark ? softShadowColorDark : softShadowColor,
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: dark ? borderColorDark : borderColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  title ?? 'Choose Image',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: dark ? Colors.white : primaryTextColor,
                  ),
                ),
                const SizedBox(height: 20),
                // Camera option
                _ImagePickerOption(
                  icon: Icons.camera_alt_outlined,
                  label: cameraLabel ?? 'Camera',
                  dark: dark,
                  onTap: () {
                    Get.back();
                    GetImage(ImageSource.camera, path: onImageSelected);
                  },
                ),
                const SizedBox(height: 12),
                // Gallery option
                _ImagePickerOption(
                  icon: Icons.photo_library_outlined,
                  label: galleryLabel ?? 'Gallery',
                  dark: dark,
                  onTap: () {
                    Get.back();
                    GetImage(ImageSource.gallery, path: onImageSelected);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _ImagePickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool dark;
  final VoidCallback onTap;

  const _ImagePickerOption({
    required this.icon,
    required this.label,
    required this.dark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: dark ? surfaceElevatedDark : surfaceSubtle,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: dark ? borderColorDark : borderColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: appColorSecondary.withValues(alpha: dark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: appColorSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                  color: dark ? Colors.white : primaryTextColor,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: secondaryTextColor,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
