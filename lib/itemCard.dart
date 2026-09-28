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
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  product.imagePath,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 110,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
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
              Text('${product.category}', style: TextStyle(color: Color(0xFF637DCE), fontWeight: FontWeight.bold),),
              const SizedBox(height: 4),
              Text('${product.price} USD'),
                IconButton(
                iconSize: 24,
                color: isFavorite ? Colors.green : Colors.black,
                onPressed: onFavoriteTap,
                icon: Icon(isFavorite ? Icons.shopping_cart : Icons.shopping_cart_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}