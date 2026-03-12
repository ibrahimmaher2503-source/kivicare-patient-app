import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../utils/app_common.dart';
import '../utils/colors.dart';
import '../utils/common_base.dart';

/// A shimmer placeholder widget that uses an animated gradient
/// to indicate loading state. Uses the design system shimmer color tokens.
class _ShimmerPlaceholder extends StatefulWidget {
  final double? height;
  final double? width;
  final double borderRadius;
  final bool circle;

  const _ShimmerPlaceholder({
    this.height,
    this.width,
    this.borderRadius = 0,
    this.circle = false,
  });

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = isDarkMode.value;
    final Color base = dark ? shimmerBaseDark : shimmerBase;
    final Color highlight = dark ? shimmerHighlightDark : shimmerHighlight;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.circle ? null : BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, highlight, base],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CachedImageWidget extends StatelessWidget {
  final String url;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String firstName;
  final String lastName;
  final Color? color;
  final String? placeHolderImage;
  final AlignmentGeometry? alignment;
  final bool usePlaceholderIfUrlEmpty;
  final bool circle;
  final double? radius;
  final int bottomLeftRadius;
  final int bottomRightRadius;
  final int topLeftRadius;
  final int topRightRadius;

  const CachedImageWidget({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.fit,
    this.firstName = "",
    this.lastName = "",
    this.color,
    this.placeHolderImage,
    this.alignment,
    this.radius,
    this.usePlaceholderIfUrlEmpty = true,
    this.circle = false,
    this.bottomLeftRadius = 0,
    this.bottomRightRadius = 0,
    this.topLeftRadius = 0,
    this.topRightRadius = 0,
  });

  Widget _buildInitialsPlaceholder() {
    return PlaceHolderWidget(
      height: height,
      width: width,
      alignment: alignment ?? Alignment.center,
      child: circle
          ? Text(
              "${firstName.firstLetter.toUpperCase()}${lastName.firstLetter.toUpperCase()}",
              style: primaryTextStyle(size: (height.validate() * 0.3).toInt(), decoration: TextDecoration.none),
            )
          : null,
    );
  }

  Widget _buildShimmerPlaceholder() {
    final double effectiveRadius = radius ?? (circle ? (height.validate() / 2) : 0);
    return _ShimmerPlaceholder(
      height: height,
      width: width,
      borderRadius: effectiveRadius,
      circle: circle,
    );
  }

  Widget _applyClipping(Widget child) {
    return child
        .cornerRadiusWithClipRRectOnly(
          topLeft: topLeftRadius,
          topRight: topRightRadius,
          bottomLeft: bottomLeftRadius,
          bottomRight: bottomRightRadius,
        )
        .cornerRadiusWithClipRRect(radius ?? (circle ? (height.validate() / 2) : 0));
  }

  @override
  Widget build(BuildContext context) {
    if (url.validate().isEmpty) {
      return _applyClipping(
        Container(
          height: height,
          width: width,
          color: color ?? grey.withValues(alpha: 0.1),
          alignment: alignment,
          child: _applyClipping(_buildInitialsPlaceholder()),
        ),
      );
    } else if (url.validate().startsWith('http')) {
      return _applyClipping(
        CachedNetworkImage(
          placeholder: (_, __) {
            return _applyClipping(_buildShimmerPlaceholder()).visible(usePlaceholderIfUrlEmpty);
          },
          imageUrl: url,
          height: height,
          width: width,
          fit: fit,
          color: color,
          alignment: alignment as Alignment? ?? Alignment.center,
          errorWidget: (_, s, d) {
            return _applyClipping(_buildInitialsPlaceholder());
          },
        ),
      );
    } else {
      if (url.startsWith(r"assets/")) {
        return _applyClipping(
          Image.asset(
            url,
            height: height,
            width: width,
            fit: fit,
            color: color,
            alignment: alignment ?? Alignment.center,
            errorBuilder: (_, s, d) {
              return _applyClipping(_buildInitialsPlaceholder());
            },
          ),
        );
      } else {
        return Image.file(
          File(url),
          height: height,
          width: width,
          fit: fit,
          color: color,
          alignment: alignment ?? Alignment.center,
          errorBuilder: (_, s, d) {
            return _applyClipping(_buildInitialsPlaceholder());
          },
        ).cornerRadiusWithClipRRect(radius ?? (circle ? (height.validate() / 2) : 0));
      }
    }
  }
}
