class BookingModel {
  final String id;
  final String bookingCode;
  final String userId;
  final String scheduleId;
  final String lineId;
  final String companyId;
  final String passengerName;
  final String? passengerPhone;
  final DateTime departureDate;
  final String? seatNumber;
  final double luggageWeightKg;
  final double basePrice;
  final double luggageFee;
  final double totalAmount;
  final String? paymentMethod;
  final String paymentStatus;
  final String bookingStatus;
  final DateTime createdAt;
  final String? originCity;
  final String? destinationCity;
  final String? companyName;
  final String? logoUrl;

  BookingModel({
    required this.id,
    required this.bookingCode,
    required this.userId,
    required this.scheduleId,
    required this.lineId,
    required this.companyId,
    required this.passengerName,
    this.passengerPhone,
    required this.departureDate,
    this.seatNumber,
    required this.luggageWeightKg,
    required this.basePrice,
    required this.luggageFee,
    required this.totalAmount,
    this.paymentMethod,
    required this.paymentStatus,
    required this.bookingStatus,
    required this.createdAt,
    this.originCity,
    this.destinationCity,
    this.companyName,
    this.logoUrl,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      bookingCode: json['booking_code'] as String,
      userId: json['user_id'] as String,
      scheduleId: json['schedule_id'] as String,
      lineId: json['line_id'] as String,
      companyId: json['company_id'] as String,
      passengerName: json['passenger_name'] as String,
      passengerPhone: json['passenger_phone'] as String?,
      departureDate: DateTime.parse(json['departure_date'] as String),
      seatNumber: json['seat_number'] as String?,
      luggageWeightKg: (json['luggage_weight_kg'] as num?)?.toDouble() ?? 0.0,
      basePrice: (json['base_price'] as num).toDouble(),
      luggageFee: (json['luggage_fee'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String?,
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      bookingStatus: json['booking_status'] as String? ?? 'confirmed',
      createdAt: DateTime.parse(json['created_at'] as String),
      originCity: json['origin_city'] as String?,
      destinationCity: json['destination_city'] as String?,
      companyName: json['company_name'] as String?,
      logoUrl: json['logo_url'] as String?,
    );
  }

  bool get isUpcoming => departureDate.isAfter(DateTime.now());
  
  bool get isPast => departureDate.isBefore(DateTime.now());
  
  bool get isPaid => paymentStatus == 'completed';
  
  bool get isConfirmed => bookingStatus == 'confirmed';
}
