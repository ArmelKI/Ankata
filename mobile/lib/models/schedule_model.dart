class Schedule {
  final String id;
  final String lineId;
  final String departureTime;
  final List<int> daysOfWeek;
  final int totalSeats;
  final int availableSeats;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;

  Schedule({
    required this.id,
    required this.lineId,
    required this.departureTime,
    required this.daysOfWeek,
    required this.totalSeats,
    required this.availableSeats,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String,
      lineId: json['line_id'] as String,
      departureTime: json['departure_time'] as String,
      daysOfWeek: List<int>.from(json['days_of_week'] as List? ?? []),
      totalSeats: json['total_seats'] as int,
      availableSeats: json['available_seats'] as int,
      validFrom: DateTime.parse(json['valid_from'] as String),
      validUntil: DateTime.parse(json['valid_until'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  bool get hasAvailableSeats => availableSeats > 0;
  
  int get bookedSeats => totalSeats - availableSeats;
  
  double get occupancyPercent => (bookedSeats / totalSeats) * 100;
}
