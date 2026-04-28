enum VisitStatus {
  pending,
  confirmed,
  completed,
  cancelled;

  static VisitStatus fromString(String? value) {
    switch (value) {
      case 'confirmed':
        return VisitStatus.confirmed;
      case 'completed':
        return VisitStatus.completed;
      case 'cancelled':
        return VisitStatus.cancelled;
      case 'pending':
      default:
        return VisitStatus.pending;
    }
  }

  String get apiValue => name;

  bool get isTerminal => this == cancelled || this == completed;
}
