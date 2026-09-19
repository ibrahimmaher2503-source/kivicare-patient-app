import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/colors.dart';

/// Animated shimmer placeholders for the Labs & Radiology screens.
///
/// Mirrors the sibling `IcuShimmer` approach (no external package — a moving
/// linear gradient driven by a single repeating animation) but renders a
/// silhouette that matches the real cards (logo block + text lines) so the
/// loading state reads as "content is coming", not just a spinner.

class _ShimmerScope extends StatefulWidget {
  final Widget Function(double t, Color base, Color highlight) builder;

  const _ShimmerScope({required this.builder});

  @override
  State<_ShimmerScope> createState() => _ShimmerScopeState();
}

class _ShimmerScopeState extends State<_ShimmerScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

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
        builder: (_, __) => widget.builder(_animation.value, base, highlight),
      );
    });
  }
}

Widget _shimmerBlock(
  double t,
  Color base,
  Color highlight, {
  double? width,
  double height = 12,
  double radius = 8,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment(t - 1, 0),
        end: Alignment(t + 1, 0),
        colors: [base, highlight, base],
      ),
    ),
  );
}

BoxDecoration _cardDecoration(bool dark) {
  return BoxDecoration(
    color: dark ? surfaceElevatedDark : surfaceElevated,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: dark ? softShadowColorDark : softShadowColor,
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

/// Skeleton list of facility cards (used by the hub while facilities load).
class LabsFacilityShimmer extends StatelessWidget {
  final int itemCount;

  const LabsFacilityShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return _ShimmerScope(
      builder: (t, base, highlight) {
        final dark = isDarkMode.value;
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: itemCount,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, __) => Container(
            padding: const EdgeInsets.all(14),
            decoration: _cardDecoration(dark),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBlock(t, base, highlight,
                    width: 76, height: 76, radius: 14),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _shimmerBlock(t, base, highlight,
                              width: 64, height: 18, radius: 999),
                          _shimmerBlock(t, base, highlight,
                              width: 44, height: 18, radius: 999),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _shimmerBlock(t, base, highlight,
                          width: double.infinity, height: 14),
                      const SizedBox(height: 8),
                      _shimmerBlock(t, base, highlight, width: 150, height: 12),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _shimmerBlock(t, base, highlight,
                              width: 70, height: 12),
                          _shimmerBlock(t, base, highlight,
                              width: 90, height: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton list of test rows (used by the facility detail while tests load).
class LabsTestShimmer extends StatelessWidget {
  final int itemCount;

  const LabsTestShimmer({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return _ShimmerScope(
      builder: (t, base, highlight) {
        final dark = isDarkMode.value;
        return Column(
          children: List.generate(
            itemCount,
            (_) => Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(dark),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerBlock(t, base, highlight,
                            width: 160, height: 14),
                        const SizedBox(height: 8),
                        _shimmerBlock(t, base, highlight,
                            width: 80, height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _shimmerBlock(t, base, highlight,
                      width: 76, height: 34, radius: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
