class BookingSlot {
  final String time; // Time in H:i format (e.g., "08:00")
  final bool available; // Whether the slot is available for booking

  BookingSlot({
    required this.time,
    required this.available,
  });

  factory BookingSlot.fromJson(Map<String, dynamic> json) {
    return BookingSlot(
      time: json['time'] ?? '',
      available: json['available'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'time': time,
    'available': available,
  };
}
