import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'https://api-ppb.vercel.app';
  static const String rajaOngkirBaseUrl = 'https://api.rajaongkir.com/starter';

  // Fungsi untuk mendapatkan token yang tersimpan
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // Mengambil token yang disimpan
  }

  // Menambahkan header Authorization dengan token pada request
  Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final token = await _getToken();
    final requestHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    final Uri url = Uri.parse('$baseUrl$endpoint');
    switch (method) {
      case 'POST':
        return http.post(url, headers: requestHeaders, body: json.encode(body));
      case 'GET':
        return http.get(url, headers: requestHeaders);
      case 'PUT':
        return http.put(url, headers: requestHeaders, body: json.encode(body));
      case 'DELETE':
        return http.delete(url, headers: requestHeaders);
      default:
        throw Exception('Unsupported HTTP method');
    }
  }

  // Login pengguna
 Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    final response = await _makeRequest(
      'POST',
      '/api/users/login',
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      // Pastikan semua kunci ada dalam respons
      if (data['token'] == null ||
          data['userId'] == null ||
          data['role'] == null) {
        throw Exception('Respons tidak lengkap: $data');
      }

      return data; // Mengembalikan seluruh data respons sebagai Map
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
      throw Exception('Gagal login: ${response.body}');
    }
  }


  // Mendaftar pengguna baru
  Future<bool> registerUser(
      String username, String password, String role) async {
    final response = await _makeRequest(
      'POST',
      '/api/users',
      body: {
        'username': username,
        'password': password,
        'role': role,
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal mendaftar pengguna: ${response.body}');
    }
  }

  // Mengambil semua produk
  Future<List<Product>> fetchProducts() async {
    final response = await _makeRequest('GET', '/api/products');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat produk: ${response.body}');
    }
  }

  // Mengambil produk berdasarkan ID
  Future<Product> fetchProductById(int productId) async {
    final response = await _makeRequest('GET', '/api/products/$productId');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Product.fromJson(data);
    } else {
      throw Exception('Gagal mengambil detail produk: ${response.body}');
    }
  }

  // Membuat produk baru
  Future<bool> createProduct(Product product) async {
    final response = await _makeRequest(
      'POST',
      '/api/products',
      body: product.toJson(),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Gagal membuat produk: ${response.body}');
    }
  }

  // Memperbarui produk
  Future<bool> updateProduct(Product product) async {
    final response = await _makeRequest(
      'PUT',
      '/api/products/${product.id}',
      body: product.toJson(),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal memperbarui produk: ${response.body}');
    }
  }

  // Menghapus produk
  Future<bool> deleteProduct(int productId) async {
    final response = await _makeRequest('DELETE', '/api/products/$productId');

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal menghapus produk: ${response.body}');
    }
  }

  // Menambahkan produk ke keranjang
  Future<bool> addToCart(int userId, int productId, int quantity) async {
    final response = await _makeRequest(
      'POST',
      '/api/carts',
      body: {
        'user_id': userId,
        'product_id': productId,
        'jumlah': quantity,
      },
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Gagal menambahkan ke keranjang: ${response.body}');
    }
  }

  // Mengambil keranjang saat ini
  Future<List<Map<String, dynamic>>> getCurrentCart(int userId) async {
    final response = await _makeRequest(
      'POST',
      '/api/carts/user',
      body: {
        'user_id': userId,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Gagal mengambil keranjang: ${response.body}');
    }
  }

  // Menghapus produk dari keranjang
  Future<bool> removeFromCart(int userId, int productId) async {
    final response = await _makeRequest(
      'POST',
      '/api/carts/remove',
      body: {
        'user_id': userId,
        'product_id': productId,
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal menghapus dari keranjang: ${response.body}');
    }
  }

  // Menambahkan biaya pengiriman
  Future<bool> addShipping(int userId, String kotaAsal, String kotaTujuan,
      double biayaOngkir, double weight) async {
    final response = await _makeRequest(
      'POST',
      '/api/carts/add-shipping',
      body: {
        'user_id': userId,
        'kota_asal': kotaAsal,
        'kota_tujuan': kotaTujuan,
        'biaya_ongkir': biayaOngkir,
        'weight': weight,
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal menambahkan biaya pengiriman: ${response.body}');
    }
  }

  // Memvalidasi pembayaran
  Future<bool> validatePayment(int userId, bool isPaid) async {
    final response = await _makeRequest(
      'POST',
      '/api/carts/checkout',
      body: {
        'user_id': userId,
        'is_paid': isPaid,
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal memvalidasi pembayaran: ${response.body}');
    }
  }

  // Memperbarui pengguna
  Future<bool> updateUser(
      int userId, String username, String password, String role) async {
    final response = await _makeRequest(
      'PUT',
      '/api/users/$userId',
      body: {
        'username': username,
        'password': password,
        'role': role,
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal memperbarui pengguna: ${response.body}');
    }
  }
}
