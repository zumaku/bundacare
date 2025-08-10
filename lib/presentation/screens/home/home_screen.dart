import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:bundacare/domain/entities/food_log.dart';
import 'package:bundacare/domain/entities/user_profile.dart';
import 'package:bundacare/presentation/bloc/auth/auth_bloc.dart';
import 'package:bundacare/presentation/bloc/food/food_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          // Saat ditarik, panggil ulang event untuk mengambil data makanan
          context.read<FoodBloc>().add(FetchTodaysFood());
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            const SizedBox(height: 16),
            const Text(
              'BundaCare',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // --- KARTU TRIMESTER ---
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  final UserProfile? profile = state.profile;
                  if (profile != null && profile.pregnancyStartDate != null) {
                    return _TrimesterCard(startDate: profile.pregnancyStartDate!);
                  }
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),

            // --- RINGKASAN NUTRISI ---
            const Text("Ringkasan Hari Ini", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            BlocBuilder<FoodBloc, FoodState>(
              builder: (context, state) {
                if (state is FoodLoaded) {
                  return Column(
                    children: [
                      _buildNutritionCard('Kalori', state.totalCalories, 289.7, 'kcal'),
                      _buildNutritionCard('Protein', state.totalProtein, 181, 'g'),
                      _buildNutritionCard('Karbo', state.totalCarbohydrate, 362, 'g'),
                      _buildNutritionCard('Lemak', state.totalFat, 80, 'g'),
                    ],
                  );
                }
                if (state is FoodError) {
                  return Center(child: Text('Gagal memuat data: ${state.message}'));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            const SizedBox(height: 24),

            // --- DAFTAR MAKANAN HARI INI ---
            const Text("Makanan Hari Ini", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
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
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: state.foodLogs.length,
                    itemBuilder: (context, index) {
                      final foodLog = state.foodLogs[index];
                      return _buildFoodItemCard(foodLog);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

//==============================================================================
// WIDGET HELPER DI BAWAH INI
//==============================================================================

class _TrimesterCard extends StatelessWidget {
  final DateTime startDate;
  const _TrimesterCard({required this.startDate});

  @override
  Widget build(BuildContext context) {
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
      totalWeeksInTrimester = 14;
    } else {
      trimester = 3;
      weekInTrimester = currentWeek - 27;
      totalWeeksInTrimester = 13;
    }

    final progress = (totalWeeksInTrimester > 0) ? (weekInTrimester / totalWeeksInTrimester) : 0.0;
    final formattedDate = DateFormat('dd/MM/yy', 'id_ID').format(now);

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

Widget _buildNutritionCard(String title, double value, double target, String unit) {
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

Widget _buildFoodItemCard(FoodLog foodLog) {
  return Card(
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned.fill(
          child: Image.network(
            foodLog.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40));
            },
          ),
        ),
        Container(
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
            ),
          ),
        ),
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