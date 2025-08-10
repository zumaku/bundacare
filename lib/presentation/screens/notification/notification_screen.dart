import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop(); // balik ke halaman sebelumnya
          },
        ),
      ),
      body: const Center(
        child: Text(
          'Belum ada notifikasi.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}