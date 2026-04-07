class TimeSlot {
  String value;
  String label;

  TimeSlot({
    this.value = "",
    this.label = "",
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      value: json["value"] is String ? json["value"] : "",
      label: json["label"] is String ? json["label"] : "",
    );
  }

  Map<String, dynamic> toJson() => {
    "value": value,
    "label": label,
  };
}
