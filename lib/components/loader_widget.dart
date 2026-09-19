import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../main.dart';
import '../utils/colors.dart';

class LoaderWidget extends StatelessWidget {
  final bool isBlurBackground;
  final Color? loaderColor;

  const LoaderWidget(
      {super.key, this.loaderColor, this.isBlurBackground = false});

  @override
  Widget build(BuildContext context) {
    final loader = SpinKitFadingCircle(
      size: 50,
      itemBuilder: (BuildContext context, int index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: loaderColor ?? appColorSecondary,
          ),
        );
      },
    );

    return isBlurBackground
        ? Semantics(
            label: locale.value.loading,
            liveRegion: true,
            child: AbsorbPointer(
              child: SizedBox(
                height: Get.height,
                width: Get.width,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 4.0, sigmaY: 4.0, tileMode: TileMode.mirror),
                  child: loader,
                ),
              ),
            ),
          )
        : Semantics(
            label: locale.value.loading,
            liveRegion: true,
            child: loader,
          );
  }
}

class BlockingLoaderWidget extends StatelessWidget {
  final bool isBlurBackground;

  const BlockingLoaderWidget({
    super.key,
    this.isBlurBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: locale.value.loading,
      liveRegion: true,
      container: true,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withValues(
              alpha: isBlurBackground ? 0.18 : 0.06,
            ),
          ),
          Center(
            child: LoaderWidget(isBlurBackground: isBlurBackground),
          ),
        ],
      ),
    );
  }
}

class ThreeBounceLoadingWidget extends StatelessWidget {
  const ThreeBounceLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SpinKitThreeBounce(
      size: 30,
      itemBuilder: (BuildContext context, int index) {
        return const DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: appColorPrimary,
          ),
        );
      },
    );
  }
}
