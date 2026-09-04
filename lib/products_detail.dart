import 'package:flutter/material.dart';
import 'product.dart';

class ProductsDetail extends StatelessWidget {
  final Product product;

  const ProductsDetail({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              product.imagePath,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          Text(
            product.name,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text('${product.price} USD'),
          Text(product.description),
        ],
      ),
    );
  }
}
