import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class SlotModel {
  int id;
  String startTime;
  String endTime;
  bool available;

  SlotModel({
    this.id = 0,
    this.startTime = '',
    this.endTime = '',
    this.available = false,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['id'] is int ? json['id'] : json['id'].toString().toInt(),
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      available: json['available'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime,
      'end_time': endTime,
      'available': available,
    };
  }

  String formattedRange(String localeCode) {
    try {
      final start = DateFormat('HH:mm').parse(startTime);
      final end = DateFormat('HH:mm').parse(endTime);
      final displayFormat = DateFormat('h:mm a', localeCode);
      return '${displayFormat.format(start)} – ${displayFormat.format(end)}';
    } catch (e) {
      return '$startTime – $endTime';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlotModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
