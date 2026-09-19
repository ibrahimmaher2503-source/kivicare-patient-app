import 'package:flutter/material.dart';

// Primary Brand Colors
const appColorPrimary = Color(0xFF08234F); // Dark Navy Blue
const appColorSecondary = Color(0xFF037F7C); // Teal
const appColorAccent = Color(0xFF13BAAA); // Light Teal

// Light Variants
const lightPrimaryColor = Color(0xFFE3E6EB); // Very light blue-grey
const extraLightPrimaryColor = Color(0xFFF5F6F8);
const lightSecondaryColor = Color(0xFFE0F5F4); // Light teal tint
const lightAccentColor = Color(0xFFD4F4F0); // Very light teal

const appBodyColor = Color(0xFF5E6872);
const canvasColor = Color(0xFF1E1E24);
const canvasColorDark = Color(0xFF171B23);
const fullDarkCanvasColor = Color(0xFF272B35);
const fullDarkCanvasColorDark = Color(0xFF12161E);
const lightCanvasColor = Color(0xFF384052);
const mediumCanvasColor = Color(0XFF303030);

//Section BG / page BG
const appLayoutBackground = Color(0xFFF8FAFB);
const appSectionBackground = Color(0xFFFFFFFF);
const appScreenBackground = Color(0xFFF5F6FA);
const appScreenGreyBackground = Color(0xFFF7F7F7);
const lightGreenColor = Color(0xFFE0F5F4); // Changed to light teal

// Tertiary
const bodyWhite = Color(0xFFA6A6A6);
const bodyWhiteType = Color(0xFFFAFAFA);
const appColorlightGray = Color(0xFFF5F5F5);
const dividerColor = Color(0xFF828A90);
const whiteBorderColor = Color(0xFFEBF0F3); // Light blue-grey
const borderColor = Color(0xFFD8D9D9);
const borderColorDark = Color(0xFF23272F);

// Dark Theme Colors
const appScreenBackgroundDark = Color(0xFF0A1628); // Dark blue-grey
const appBackgroundColorDark = Color(0xFF041020); // Very dark blue
const appBackgroundSecondaryColorDark = Color(0xFF0D1829);
const colorPrimaryBlack = Color(0xFF121212);
const darkHeadingColor = Color(0xFF999999);
const appDarkBodyColor = Color(0xFF666666);
const iconColorPrimaryDark = Color(0xFF5F6060);
const appShadowColorDark = Color(0xFF333333);
const cardBackgroundBlackDark = Color(0xFF1F1F1F);

// Dark Mode Text Colors — layered opacity for visual hierarchy
const textPrimaryDark = Color(0xFFF0F2F5); // Soft white, easy on eyes
const textSecondaryDark = Color(0xFFB0B8C4); // Muted blue-grey
const textTertiaryDark = Color(0xFF9AA7B9); // WCAG AA on dark surfaces
const textHintDark = Color(0xFFA7B0BE); // Accessible placeholder / hint text

// Text Colors
const appTransparentColor = Colors.transparent;
const whiteTextColor = Color(0xFFFFFFFF);
const blackTextColor = Color(0xFF000000);
const resetTextColor = Color(0xFF13BAAA); // Light teal
const deleteTextColor = Color(0xFFD76161);
const redTextColor = Color(0xFFFF3E3E);
const darkGrayGeneral = Color(0xff6C757D);
const darkGrayTextColor = Color(0xff3F414D);

//Text Colors
const primaryTextColor = Color(0xFF08234F); // Dark navy
const secondaryTextColor = Color(0xFF5E6872);

// Grayscale Colors
const gray50 = Color(0xFFF9FAFB); // Very light
const gray100 = Color(0xFFF3F4F6); // Light
const gray200 = Color(0xFFE5E7EB); // Lighter
const gray300 = Color(0xFFD1D5DB); // Light-medium
const gray400 = Color(0xFF9CA3AF); // Medium
const gray500 = Color(0xFF6B7280); // Medium-dark
const gray600 = Color(0xFF4B5563); // Dark
const gray700 = Color(0xFF374151); // Darker
const gray800 = Color(0xFF1F2937); // Very dark

//Status Colors - Coordinated with brand
const pendingStatusColor = Color(0xFFFF9F66); // Warm orange
const checkoutStatusColor = Color(0xFFFFB84D); // Amber
const confirmedStatusColor = Color(0xFF037F7C); // Brand teal
const completedStatusColor = Color(0xFF13BAAA); // Brand light teal
const cancelStatusColor = Color(0xFFE74C3C); // Red
const defaultStatusColor = Color(0xFF08234F); // Brand navy
const checkInStatusColor = Color(0xFF3498DB); // Blue

//Review Selection Colors
const ratingColor = checkoutStatusColor;
const ratingFirstColor = Color(0xFF13BAAA); // Excellent - light teal
const ratingSecondColor = Color(0xFF52C9BC); // Good - mid teal
const ratingThirdColor = checkoutStatusColor; // Average - amber
const ratingFourthColor = pendingStatusColor; // Below average - orange
const ratingFifthColor = cancelStatusColor; // Poor - red

const switchActiveTrackColor = appColorSecondary; // Teal
const switchActiveColor = Colors.white;
const switchColor = Color(0xFF808080);
const iconColor = Color(0xFF037F7C); // Teal icons
const browseColor = Color(0xFFE0F5F4); // Light teal

// Clinical Luxury - Gradient Colors
const gradientStart = Color(0xFF08234F); // Navy primary
const gradientEnd = Color(0xFF0D3B7A); // Lighter navy for gradient transition
const gradientSecondaryStart = Color(0xFF037F7C); // Teal gradient start
const gradientSecondaryEnd =
    Color(0xFF08736F); // Accessible teal for white CTAs

// Clinical Luxury - Glassmorphism
const glassTintLight = Color(0x33FFFFFF); // White 20% for glass overlay
const glassTintDark = Color(0x1A08234F); // Navy 10% for glass overlay
const glassStrokeLight = Color(0x33FFFFFF); // Subtle glass border light
const glassStrokeDark = Color(0x1AFFFFFF); // Subtle glass border dark

// Clinical Luxury - Soft Shadows (navy-tinted instead of grey)
const softShadowColor = Color(0x1408234F); // Navy shadow at 8% opacity
const softShadowColorMedium = Color(0x1F08234F); // Navy shadow at 12% opacity
const softShadowColorDark = Color(0x0A0D1829); // Dark mode shadow

// Clinical Luxury - Elevated Surfaces
const surfaceElevated = Color(0xFFFFFFFF); // Elevated card surface light
const surfaceElevatedDark = Color(0xFF1A2436); // Elevated card surface dark
const surfaceSubtle = Color(0xFFF8FAFB); // Subtle background variation

// Clinical Luxury - Shimmer Loading
const shimmerBase = Color(0xFFE8ECF1); // Shimmer base color
const shimmerHighlight = Color(0xFFF5F7FA); // Shimmer highlight
const shimmerBaseDark = Color(0xFF1A2436); // Shimmer base dark mode
const shimmerHighlightDark = Color(0xFF243046); // Shimmer highlight dark mode

// Clinical Luxury - Input Field Colors
const inputFillColor = Color(0xFFF5F6FA); // Subtle fill for inputs
const inputFillColorDark = Color(0xFF0F1D32); // Dark mode input fill
const inputFocusGlow = Color(0x1A08234F); // Focus ring glow

// Nurse Request Status Colors
const nurseStatusPendingColor = Color(0xFFFF9800);
const nurseStatusConfirmedColor = Color(0xFF037F7C);
const nurseStatusInProgressColor = Color(0xFF2196F3);
const nurseStatusCompletedColor = Color(0xFF13BAAA);
const nurseStatusCancelledColor = Color(0xFFE53935);

// Lab Test Order Status Colors
const labStatusPendingColor = Color(0xFFFF9800);
const labStatusConfirmedColor = Color(0xFF037F7C);
const labStatusSampleCollectedColor = Color(0xFF7C4DFF);
const labStatusProcessingColor = Color(0xFF2196F3);
const labStatusCompletedColor = Color(0xFF13BAAA);
const labStatusDeliveredColor = Color(0xFF4CAF50);
const labStatusCancelledColor = Color(0xFFE53935);

// Test Result Status Colors
const resultNormalColor = Color(0xFF4CAF50);
const resultAbnormalColor = Color(0xFFFF9800);
const resultCriticalColor = Color(0xFFE53935);

// Nurse Availability Colors
const nurseAvailableColor = Color(0xFF4CAF50);
const nurseBusyColor = Color(0xFFFF9800);
const nurseOffDutyColor = Color(0xFF9E9E9E);

// Service Request Status Colors
const serviceStatusPendingColor = Color(0xFFFF9800);
const serviceStatusAcceptColor = Color(0xFF4CAF50);
const serviceStatusRejectColor = Color(0xFFE53935);

// ICU Admission Status Colors
const icuStatusPendingColor = Color(0xFFFF9800); // Amber
const icuStatusAcceptedColor = Color(0xFF4CAF50); // Green
const icuStatusRejectedColor = Color(0xFFE53935); // Red
const icuStatusInfoRequestedColor = Color(0xFF2196F3); // Blue
const icuStatusCancelledColor = Color(0xFF9E9E9E); // Grey

// ICU Urgency Colors
const urgencyCriticalColor = Color(0xFFE53935); // Red
const urgencyUrgentColor = Color(0xFFFF9800); // Orange
const urgencyStandardColor = Color(0xFF2196F3); // Blue

// Call Booking Colors
const callTypeVideoColor = Color(0xFF5C6BC0); // Indigo
const callTypePhoneColor = Color(0xFF4CAF50); // Green
const callBookingConfirmedColor = Color(0xFF4CAF50); // Green
const callBookingCompletedColor = Color(0xFF13BAAA); // Teal
const callBookingCancelledColor = Color(0xFFE53935); // Red

// Specialty Tile Accent Colors (Home V2 grid)
const specialtyAccentTeal = Color(0xFF037F7C);
const specialtyAccentIndigo = Color(0xFF5C6BC0);
const specialtyAccentOrange = Color(0xFFE67E22);
const specialtyAccentPlum = Color(0xFF8E44AD);
const specialtyAccentOcean = Color(0xFF2980B9);
const specialtyAccentBrick = Color(0xFFC0392B);
const specialtyAccentEmerald = Color(0xFF27AE60);
const specialtyAccentPersian = Color(0xFF16A085);

// Doctor Card Semantic Tokens
const colorStatusOnline = Color(0xFF2D9B6F);
const ratingColorFilled = Color(0xFFFFA827);
const ratingColorEmpty = Color(0xFFD1D5DB);
const colorPatientMetric = Color(0xFF037F7C);
