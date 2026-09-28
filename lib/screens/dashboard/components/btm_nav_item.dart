import 'package:flutter/material.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'menu.dart';

class BtmNavItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isSelected = selectedNav == navBar;

    return Expanded(
      child: Semantics(
        container: true,
        button: true,
        selected: isSelected,
        label: navBar.title.value,
        child: ExcludeSemantics(
          child: Tooltip(
            message: navBar.title.value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: press,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        height: 3,
                        width: isSelected ? 28 : 0,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [
                                    gradientSecondaryStart,
                                    gradientSecondaryEnd
                                  ],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      AnimatedScale(
                        scale: isSelected ? 1.08 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: isSelected
                              ? ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [
                                      gradientSecondaryStart,
                                      gradientSecondaryEnd
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  blendMode: BlendMode.srcIn,
                                  child: Image.asset(navBar.activeIcon),
                                )
                              : Image.asset(
                                  navBar.icon,
                                  color: isDarkMode.value
                                      ? textTertiaryDark
                                      : gray500,
                                  colorBlendMode: BlendMode.srcIn,
                                ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: isSelected
                            ? const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: gradientSecondaryStart,
                                height: 1.15,
                              )
                            : TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode.value
                                    ? textTertiaryDark
                                    : gray500,
                                height: 1.15,
                              ),
                        child: Text(
                          navBar.title.value,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
