class Product {
  String name;
  double price;
  int inventory;
  String category;
  bool isAvailable;
  String imagePath;
  String description;
  // Constructor

  Product({
    required this.name,
    required this.price,
    required this.inventory,
    required this.category,
    required this.isAvailable,
    required this.imagePath,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      inventory: json['inventory'] as int,
      category: json['category'] as String,
      isAvailable: json['isAvailable'] as bool,
      imagePath: json['imagePath'] as String,
      description: json['description'] as String,
    );
  }
}
