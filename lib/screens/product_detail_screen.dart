import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductDetailScreen extends StatelessWidget {
  final int productId;

  ProductDetailScreen({required this.productId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product>(
      future: ApiService()
          .fetchProductById(productId), // Ambil produk berdasarkan ID
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No product found'));
        }

        final product = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(product.name),
          ),
          body: Column(
            children: [
              Image.network(
                product.imageUrl, // Menggunakan URL gambar dari produk
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return Text('Failed to load image');
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(product.description),
              ),
              Text('Price: \$${product.price}'),
            ],
          ),
        );
      },
    );
  }
}
