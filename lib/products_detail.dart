import 'package:flutter/material.dart';
import 'product.dart';

class ProductsDetail extends StatelessWidget {
  final Product product;

  const ProductsDetail({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              product.imagePath,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  width: 72,
                  height: 72,
                  child: Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          Text(
            product.name,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text('${product.price} USD'),
          Text(product.description),
        ],
      ),
    );
  }
}
