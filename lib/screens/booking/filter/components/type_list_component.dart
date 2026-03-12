import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/app_common.dart';
import '../../../../utils/colors.dart';
import '../filter_controller.dart';

class FilterTypeListComponent extends StatefulWidget {
  final List<dynamic> filterList;
  const FilterTypeListComponent({super.key, required this.filterList});

  @override
  State<FilterTypeListComponent> createState() => _FilterTypeListComponentState();
}

class _FilterTypeListComponentState extends State<FilterTypeListComponent> {
  final FilterController filterCont = Get.put(FilterController());
  @override
  void initState() {
    super.initState();
    if (widget.filterList.isNotEmpty &&
        filterCont.filterType.value != widget.filterList.first) {
      filterCont.filterType(widget.filterList.first);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height,
      width: 88,
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
        border: Border(
          right: BorderSide(
            color: isDarkMode.value ? glassStrokeDark : whiteBorderColor,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        itemCount: widget.filterList.length,
        padding: const EdgeInsets.only(top: 8),
        itemBuilder: (context, index) {
          return Obx(
            () {
              final bool isSelected = filterCont.filterType.value == widget.filterList[index];
              return InkWell(
                onTap: () {
                  filterCont.filterType(widget.filterList[index]);
                  filterCont.filterType.refresh();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 48,
                  width: double.infinity,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? isDarkMode.value
                            ? appColorSecondary.withValues(alpha: 0.15)
                            : lightSecondaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: appColorSecondary.withValues(alpha: 0.3), width: 1)
                        : null,
                  ),
                  child: Text(
                    "${widget.filterList[index]}",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? appColorSecondary
                          : isDarkMode.value
                              ? Colors.white70
                              : secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  bool checkFilterType(String type) {
    if (filterCont.filterType.value == type) {
      return true;
    }
    return false;
  }
}
