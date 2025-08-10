import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat')),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: 10,
          itemBuilder: (context, index) => Card(
            child: ListTile(
              title: Text('Food item ${index+1}'),
              subtitle: Text('115.2 kcal'),
            ),
          ),
        ),
      ),
    );
  }
}
