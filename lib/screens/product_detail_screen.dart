import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Product> _product;

  @override
  void initState() {
    super.initState();
    _product = _apiService
        .fetchProductById(widget.productId); // Mengambil detail produk
  }

  Future<void> _addToCart(int userId) async {
    try {
      await _apiService.addToCart(
          userId, widget.productId, 1); // Menambahkan produk ke keranjang
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Produk berhasil ditambahkan ke keranjang')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan ke keranjang: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: FutureBuilder<Product>(
        future: _product,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Produk tidak ditemukan'));
          } else {
            final product = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.network(product.imageUrl), // Menampilkan gambar produk
                  const SizedBox(height: 16),
                  Text(product.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Harga: \$${product.price}',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  Text(product.description,
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final userId = prefs.getInt(
                          'user_id'); // Mengambil userId dari SharedPreferences
                      if (userId != null) {
                        _addToCart(userId); // Menambahkan produk ke keranjang
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Silakan login terlebih dahulu')),
                        );
                      }
                    },
                    child: const Text('Tambah ke Keranjang'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
