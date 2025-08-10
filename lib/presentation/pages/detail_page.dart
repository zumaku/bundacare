import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final String logId;
  const DetailPage({super.key, required this.logId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 220, color: Colors.grey[800], child: const Center(child: Text('Image Placeholder'))),
              const SizedBox(height: 12),
              Text('Telur Orek', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('Kalori: 115.2 kcal\nProtein: 0.9 g\nLemak: 0.3 g\nKarbohidrat: 27.1 g'),
            ],
          ),
        ),
      ),
    );
  }
}
