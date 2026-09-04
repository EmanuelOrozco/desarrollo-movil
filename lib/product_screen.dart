import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'itemCard.dart';
import 'product.dart';
import 'products_detail.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  // Estado de la pantalla.
  // Durante la clase analizaremos qué representa cada variable
  // y cuándo debe cambiar.
  bool isLoading = false;
  List<Product> products = [];
  String errorMessage = '';
  int? favoriteId;

  void toggleFavorite(int productId) {
    setState(() {
      favoriteId = favoriteId == productId ? null : productId;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  // Simula una operación asíncrona, como consultar una API.
  Future<List<Product>> loadProducts() async {
    await Future.delayed(
      const Duration(seconds: 2),
    );

    final String jsonString =
        await rootBundle.loadString('assets/data/data.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);

    return jsonList
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Esta función se construirá progresivamente durante la clase.
  Future<void> fetchProducts() async {
    // CHECKPOINTS DE LA CLASE:
    // 1. Activar el estado de carga.
    // 2. Esperar los datos.
    // 3. Guardar las películas.
    // 4. Finalizar la carga.
    // 5. Manejar un posible error.
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final data = await loadProducts();
      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar los productos';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Empezamos con una interfaz mínima que ya funciona.
    // Este método evolucionará durante los checkpoints.

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      ); // center
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    if (products.isEmpty) {
      return Center(
        child: ElevatedButton(
          onPressed: fetchProducts,
          child: const Text('Cargar productos'),
        ),
      );
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return ItemCard(
          product: product,
          isFavorite: favoriteId == index,
          onFavoriteTap: () => toggleFavorite(index),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductsDetail(product: product),
            ),
          ),
        );
      }, // itemBuilder
    ); // ListView.builder
  } // _buildBody() 
} // _ProductScreenState
