import 'admission_request_model.dart';

class AdmissionRequestFormPayload {
  final int hospitalId;
  final int? icuDepartmentId;
  final String patientName;
  final int patientAge;
  final String patientGender;
  final String? nationalId;
  final String diagnosis;
  final String languageCode;
  final String? currentCondition;
  final String? attendingDoctor;
  final String? medicalHistory;
  final String? currentMedications;
  final String? allergies;
  final UrgencyLevel urgency;
  // Backend required: in:stroke,cardiac,post_operative,ventilator,neonatal,pediatric,burns,general
  final String caseType;
  // Backend required: in:insurance,cash
  final String paymentMethod;
  final String? insuranceNumber;
  final String? insuranceProvider;
  final DateTime? preferredAdmissionAt;
  final String? additionalNotes;
  final String accompanyingName;
  final String? accompanyingRelation;
  final String accompanyingPhone;

  AdmissionRequestFormPayload({
    required this.hospitalId,
    this.icuDepartmentId,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    this.nationalId,
    required this.diagnosis,
    required this.languageCode,
    this.currentCondition,
    this.attendingDoctor,
    this.medicalHistory,
    this.currentMedications,
    this.allergies,
    required this.urgency,
    this.caseType = 'general',
    this.paymentMethod = 'cash',
    this.insuranceNumber,
    this.insuranceProvider,
    this.preferredAdmissionAt,
    this.additionalNotes,
    required this.accompanyingName,
    this.accompanyingRelation,
    required this.accompanyingPhone,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'hospital_id': hospitalId,
      'patient_name': patientName,
      'patient_age': patientAge,
      'patient_gender': patientGender,
      'urgency': urgency
          .toWire, // maps routine→standard, urgent→urgent, critical→critical
      'case_type': caseType,
      'payment_method': paymentMethod,
      'contact_name': accompanyingName,
      'contact_phone': accompanyingPhone,
    };

    if (icuDepartmentId != null) {
      data['icu_department_id'] = icuDepartmentId;
    }
    if (nationalId != null && nationalId!.isNotEmpty) {
      data['national_id'] = nationalId;
    }

    final localizedSuffix = languageCode.toLowerCase() == 'ar' ? 'ar' : 'en';

    // Preserve the language actually entered instead of claiming one value is
    // a valid translation in both languages.
    if (diagnosis.isNotEmpty) {
      data['diagnosis_$localizedSuffix'] = diagnosis;
    }

    if (currentCondition != null && currentCondition!.isNotEmpty) {
      data['medical_condition_$localizedSuffix'] = currentCondition;
    }

    void addIfPresent(String key, String? value) {
      final normalized = value?.trim() ?? '';
      if (normalized.isNotEmpty) {
        data[key] = normalized;
      }
    }

    addIfPresent('attending_doctor', attendingDoctor);
    addIfPresent('medical_history', medicalHistory);
    addIfPresent('current_medications', currentMedications);
    addIfPresent('allergies', allergies);
    addIfPresent('additional_notes', additionalNotes);

    if (accompanyingRelation != null && accompanyingRelation!.isNotEmpty) {
      data['relationship_to_patient'] = accompanyingRelation;
    }
    if (preferredAdmissionAt != null) {
      data['preferred_admission_at'] = preferredAdmissionAt!.toIso8601String();
    }
    if (insuranceNumber != null && insuranceNumber!.isNotEmpty) {
      data['insurance_number'] = insuranceNumber;
    }
    if (insuranceProvider != null && insuranceProvider!.isNotEmpty) {
      data['insurance_provider'] = insuranceProvider;
    }

    return data;
  }
}
