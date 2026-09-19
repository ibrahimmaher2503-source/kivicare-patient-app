import 'package:nb_utils/nb_utils.dart';
import 'facility_model.dart';
import 'facility_type.dart';
import 'lab_test_model.dart';
import 'test_order_status.dart';
import 'test_order_status_history_model.dart';

class TestOrderModel {
  int id;
  String referenceNumber;
  TestOrderStatus status;
  FacilityType facilityType;
  FacilityModel facility;
  LabTestModel? labTest;
  SlotInfo slot;
  String? patientNotes;
  double? totalAmount;
  String currency;
  PaymentStatus paymentStatus;
  String? reportUrl;
  DateTime? reportUploadedAt;
  String? cancellationReason;
  List<TestOrderStatusHistoryModel> statusHistories;
  DateTime? completedAt;
  DateTime createdAt;
  DateTime updatedAt;

  TestOrderModel({
    this.id = 0,
    this.referenceNumber = '',
    this.status = TestOrderStatus.pending,
    this.facilityType = FacilityType.lab,
    required this.facility,
    this.labTest,
    required this.slot,
    this.patientNotes,
    this.totalAmount,
    this.currency = 'EGP',
    this.paymentStatus = PaymentStatus.unpaid,
    this.reportUrl,
    this.reportUploadedAt,
    this.cancellationReason,
    this.statusHistories = const [],
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TestOrderModel.fromJson(Map<String, dynamic> json) {
    return TestOrderModel(
      id: json['id'] is int ? json['id'] : json['id'].toString().toInt(),
      referenceNumber: json['reference_number'] ?? '',
      status: TestOrderStatus.fromString(json['status']),
      facilityType: FacilityType.fromString(json['facility_type']),
      facility: FacilityModel.fromJson(json['facility'] ?? {}),
      labTest: json['lab_test'] != null
          ? LabTestModel.fromJson(json['lab_test'])
          : null,
      slot: SlotInfo.fromJson(json['slot'] ?? {}),
      patientNotes: json['patient_notes'],
      totalAmount: json['total_amount']?.toDouble(),
      currency: json['currency'] ?? 'EGP',
      paymentStatus: PaymentStatus.fromString(json['payment_status']),
      reportUrl: json['report_url'],
      reportUploadedAt: json['report_uploaded_at'] != null
          ? DateTime.parse(json['report_uploaded_at'])
          : null,
      cancellationReason: json['cancellation_reason'],
      statusHistories: (json['status_histories'] as List?)
              ?.map((e) => TestOrderStatusHistoryModel.fromJson(e))
              .toList() ??
          [],
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  bool get canCancel => status.isCancellable;
  bool get hasReport => reportUrl != null && reportUrl!.isNotEmpty;
}

class SlotInfo {
  String date;
  String startTime;
  String endTime;

  SlotInfo({
    this.date = '',
    this.startTime = '',
    this.endTime = '',
  });

  factory SlotInfo.fromJson(Map<String, dynamic> json) {
    return SlotInfo(
      date: json['date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}
