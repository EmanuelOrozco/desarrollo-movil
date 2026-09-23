import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'itemCard.dart';
import 'product.dart';
import 'products_detail.dart';
import 'services/product_services.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int? favoriteId;

  late final ProductServices _service;
  late Future<List<Product>> _futureProducts;

  void toggleFavorite(int productId) {
    setState(() {
      favoriteId = favoriteId == productId ? null : productId;
      saveFavoriteId();
    });
  }

  Future<void> saveFavoriteId() async {
    final prefs = await SharedPreferences.getInstance();
    if (favoriteId == null) {
      await prefs.remove('favoriteId');
    } else {
      await prefs.setInt('favoriteId', favoriteId!);
    }
  }

  Future<void> loadFavoriteId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteId = prefs.getInt('favoriteId');
    });
  }

  @override
  void initState() {
    super.initState();
    _service = ProductServices(
      baseUrl: 'https://dummyjson.com/c/b7c3-d875-45ac-ab06',
    );
    _futureProducts = _service.getProducts();
    loadFavoriteId();
  }

  void openProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductsDetail(product: product)),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<Product>>(
      future: _futureProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar los productos'));
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return const Center(child: Text('No hay productos'));
        }

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final bool isFavorite = product.id == favoriteId;
            return ItemCard(
              product: product,
              onTap: () {
                openProductDetail(product);
              },
              isFavorite: isFavorite,
              onFavoriteTap: () {
                toggleFavorite(product.id!);
              },
            ); // ItemCard
          },
        ); // ListView.builder
      },
    ); // FutureBuilder
  } // _buildBody()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: Padding(padding: const EdgeInsets.all(16), child: _buildBody()),
    );
  }
}
