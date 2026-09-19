import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../locale/languages.dart';

class PharmacyConstants {
  static const int defaultMaxQuantity = 10;
  static const int maxPrescriptionImages = 5;

  // Order Statuses
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusPreparing = 'preparing';
  static const String statusOutForDelivery = 'out_for_delivery';
  static const String statusDelivered = 'delivered';
  static const String statusCancelled = 'cancelled';
  static const String statusRefunded = 'refunded';

  // Prescription Statuses
  static const String prescriptionPending = 'pending';
  static const String prescriptionReviewed = 'reviewed';
  static const String prescriptionApproved = 'approved';
  static const String prescriptionRejected = 'rejected';

  static const Color _statusAmber = Color(0xFFF59E0B);
  static const Color _statusGreen = Color(0xFF16A34A);
  static const Color _statusRed = Color(0xFFDC2626);
  static const Color _statusBlue = Color(0xFF2563EB);
  static const Color _statusPurple = Color(0xFF7C3AED);
  static const Color _statusIndigo = Color(0xFF4338CA);
  static const Color _statusGray = Color(0xFF6B7280);

  static Color getStatusColor(String status) {
    switch (status) {
      case statusPending:
        return _statusAmber;
      case statusConfirmed:
        return _statusBlue;
      case statusPreparing:
        return _statusPurple;
      case statusOutForDelivery:
        return _statusIndigo;
      case statusDelivered:
        return _statusGreen;
      case statusCancelled:
        return _statusRed;
      case statusRefunded:
        return _statusGray;
      default:
        return appColorPrimary;
    }
  }

  static String orderStatusLabel(BaseLanguage language, String status) {
    switch (status) {
      case statusPending:
        return language.pending;
      case statusConfirmed:
        return language.confirmed;
      case statusPreparing:
        return language.preparing;
      case statusOutForDelivery:
        return language.outForDelivery;
      case statusDelivered:
        return language.delivered;
      case statusCancelled:
        return language.cancelled;
      case statusRefunded:
        return language.refunded;
      default:
        return status.replaceAll('_', ' ');
    }
  }

  static Color getPrescriptionStatusColor(String status) {
    switch (status) {
      case prescriptionPending:
        return _statusAmber;
      case prescriptionReviewed:
        return _statusBlue;
      case prescriptionApproved:
        return _statusGreen;
      case prescriptionRejected:
        return _statusRed;
      default:
        return appColorPrimary;
    }
  }

  static String prescriptionStatusLabel(BaseLanguage language, String status) {
    switch (status) {
      case prescriptionPending:
        return language.pending;
      case prescriptionReviewed:
        return language.reviewed;
      case prescriptionApproved:
        return language.approved;
      case prescriptionRejected:
        return language.rejected;
      default:
        return status.replaceAll('_', ' ');
    }
  }

  // Refund Statuses
  static const String refundPending = 'pending';
  static const String refundApproved = 'approved';
  static const String refundProcessed = 'processed';
  static const String refundRejected = 'rejected';

  static Color getRefundStatusColor(String status) {
    switch (status) {
      case refundApproved:
      case refundProcessed:
        return _statusGreen;
      case refundRejected:
        return _statusRed;
      case refundPending:
      default:
        return _statusAmber;
    }
  }

  static String refundStatusLabel(BaseLanguage language, String status) {
    switch (status) {
      case refundPending:
        return language.pending;
      case refundApproved:
        return language.approved;
      case refundProcessed:
        return language.processed;
      case refundRejected:
        return language.rejected;
      default:
        return status.replaceAll('_', ' ');
    }
  }

  static String paymentMethodLabel(BaseLanguage language, String method) {
    switch (method) {
      case 'cash':
      case 'cash_on_delivery':
        return language.pharmacyCashOnDelivery;
      case 'wallet':
        return language.pharmacyWallet;
      default:
        return method.replaceAll('_', ' ');
    }
  }
}
