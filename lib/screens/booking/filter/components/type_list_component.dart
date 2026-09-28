import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../utils/app_common.dart';
import '../../../../utils/colors.dart';
import '../filter_controller.dart';

class FilterTypeListComponent extends StatefulWidget {
  final List<dynamic> filterList;
  const FilterTypeListComponent({super.key, required this.filterList});

  @override
  State<FilterTypeListComponent> createState() =>
      _FilterTypeListComponentState();
}

class _FilterTypeListComponentState extends State<FilterTypeListComponent> {
  final FilterController filterCont = Get.find<FilterController>();
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
      width: 80,
      decoration: boxDecorationDefault(
          borderRadius: radius(0), color: context.cardColor),
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        itemCount: widget.filterList.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return Obx(
            () => Semantics(
              button: true,
              selected: filterCont.filterType.value == widget.filterList[index],
              label: '${widget.filterList[index]}',
              onTap: () {
                filterCont.filterType(widget.filterList[index]);
                filterCont.filterType.refresh();
              },
              child: InkWell(
                onTap: () {
                  filterCont.filterType(widget.filterList[index]);
                  filterCont.filterType.refresh();
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  alignment: Alignment.center,
                  color: filterCont.filterType.value == widget.filterList[index]
                      ? isDarkMode.value
                          ? appScreenBackgroundDark
                          : appScreenBackground
                      : context.cardColor,
                  child: Text(
                    "${widget.filterList[index]}",
                    style:
                        filterCont.filterType.value == widget.filterList[index]
                            ? boldTextStyle(size: 12, color: appColorPrimary)
                            : primaryTextStyle(size: 12),
                  ),
                ),
              ),
            ),
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
