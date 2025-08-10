import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BundaCare')),
      body: SafeArea(
        child: Column(
          children: [
            // Trimester card and macro summary placeholders
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
              child: Column(children: const [
                Text('Trimester 2', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Ringkasan nutrisi hari ini (placeholder)'),
              ]),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(12),
                children: List.generate(6, (index) => Card(
                  child: InkWell(
                    onTap: () => context.push('/detail/${index+1}'),
                    child: Center(child: Text('Food ${index+1}')),
                  ),
                )),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Kamera'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (i) {
          if (i == 1) context.push('/home'); // replace with camera route
          if (i == 2) context.push('/profile');
        },
      ),
    );
  }
}
