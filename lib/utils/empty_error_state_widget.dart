import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../generated/assets.dart';
import '../main.dart';

class EmptyStateWidget extends StatelessWidget {
  final double? height;
  final double? width;

  const EmptyStateWidget({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: locale.value.noDataFound,
      image: true,
      child: Lottie.asset(
        Assets.lottieEmptyLottie,
        height: height ?? 150,
        width: width,
        repeat: true,
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final double? height;
  final double? width;

  const ErrorStateWidget({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: locale.value.somethingWentWrongPleaseTryAgainLater,
      image: true,
      child: Lottie.asset(
        Assets.lottieErrorLottie,
        height: height ?? 110,
        width: width,
        repeat: true,
      ),
    );
  }
}
