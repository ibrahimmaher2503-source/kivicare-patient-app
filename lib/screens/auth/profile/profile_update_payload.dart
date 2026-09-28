String profileDateOfBirthForUpdate({
  required bool photoOnly,
  required DateTime? selectedDate,
}) {
  if (photoOnly || selectedDate == null) return '';

  final year = selectedDate.year.toString().padLeft(4, '0');
  final month = selectedDate.month.toString().padLeft(2, '0');
  final day = selectedDate.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
