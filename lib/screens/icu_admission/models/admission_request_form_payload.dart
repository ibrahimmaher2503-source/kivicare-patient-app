import 'admission_request_model.dart';

class AdmissionRequestFormPayload {
  final int hospitalId;
  final int icuDepartmentId;
  final String patientName;
  final int patientAge;
  final String patientGender;
  final String? nationalId;
  final String diagnosis;
  final String? currentCondition;
  final String? attendingDoctor;
  final String? medicalHistory;
  final String? currentMedications;
  final String? allergies;
  final UrgencyLevel urgency;
  final DateTime? preferredAdmissionAt;
  final String? additionalNotes;
  final String accompanyingName;
  final String? accompanyingRelation;
  final String accompanyingPhone;

  AdmissionRequestFormPayload({
    required this.hospitalId,
    required this.icuDepartmentId,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    this.nationalId,
    required this.diagnosis,
    this.currentCondition,
    this.attendingDoctor,
    this.medicalHistory,
    this.currentMedications,
    this.allergies,
    required this.urgency,
    this.preferredAdmissionAt,
    this.additionalNotes,
    required this.accompanyingName,
    this.accompanyingRelation,
    required this.accompanyingPhone,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'hospital_id': hospitalId,
      'icu_department_id': icuDepartmentId,
      'patient_name': patientName,
      'patient_age': patientAge,
      'patient_gender': patientGender,
      'diagnosis': diagnosis,
      'urgency': urgency.toWire,
      'accompanying_name': accompanyingName,
      'accompanying_phone': accompanyingPhone,
    };

    if (nationalId != null && nationalId!.isNotEmpty) data['national_id'] = nationalId;
    if (currentCondition != null && currentCondition!.isNotEmpty) data['current_condition'] = currentCondition;
    if (attendingDoctor != null && attendingDoctor!.isNotEmpty) data['attending_doctor'] = attendingDoctor;
    if (medicalHistory != null && medicalHistory!.isNotEmpty) data['medical_history'] = medicalHistory;
    if (currentMedications != null && currentMedications!.isNotEmpty) data['current_medications'] = currentMedications;
    if (allergies != null && allergies!.isNotEmpty) data['allergies'] = allergies;
    if (preferredAdmissionAt != null) data['preferred_admission_at'] = preferredAdmissionAt!.toIso8601String();
    if (additionalNotes != null && additionalNotes!.isNotEmpty) data['additional_notes'] = additionalNotes;
    if (accompanyingRelation != null && accompanyingRelation!.isNotEmpty) data['accompanying_relation'] = accompanyingRelation;

    // FR-023: The system MUST NOT transmit status, reference_number, assigned_room, 
    // assigned_bed, admitted_at, discharged_at, payment_*, or commission_* fields.
    return data;
  }
}
