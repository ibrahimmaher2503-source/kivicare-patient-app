import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/utils/colors.dart';
import '../../../components/app_shader_widget.dart';
import '../../../utils/app_common.dart';
import 'menu.dart';

class BtmNavItem extends StatefulWidget {
  const BtmNavItem({
    super.key,
    required this.navBar,
    required this.press,
    required this.selectedNav,
    this.isLast = false,
    this.isFirst = false,
  });

  final BottomBarItem navBar;
  final VoidCallback press;
  final BottomBarItem selectedNav;
  final bool isLast;
  final bool isFirst;

  @override
  State<BtmNavItem> createState() => _BtmNavItemState();
}

class _BtmNavItemState extends State<BtmNavItem> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  bool get isActive => widget.selectedNav == widget.navBar;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    if (isActive) _animController.forward();
  }

  @override
  void didUpdateWidget(BtmNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasActive = oldWidget.selectedNav == oldWidget.navBar;
    if (isActive && !wasActive) {
      _animController.forward(from: 0.0);
    } else if (!isActive && wasActive) {
      _animController.reverse();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.press,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        height: Get.height * 0.055,
        width: isActive ? (Get.width / 3.2) : 50,
        decoration: isActive
            ? BoxDecoration(
                // Vibrant teal gradient for active state
                gradient: const LinearGradient(
                  colors: [gradientSecondaryStart, gradientSecondaryEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(50)),
                boxShadow: [
                  BoxShadow(
                    color: gradientSecondaryStart.withValues(alpha: 0.5),
                    offset: const Offset(0, 4),
                    blurRadius: 16,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: gradientSecondaryEnd.withValues(alpha: 0.3),
                    offset: const Offset(0, 0),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              )
            : null,
        child: isActive
            ? ScaleTransition(
                scale: _scaleAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 22,
                      width: 22,
                      child: AppShaderWidget(
                        color: white,
                        child: Image.asset(
                          widget.navBar.activeIcon,
                        ),
                      ),
                    ),
                    4.width,
                    Flexible(
                      child: Text(
                        widget.navBar.title.value,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: primaryTextStyle(
                          color: white,
                          size: 11,
                          weight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ).paddingSymmetric(horizontal: 8),
              )
            : AppShaderWidget(
                color: isDarkMode.value
                    ? white.withValues(alpha: 0.5)
                    : appColorPrimary.withValues(alpha: 0.45),
                child: Image.asset(
                  widget.navBar.icon,
                  height: 24,
                  width: 24,
                  fit: BoxFit.cover,
                ),
              ).paddingOnly(left: widget.isFirst ? 10 : 0, right: widget.isLast ? 10 : 0),
      ),
    );
  }
}
