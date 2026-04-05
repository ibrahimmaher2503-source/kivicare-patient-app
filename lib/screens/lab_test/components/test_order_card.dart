import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/price_widget.dart';
import '../model/test_order_model.dart';
import '../test_order_detail_screen.dart';

class TestOrderCard extends StatelessWidget {
  final TestOrder orderData;
  final VoidCallback? onTap;

  const TestOrderCard({
    super.key,
    required this.orderData,
    this.onTap,
  });

  Color get _statusColor {
    switch (orderData.status.toLowerCase()) {
      case 'pending':
        return labStatusPendingColor;
      case 'confirmed':
        return labStatusConfirmedColor;
      case 'sample_collected':
        return labStatusSampleCollectedColor;
      case 'processing':
        return labStatusProcessingColor;
      case 'completed':
        return labStatusCompletedColor;
      case 'delivered':
        return labStatusDeliveredColor;
      case 'cancelled':
        return labStatusCancelledColor;
      default:
        return labStatusPendingColor;
    }
  }

  String get _statusLabel {
    switch (orderData.status.toLowerCase()) {
      case 'pending':
        return locale.value.pending;
      case 'confirmed':
        return locale.value.confirmed;
      case 'sample_collected':
        return locale.value.sampleCollected;
      case 'processing':
        return locale.value.processing;
      case 'completed':
        return locale.value.completed;
      case 'delivered':
        return locale.value.delivered;
      case 'cancelled':
        return locale.value.cancelled;
      default:
        return orderData.status;
    }
  }

  Color get _priorityColor {
    switch (orderData.priority.toLowerCase()) {
      case 'urgent':
        return resultAbnormalColor;
      case 'stat':
        return resultCriticalColor;
      default:
        return appColorSecondary;
    }
  }

  String get _priorityLabel {
    switch (orderData.priority.toLowerCase()) {
      case 'routine':
        return locale.value.priorityRoutine;
      case 'urgent':
        return locale.value.priorityUrgent;
      case 'stat':
        return locale.value.priorityStat;
      default:
        return orderData.priority;
    }
  }

  int get _statusStep {
    switch (orderData.status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'confirmed':
        return 1;
      case 'sample_collected':
        return 2;
      case 'processing':
        return 3;
      case 'completed':
        return 4;
      case 'delivered':
        return 5;
      case 'cancelled':
        return -1;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStat = orderData.priority.toLowerCase() == 'stat';

    return GestureDetector(
      onTap: onTap ?? () {
        hideKeyboard(context);
        Get.to(() => TestOrderDetailScreen(orderData: orderData));
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode.value ? softShadowColorDark : softShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Colored left border strip (4px) based on status
              Container(
                width: 4,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _statusColor,
                      _statusColor.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),

              // Card content
              Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Number & Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Order number - monospace style with background
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: isDarkMode.value
                                  ? appColorPrimary.withValues(alpha: 0.3)
                                  : appColorPrimary.withValues(alpha: 0.06),
                            ),
                            child: Text(
                              '#${orderData.orderNumber}',
                              style: GoogleFonts.sourceCodePro(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: isDarkMode.value ? Colors.white : primaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        8.width,
                        _buildStatusBadge(),
                      ],
                    ),
                    14.height,

                    // Mini timeline/stepper for order progress
                    if (_statusStep >= 0) _buildProgressStepper(),
                    if (_statusStep >= 0) 14.height,

                    // Order Date & Items count badge
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14, color: secondaryTextColor),
                        4.width,
                        Text(
                          orderData.orderDate,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            letterSpacing: 0.1,
                            color: secondaryTextColor,
                          ),
                        ),
                        16.width,
                        // Items count as circular badge
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                appColorSecondary.withValues(alpha: 0.2),
                                appColorAccent.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${orderData.items.length}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: appColorSecondary,
                              ),
                            ),
                          ),
                        ),
                        4.width,
                        Text(
                          locale.value.testCount,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            letterSpacing: 0.1,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    12.height,

                    // Separator line
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            isDarkMode.value
                                ? Colors.white.withValues(alpha: 0.06)
                                : appColorPrimary.withValues(alpha: 0.06),
                            isDarkMode.value
                                ? Colors.white.withValues(alpha: 0.02)
                                : appColorPrimary.withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                    ),
                    12.height,

                    // Priority Badge & Final Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (orderData.priority.isNotEmpty)
                          isStat
                              ? _PulsingBadge(
                                  color: _priorityColor,
                                  label: _priorityLabel,
                                )
                              : _buildPriorityBadge(),
                        if (orderData.priority.isEmpty) const Spacer(),
                        // Right-aligned amount with currency formatting
                        PriceWidget(
                          price: orderData.finalAmount,
                          size: 20,
                          color: isDarkMode.value ? Colors.white : primaryTextColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStepper() {
    const totalSteps = 5; // pending, confirmed, sample_collected, processing, completed/delivered
    final currentStep = _statusStep.clamp(0, totalSteps);

    return Row(
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isEven) {
          // Dot
          final stepIndex = index ~/ 2;
          final isActive = stepIndex <= currentStep;
          final isCurrent = stepIndex == currentStep;
          return Container(
            width: isCurrent ? 10 : 8,
            height: isCurrent ? 10 : 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? _statusColor : (isDarkMode.value ? Colors.white.withValues(alpha: 0.15) : appColorPrimary.withValues(alpha: 0.12)),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: _statusColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
          );
        } else {
          // Line
          final stepIndex = index ~/ 2;
          final isActive = stepIndex < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                color: isActive ? _statusColor.withValues(alpha: 0.6) : (isDarkMode.value ? Colors.white.withValues(alpha: 0.08) : appColorPrimary.withValues(alpha: 0.08)),
              ),
            ),
          );
        }
      }),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            _statusColor.withValues(alpha: 0.15),
            _statusColor.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _statusColor,
            ),
          ),
          4.width,
          Text(
            _statusLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              color: _statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge() {
    final isUrgent = orderData.priority.toLowerCase() == 'urgent';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            _priorityColor.withValues(alpha: isUrgent ? 0.2 : 0.15),
            _priorityColor.withValues(alpha: isUrgent ? 0.12 : 0.08),
          ],
        ),
        border: isUrgent
            ? Border.all(color: _priorityColor.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isUrgent) ...[
            Icon(Icons.warning_amber_rounded, size: 13, color: _priorityColor),
            4.width,
          ],
          Text(
            _priorityLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              color: _priorityColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated pulsing badge for STAT priority
class _PulsingBadge extends StatefulWidget {
  final Color color;
  final String label;

  const _PulsingBadge({required this.color, required this.label});

  @override
  State<_PulsingBadge> createState() => _PulsingBadgeState();
}

class _PulsingBadgeState extends State<_PulsingBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  widget.color.withValues(alpha: 0.25),
                  widget.color.withValues(alpha: 0.15),
                ],
              ),
              border: Border.all(
                color: widget.color.withValues(alpha: 0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.2 * _animation.value),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 13, color: widget.color),
                4.width,
                Text(
                  widget.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: widget.color,
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
