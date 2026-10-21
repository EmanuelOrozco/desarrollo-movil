import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/app_logger.dart';
import '../models/product.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class ProductServices {
  final String baseUrl;

  ProductServices({required this.baseUrl});

  Future<List<Product>> getProducts() async {
    try {
      AppLogger.debug('Consultando catálogo remoto');

      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) {
        throw const ApiException('Not found');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final products = data
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
        AppLogger.debug('Productos obtenidos: ${products.length}');
        return products;
      }

      throw ApiException('Error HTTP: ${response.statusCode}');
    } on TimeoutException catch (error) {
      AppLogger.error('No fue posible obtener los productos', error: error);
      throw const ApiException('Timeout');
    } catch (error) {
      AppLogger.error('No fue posible obtener los productos', error: error);
      rethrow;
    }
  }
}
