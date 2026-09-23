import 'dart:convert';

import 'package:http/http.dart' as http;

import '../product.dart';

class ProductServices {
  final String baseUrl;

  ProductServices({required this.baseUrl});

  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 404) {
      throw Exception('Not found');
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to load products');
    }

    final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
    return jsonList
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
