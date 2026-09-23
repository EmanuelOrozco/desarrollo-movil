class ProductNote {
  final int productId;
  final String note;
  final int rating;
  final DateTime updatedAt;

  ProductNote({
    required this.productId,
    required this.note,
    required this.rating,
    required this.updatedAt,
  });

  factory ProductNote.fromJson(Map<String, dynamic> json) {
    return ProductNote(
      productId: json['productId'] as int,
      note: json['note'] as String,
      rating: json['rating'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'note': note,
        'rating': rating,
        'updatedAt': updatedAt.toIso8601String(),
      };
}
