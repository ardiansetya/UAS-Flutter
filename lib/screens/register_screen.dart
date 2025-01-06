import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/navigation_utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController =
      TextEditingController(); // Mengganti roleController dengan nameController
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  void _register() async {
    final name = _nameController.text.trim(); // Mengambil nama
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua kolom')),
      );
      return;
    }

    try {
      print('Mencoba mendaftar dengan: $name, $username');
      final success = await _apiService.registerUser(
          name, username, password); // Mengirim name, username, dan password
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil')),
        );
        navigateTo(context, '/login'); // Redirect ke halaman login
      }
    } catch (e) {
      print('Error saat registrasi: $e'); // Log error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal registrasi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController, // Menggunakan nameController
              decoration:
                  const InputDecoration(labelText: 'Name'), // Mengganti label
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
