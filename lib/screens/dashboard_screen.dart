import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_ppb/models/product.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Product>> _products;
  final ApiService _apiService = ApiService();
  String? _role;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _loadUserRole(); // Load user role from SharedPreferences
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role'); // Get the role from SharedPreferences
    });
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _products = _apiService.fetchProducts(); // Mengambil produk dari API
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada produk'));
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final product = snapshot.data![index];
                return ProductCard(
                  name: product.name,
                  description: product.description,
                  price: product.price.toString(),
                  imageUrl: product.imageUrl,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/productDetail',
                      arguments: product.id,
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: _role == 'admin' // Show button only for admin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/adminProducts');
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
