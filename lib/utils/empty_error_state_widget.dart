import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../generated/assets.dart';
import 'app_common.dart';
import 'colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final String? title;
  final String? subtitle;

  const EmptyStateWidget({super.key, this.height, this.width, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final bool dark = isDarkMode.value;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(Assets.lottieEmptyLottie, height: 150, repeat: true),
        if (title != null) ...[
          const SizedBox(height: 16),
          Text(
            title!,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: dark ? Colors.white : primaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.1,
                color: secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final String? title;
  final String? subtitle;
  final String? retryText;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    this.height,
    this.width,
    this.title,
    this.subtitle,
    this.retryText,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = isDarkMode.value;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(Assets.lottieErrorLottie, height: 110, repeat: true),
        if (title != null) ...[
          const SizedBox(height: 16),
          Text(
            title!,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: dark ? Colors.white : primaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.1,
                color: secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        if (onRetry != null) ...[
          const SizedBox(height: 24),
          _RetryButton(
            text: retryText ?? 'Retry',
            onTap: onRetry!,
          ),
        ],
      ],
    );
  }
}

class _RetryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _RetryButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [gradientSecondaryStart, gradientSecondaryEnd],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: appColorSecondary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}
