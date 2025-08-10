import 'package:bundacare/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bundacare/core/injection_container.dart' as di;
import 'package:bundacare/domain/entities/food_log.dart'; // Import entitas FoodLog
import 'package:bundacare/presentation/bloc/food/food_bloc.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<FoodBloc>().add(FetchTodaysFood());
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              const SizedBox(height: 16),
              // -- KARTU TRIMESTER --
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is Authenticated && state.profile?.pregnancyStartDate != null) {
                    return _TrimesterCard(startDate: state.profile!.pregnancyStartDate!);
                  }
                  return const SizedBox.shrink(); // Widget kosong jika data belum siap
                },
              ),
              const SizedBox(height: 16),
              const Text("Ringkasan Hari Ini", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // --- Bagian Ringkasan Nutrisi (TETAP SAMA) ---
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
                  return const Center(child: Text("Tarik ke bawah untuk refresh."));
                },
              ),
              const SizedBox(height: 24),
              const Text("Makanan Hari Ini", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // --- BAGIAN BARU: DAFTAR MAKANAN ---
              BlocBuilder<FoodBloc, FoodState>(
                builder: (context, state) {
                  if (state is FoodLoaded) {
                    if (state.foodLogs.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text("Belum ada makanan yang dicatat hari ini."),
                        ),
                      );
                    }
                    // Tampilkan GridView jika ada data
                    return GridView.builder(
                      shrinkWrap: true, // Penting agar GridView bisa di dalam ListView
                      physics: const NeverScrollableScrollPhysics(), // Nonaktifkan scroll GridView
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 kolom
                        crossAxisSpacing: 12, // Jarak horizontal
                        mainAxisSpacing: 12,  // Jarak vertikal
                        childAspectRatio: 0.8, // Rasio lebar:tinggi untuk setiap item
                      ),
                      itemCount: state.foodLogs.length,
                      itemBuilder: (context, index) {
                        final foodLog = state.foodLogs[index];
                        return _buildFoodItemCard(foodLog);
                      },
                    );
                  }
                  // Tampilkan state loading atau error
                  return const SizedBox.shrink(); // Widget kosong jika belum loaded
                },
              ),
              const SizedBox(height: 24), // Beri jarak di bawah
            ],
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
          currentIndex: 0, 
          onTap: (index) {
            if (index == 2) {
              context.go('/profile');
            }
          },
        ),
      ),
    );
  }

  // --- Widget Helper untuk Kartu Nutrisi (TETAP SAMA) ---
  Widget _buildNutritionCard(String title, double value, double target, String unit) {
    final targetValues = {
      'Kalori': 289.7, 'Protein': 181.0, 'Karbo': 362.0, 'Lemak': 80.0,
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
              value: (target > 0) ? (value / target) : 0.0, minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER BARU: KARTU ITEM MAKANAN ---
  Widget _buildFoodItemCard(FoodLog foodLog) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Gambar Makanan
          Positioned.fill(
            child: Image.network(
              foodLog.imageUrl,
              fit: BoxFit.cover,
              // Tampilkan loading indicator saat gambar dimuat
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              // Tampilkan icon error jika gambar gagal dimuat
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40));
              },
            ),
          ),
          // Gradient hitam transparan di bawah
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Teks Kalori di atas kiri
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${foodLog.calories.toStringAsFixed(1)} kcal',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          // Teks Nama Makanan di bawah
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              foodLog.foodName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// -- WIDGET BARU UNTUK KARTU TRIMESTER --
class _TrimesterCard extends StatelessWidget {
  final DateTime startDate;

  const _TrimesterCard({required this.startDate});

  @override
  Widget build(BuildContext context) {
    // --- Logika Perhitungan ---
    final now = DateTime.now();
    final daysPassed = now.difference(startDate).inDays;
    final currentWeek = (daysPassed / 7).floor() + 1;

    int trimester;
    int weekInTrimester;
    int totalWeeksInTrimester;
    
    if (currentWeek <= 13) {
      trimester = 1;
      weekInTrimester = currentWeek;
      totalWeeksInTrimester = 13;
    } else if (currentWeek <= 27) {
      trimester = 2;
      weekInTrimester = currentWeek - 13;
      totalWeeksInTrimester = 14; // 27 - 13
    } else {
      trimester = 3;
      weekInTrimester = currentWeek - 27;
      totalWeeksInTrimester = 13; // 40 - 27
    }

    final progress = weekInTrimester / totalWeeksInTrimester;
    final formattedDate = DateFormat('dd/MM/yy').format(now);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Trimester $trimester', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.pink),
                    const SizedBox(width: 8),
                    Text(formattedDate),
                  ],
                ),
              ],
            ),
            Text('Minggu ke $weekInTrimester', style: TextStyle(fontSize: 16, color: Colors.grey.shade400)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
              backgroundColor: Colors.grey.shade800,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
            ),
          ],
        ),
      ),
    );
  }
}