import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';

class IcuShimmer extends StatefulWidget {
  final int itemCount;
  final double height;
  final EdgeInsetsGeometry? padding;

  const IcuShimmer({
    super.key,
    this.itemCount = 6,
    this.height = 100,
    this.padding,
  });

  @override
  State<IcuShimmer> createState() => _IcuShimmerState();
}

class _IcuShimmerState extends State<IcuShimmer> with SingleTickerProviderStateMixin {
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
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: widget.itemCount,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => Container(
              height: widget.height,
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
