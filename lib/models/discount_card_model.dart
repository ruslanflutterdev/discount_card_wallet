class DiscountCardModel {
  final String id;
  final String storeName;
  final String storeLogoUrl;
  final String frontImageUrl;
  final String backImageUrl;
  final String notes;
  final DateTime createdAt;

  DiscountCardModel({
    required this.id,
    required this.storeName,
    required this.storeLogoUrl,
    required this.frontImageUrl,
    required this.backImageUrl,
    required this.notes,
    required this.createdAt,
  });

  factory DiscountCardModel.fromJson(Map<String, dynamic> json) {
    return DiscountCardModel(
      id: json['id'],
      storeName: json['store_name'],
      storeLogoUrl: json['store_logo_url'],
      frontImageUrl: json['front_image_url'],
      backImageUrl: json['back_image_url'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_name': storeName,
      'store_logo_url': storeLogoUrl,
      'front_image_url': frontImageUrl,
      'back_image_url': backImageUrl,
      'notes': notes,
    };
  }
}