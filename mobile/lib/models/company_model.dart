class Company {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? logoUrl;
  final String? primaryColor;
  final String? secondaryColor;
  final String? phone;
  final String? whatsapp;
  final String? facebookUrl;
  final String? headquartersAddress;
  final double ratingAverage;
  final int totalRatings;
  final bool isActive;

  Company({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.logoUrl,
    this.primaryColor,
    this.secondaryColor,
    this.phone,
    this.whatsapp,
    this.facebookUrl,
    this.headquartersAddress,
    required this.ratingAverage,
    required this.totalRatings,
    required this.isActive,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      primaryColor: json['primary_color'] as String?,
      secondaryColor: json['secondary_color'] as String?,
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      facebookUrl: json['facebook_url'] as String?,
      headquartersAddress: json['headquarters_address'] as String?,
      ratingAverage: (json['rating_average'] as num?)?.toDouble() ?? 0.0,
      totalRatings: json['total_ratings'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'logo_url': logoUrl,
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      'phone': phone,
      'whatsapp': whatsapp,
      'facebook_url': facebookUrl,
      'headquarters_address': headquartersAddress,
      'rating_average': ratingAverage,
      'total_ratings': totalRatings,
      'is_active': isActive,
    };
  }
}
