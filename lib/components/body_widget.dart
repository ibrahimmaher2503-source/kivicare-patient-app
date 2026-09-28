import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'loader_widget.dart';

class Body extends StatelessWidget {
  final Widget child;
  final RxBool? isLoading;

  const Body({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      height: Get.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (isLoading != null)
            Obx(
              () => isLoading!.value
                  ? const BlockingLoaderWidget()
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
