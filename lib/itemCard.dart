import 'package:flutter/material.dart';
import 'models/product.dart';

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
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                iconSize: 24,
                color: isFavorite ? Colors.yellow : Colors.black,
                onPressed: onFavoriteTap,
                icon: Icon(isFavorite ? Icons.star : Icons.star_border),
              ),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text('${product.price} USD'),
            ],
          ),
        ),
      ),
    );
  }
}
