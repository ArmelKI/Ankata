
class Line {
  final String id;
  final String lineCode;
  final String companyId;
  final String originCity;
  final String destinationCity;
  final String? originName;
  final String? destinationName;
  final double? originLatitude;
  final double? originLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final double basePrice;
  final String currency;
  final double luggagePricePerKg;
  final double? distanceKm;
  final int? estimatedDurationMinutes;
  final String companyName;
  final String? logoUrl;
  final double ratingAverage;
  final bool isActive;

  Line({
    required this.id,
    required this.lineCode,
    required this.companyId,
    required this.originCity,
    required this.destinationCity,
    this.originName,
    this.destinationName,
    this.originLatitude,
    this.originLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
    required this.basePrice,
    this.currency = 'XOF',
    this.luggagePricePerKg = 100.0,
    this.distanceKm,
    this.estimatedDurationMinutes,
    required this.companyName,
    this.logoUrl,
    required this.ratingAverage,
    this.isActive = true,
  });

  factory Line.fromJson(Map<String, dynamic> json) {
    return Line(
      id: json['id'] as String,
      lineCode: json['line_code'] as String,
      companyId: json['company_id'] as String,
      originCity: json['origin_city'] as String,
      destinationCity: json['destination_city'] as String,
      originName: json['origin_name'] as String?,
      destinationName: json['destination_name'] as String?,
      originLatitude: (json['origin_latitude'] as num?)?.toDouble(),
      originLongitude: (json['origin_longitude'] as num?)?.toDouble(),
      destinationLatitude: (json['destination_latitude'] as num?)?.toDouble(),
      destinationLongitude: (json['destination_longitude'] as num?)?.toDouble(),
      basePrice: (json['base_price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'XOF',
      luggagePricePerKg: (json['luggage_price_per_kg'] as num?)?.toDouble() ?? 100.0,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int?,
      companyName: json['company_name'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
      ratingAverage: (json['rating_average'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'line_code': lineCode,
      'company_id': companyId,
      'origin_city': originCity,
      'destination_city': destinationCity,
      'origin_name': originName,
      'destination_name': destinationName,
      'origin_latitude': originLatitude,
      'origin_longitude': originLongitude,
      'destination_latitude': destinationLatitude,
      'destination_longitude': destinationLongitude,
      'base_price': basePrice,
      'currency': currency,
      'luggage_price_per_kg': luggagePricePerKg,
      'distance_km': distanceKm,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'company_name': companyName,
      'logo_url': logoUrl,
      'rating_average': ratingAverage,
      'is_active': isActive,
    };
  }

  String get durationDisplay {
    if (estimatedDurationMinutes == null) return '';
    final hours = estimatedDurationMinutes! ~/ 60;
    final minutes = estimatedDurationMinutes! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
