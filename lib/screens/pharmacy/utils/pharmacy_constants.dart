import 'package:flutter/material.dart';
import '../../../utils/colors.dart';

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

  static Color getStatusColor(String status) {
    switch (status) {
      case statusPending:
        return Colors.orange;
      case statusConfirmed:
        return Colors.blue;
      case statusPreparing:
        return Colors.purple;
      case statusOutForDelivery:
        return Colors.indigo;
      case statusDelivered:
        return Colors.green;
      case statusCancelled:
        return Colors.red;
      case statusRefunded:
        return Colors.grey;
      default:
        return appColorPrimary;
    }
  }

  static Color getPrescriptionStatusColor(String status) {
    switch (status) {
      case prescriptionPending:
        return Colors.orange;
      case prescriptionReviewed:
        return Colors.blue;
      case prescriptionApproved:
        return Colors.green;
      case prescriptionRejected:
        return Colors.red;
      default:
        return appColorPrimary;
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
        return Colors.green;
      case refundRejected:
        return Colors.red;
      case refundPending:
      default:
        return Colors.orange;
    }
  }
}
