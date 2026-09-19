enum FacilityType {
  lab,
  radiology;

  factory FacilityType.fromString(String? value) {
    if (value?.toLowerCase() == 'radiology') return FacilityType.radiology;
    return FacilityType.lab;
  }

  String get apiValue => name;

  String get endpointBase {
    if (this == FacilityType.radiology) return 'radiology-centers';
    return 'labs';
  }

  String get displayLabel {
    // These will be wired to locale keys in the UI layer
    if (this == FacilityType.radiology) return 'Radiology';
    return 'Lab';
  }
}
