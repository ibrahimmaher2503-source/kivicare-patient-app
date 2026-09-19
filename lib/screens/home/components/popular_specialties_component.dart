import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/view_all_label_component.dart';
import '../../category/category_screen.dart';
import '../../category/model/category_list_model.dart';
import '../../service/services_list_screen.dart';
import '../../service/system_service_list_screen.dart';
import '../home_controller.dart';

class _SpecialtyItem {
  final int id;
  final String name;
  final String nameAr;
  final String? iconUrl;
  final int displayOrder;

  _SpecialtyItem({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.iconUrl,
    required this.displayOrder,
  });

  factory _SpecialtyItem.fromCategory(
    CategoryElement category,
    int displayOrder,
  ) {
    return _SpecialtyItem(
      id: category.id,
      name: category.name,
      nameAr: category.name,
      iconUrl: category.categoryImage,
      displayOrder: displayOrder,
    );
  }

  String localizedName(String langCode) {
    if (langCode == 'ar' && nameAr.isNotEmpty) return nameAr;
    return name.isNotEmpty ? name : nameAr;
  }
}

class PopularSpecialtiesComponent extends StatefulWidget {
  const PopularSpecialtiesComponent({super.key});

  @override
  State<PopularSpecialtiesComponent> createState() => _PopularSpecialtiesComponentState();
}

class _PopularSpecialtiesComponentState extends State<PopularSpecialtiesComponent> {
  final HomeController homeController = Get.find();
  late final Future<List<_SpecialtyItem>> _futureSpecialties;

  static const List<Color> _accentPalette = [
    specialtyAccentTeal,
    specialtyAccentIndigo,
    specialtyAccentOrange,
    specialtyAccentPlum,
    specialtyAccentOcean,
    specialtyAccentBrick,
    specialtyAccentEmerald,
    specialtyAccentPersian,
  ];

  @override
  void initState() {
    super.initState();
    _futureSpecialties = _loadSpecialties();
  }

  Future<List<_SpecialtyItem>> _loadSpecialties() async {
    if (homeController.dashboardData.value.categories.isEmpty) {
      try {
        await homeController.getDashboardDetailFuture.value;
      } catch (_) {
        return const [];
      }
    }
    return homeController.dashboardData.value.categories
        .where((category) => category.id > 0 && category.name.trim().isNotEmpty)
        .take(8)
        .toList()
        .asMap()
        .entries
        .map((entry) => _SpecialtyItem.fromCategory(entry.value, entry.key))
        .toList();
  }

  void _onSpecialtyTap(_SpecialtyItem specialty) {
    final categories = homeController.dashboardData.value.categories;
    final match = categories.firstWhere(
      (c) => c.id == specialty.id,
      orElse: () => CategoryElement(
        id: specialty.id,
        name: specialty.localizedName(selectedLanguageCode.value),
      ),
    );
    if (appConfigs.value.isMultiVendor) {
      Get.to(() => SystemServiceListScreen(), arguments: match);
    } else {
      Get.to(() => ServiceListScreen(), arguments: match);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_SpecialtyItem>>(
      future: _futureSpecialties,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <_SpecialtyItem>[];
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.height,
            Obx(
              () => ViewAllLabel(
                label: locale.value.specialization,
                onTap: () {
                  Get.to(() => CategoryScreen(), duration: const Duration(milliseconds: 800));
                },
                trailingText: locale.value.viewAll,
              ),
            ).paddingOnly(left: 16, right: 8),
            Obx(
              () {
                final langCode = selectedLanguageCode.value;
                return HorizontalList(
                  runSpacing: 16,
                  spacing: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  wrapAlignment: WrapAlignment.start,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final specialty = items[index];
                    final accent = _accentPalette[index % _accentPalette.length];
                    return _SpecialtyCard(
                      specialty: specialty,
                      accent: accent,
                      langCode: langCode,
                      onTap: () => _onSpecialtyTap(specialty),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _SpecialtyCard extends StatelessWidget {
  final _SpecialtyItem specialty;
  final Color accent;
  final String langCode;
  final VoidCallback onTap;

  const _SpecialtyCard({
    required this.specialty,
    required this.accent,
    required this.langCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasIcon = specialty.iconUrl != null && specialty.iconUrl!.trim().isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Get.width / 3 - 24,
        height: Get.width * 0.32,
        alignment: Alignment.center,
        decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: hasIcon
                  ? CachedImageWidget(
                      url: specialty.iconUrl!,
                      fit: BoxFit.contain,
                      circle: true,
                      height: 40,
                      width: 40,
                    )
                  : Icon(Icons.medical_services_rounded, color: accent, size: 30),
            ).paddingSymmetric(horizontal: 8, vertical: 6),
            Text(
              specialty.localizedName(langCode),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: primaryTextStyle(size: 13, decoration: TextDecoration.none),
            ).paddingSymmetric(horizontal: 6),
          ],
        ),
      ),
    );
  }
}
