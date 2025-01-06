import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alamat Pengiriman',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan alamat',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Metode Pengiriman',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              items: const [
                DropdownMenuItem(
                  value: 'reguler',
                  child: Text('Reguler'),
                ),
                DropdownMenuItem(
                  value: 'express',
                  child: Text('Express'),
                ),
              ],
              onChanged: (value) {},
              hint: const Text('Pilih metode pengiriman'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Bayar Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}
