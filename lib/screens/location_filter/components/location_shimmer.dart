import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';

class LocationShimmer extends StatefulWidget {
  final int itemCount;
  const LocationShimmer({super.key, this.itemCount = 6});

  @override
  State<LocationShimmer> createState() => _LocationShimmerState();
}

class _LocationShimmerState extends State<LocationShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = isDarkMode.value;
      final base = dark ? shimmerBaseDark : shimmerBase;
      final highlight = dark ? shimmerHighlightDark : shimmerHighlight;
      return AnimatedBuilder(
        animation: _animation,
        builder: (_, __) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: widget.itemCount,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => Container(
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment(_animation.value - 1, 0),
                  end: Alignment(_animation.value + 1, 0),
                  colors: [base, highlight, base],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
