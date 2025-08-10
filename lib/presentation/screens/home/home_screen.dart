import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bundacare/core/injection_container.dart' as di;
import 'package:bundacare/presentation/bloc/food/food_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocProvider menyediakan FoodBloc ke widget tree di bawahnya
    return BlocProvider(
      create: (context) => di.sl<FoodBloc>()..add(FetchTodaysFood()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BundaCare'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                // TODO: Arahkan ke halaman riwayat
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => context.go('/profile'),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          // Widget RefreshIndicator untuk fungsionalitas pull-to-refresh
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<FoodBloc>().add(FetchTodaysFood());
            },
            child: ListView( // Menggunakan ListView agar bisa di-scroll
              children: [
                const SizedBox(height: 16),
                const Text("Ringkasan Hari Ini", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                BlocBuilder<FoodBloc, FoodState>(
                  builder: (context, state) {
                    if (state is FoodLoading && state is! FoodLoaded) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is FoodLoaded) {
                      return Column(
                        children: [
                          _buildNutritionCard('Kalori', state.totalCalories, 2500, 'kcal'),
                          _buildNutritionCard('Protein', state.totalProtein, 181, 'g'),
                          _buildNutritionCard('Karbo', state.totalCarbohydrate, 362, 'g'),
                          _buildNutritionCard('Lemak', state.totalFat, 80, 'g'),
                        ],
                      );
                    }
                    if (state is FoodError) {
                      return Center(child: Text('Gagal memuat data: ${state.message}'));
                    }
                    // Tampilkan state awal atau jika data kosong
                    return const Center(child: Text("Tarik ke bawah untuk refresh."));
                  },
                ),
                const SizedBox(height: 24),
                const Text("Makanan Hari Ini", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                // Di sini nanti kita akan menampilkan daftar makanan
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: 'Kamera',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: 0, // Set index ke 0 untuk Home
          onTap: (index) {
            if (index == 2) {
              context.go('/profile');
            }
            // TODO: Handle navigasi untuk kamera (index 1)
          },
        ),
      ),
    );
  }

  // Widget helper untuk membuat kartu nutrisi
  Widget _buildNutritionCard(String title, double value, double target, String unit) {
    // Hardcode nilai target sesuai desain Anda untuk sementara
    final targetValues = {
      'Kalori': 289.7,
      'Protein': 181.0,
      'Karbo': 362.0,
      'Lemak': 80.0,
    };
    target = targetValues[title] ?? target;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text('${value.toStringAsFixed(1)} / ${target.toStringAsFixed(1)} $unit',
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (target > 0) ? (value / target) : 0.0,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      ),
    );
  }
}