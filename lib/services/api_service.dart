import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'https://api-ppb.vercel.app';

  // Register user
  Future<bool> registerUser(
      String username, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user': username,
        'username': username,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to register user');
    }
  }

  // Login user
  Future<String> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token']; // Assuming API returns a token
    } else {
      throw Exception('Login failed');
    }
  }

  // Logout user (optional depending on API support)
  Future<void> logoutUser() async {
    // Clear local storage or tokens if necessary
  }

  // Fetch all products
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/api/products'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Fetch product by ID
  Future<Product> fetchProductById(int productId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/products/$productId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Product.fromJson(data);
    } else {
      throw Exception('Failed to fetch product details');
    }
  }

  // Create a new product
  Future<bool> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/products'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to create product');
    }
  }

  // Update a product
  Future<bool> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/products/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update product');
    }
  }

  // Delete a product
  Future<bool> deleteProduct(int productId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/products/$productId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete product');
    }
  }

  // Add to cart
  Future<bool> addToCart(int userId, int productId, int quantity) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/carts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'product_id': productId,
        'jumlah': quantity,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to add product to cart');
    }
  }

  // Fetch cart by user
  Future<List<dynamic>> fetchCart(int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/carts/user'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch cart');
    }
  }

  // Remove item from cart
  Future<bool> removeFromCart(int userId, int productId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/carts/remove'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'user_id': userId, 'product_id': productId}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to remove product from cart');
    }
  }

  // Add shipping info and get receipt
  Future<bool> addShipping(
    int userId,
    String origin,
    String destination,
    double cost,
    double weight,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/carts/add-shipping'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'kota_asal': origin,
        'kota_tujuan': destination,
        'biaya_ongkir': cost,
        'weight': weight,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to add shipping');
    }
  }

  // Checkout and validate payment
  Future<bool> checkout(int userId, bool isPaid) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/carts/checkout'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'user_id': userId, 'is_paid': isPaid}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to checkout');
    }
  }
}
