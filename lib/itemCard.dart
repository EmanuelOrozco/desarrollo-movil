import 'package:flutter/material.dart';
import 'product.dart';

class ItemCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  const ItemCard({
    super.key,
    required this.product,
    this.onTap,
    this.isFavorite = false,
    required this.onFavoriteTap,
  });


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text('${product.price} USD'),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
