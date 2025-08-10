import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:bundacare/domain/entities/food_log.dart';
import 'package:bundacare/domain/entities/user_profile.dart';
import 'package:bundacare/presentation/bloc/auth/auth_bloc.dart';
import 'package:bundacare/presentation/bloc/food/food_bloc.dart';

// Definisikan warna-warna custom agar mudah dikelola
const Color cardBackgroundColor = Color(0xFF353535);
const Color innerCardBackgroundColor = Color(0xFF292929);
const Color progressBarBackgroundColor = Color(0xFF353535);
const Color calorieColor = Color(0xFFE66400);
const Color proteinColor = Color(0xFF0CE600);
const Color carbsColor = Color(0xFFE6E600);
const Color fatColor = Color(0xFFA13E00);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(
                  'assets/logo/app_bar_logo.svg',
                  height: 35,
                ),
                IconButton(
                  icon: const Icon(Iconsax.notification, size: 28),
                  onPressed: () => context.go('/notifications'),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<FoodBloc>().add(FetchTodaysFood());
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is Authenticated && state.profile?.pregnancyStartDate != null) {
                        return _TrimesterCard(startDate: state.profile!.pregnancyStartDate!);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  BlocBuilder<FoodBloc, FoodState>(
                    builder: (context, state) {
                      if (state is FoodLoaded) {
                        return _buildNutritionSection(context, state);
                      }
                      if (state is FoodError) {
                        return Center(child: Text('Gagal memuat data: ${state.message}'));
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                  const SizedBox(height: 16),

                  Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text("Makanan Hari Ini", style: TextStyle(fontSize: 16))),
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
                            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.8,
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
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
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
    // --- Logika Perhitungan ---
    final now = DateTime.now();
    // Menghitung total minggu kehamilan yang telah berlalu
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
      totalWeeksInTrimester = 14; // Total durasi trimester 2 adalah 14 minggu (minggu 14 s/d 27)
    } else {
      trimester = 3;
      weekInTrimester = currentWeek - 27;
      totalWeeksInTrimester = 13; // Total durasi trimester 3 adalah 13 minggu (minggu 28 s/d 40)
    }

    final progress = (totalWeeksInTrimester > 0) ? (weekInTrimester / totalWeeksInTrimester) : 0.0;
    final formattedDate = DateFormat('dd/MM/yy', 'id_ID').format(now);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: cardBackgroundColor,
      shape: Theme.of(context).cardTheme.shape,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trimester $trimester',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    // DIUBAH: Tampilkan total minggu kehamilan saat ini
                    Text(
                      'Minggu ke $currentWeek',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade400, height: 0.8),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Row(
                  children: [
                    // DIUBAH: Gunakan warna primer dari tema
                    Icon(Iconsax.calendar_1, size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(formattedDate, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
              backgroundColor: Colors.grey.shade800,
              // DIUBAH: Gunakan warna primer dari tema
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildNutritionSection(BuildContext context, FoodLoaded state) {
  final double targetKalori = 290;
  final double targetProtein = 181;
  final double targetKarbo = 362;
  final double targetLemak = 80;

  return Column(
    children: [
      Card(
        color: cardBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(6.0), child: _buildSectionHeader(context, icon: Iconsax.diagram, title: 'Total', color: calorieColor)),
              const SizedBox(height: 8),
              _buildNutritionRow(
                iconAssetPath: 'assets/icons/calorie_icon.svg',
                title: 'Kalori',
                color: calorieColor,
                value: state.totalCalories,
                target: targetKalori,
                unit: 'kcal',
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      Card(
        color: cardBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(6.0), child: _buildSectionHeader(context, icon: Iconsax.graph, title: 'Makro', color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 4),
              _buildNutritionRow(
                iconAssetPath: 'assets/icons/protein_icon.svg',
                title: 'Protein',
                color: proteinColor,
                value: state.totalProtein,
                target: targetProtein,
                unit: 'g',
              ),
              const SizedBox(height: 6),
              _buildNutritionRow(
                iconAssetPath: 'assets/icons/carb_icon.svg',
                title: 'Karbo',
                color: carbsColor,
                value: state.totalCarbohydrate,
                target: targetKarbo,
                unit: 'g',
              ),
              const SizedBox(height: 6),
              _buildNutritionRow(
                iconAssetPath: 'assets/icons/fat_icon.svg',
                title: 'Lemak',
                color: fatColor,
                value: state.totalFat,
                target: targetLemak,
                unit: 'g',
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

// WIDGET HELPER BARU UNTUK HEADER (Total & Makro)
Widget _buildSectionHeader(BuildContext context, {required IconData icon, required String title, required Color color}) {
  return Row(
    children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const Spacer(),
      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    ],
  );
}

// WIDGET HELPER BARU UNTUK BARIS NUTRISI
Widget _buildNutritionRow({
  required String iconAssetPath,
  required String title,
  required Color color,
  required double value,
  required double target,
  required String unit,
}) {
  final double percentage = (target > 0) ? (value / target) : 0.0;

  return Card(
    color: innerCardBackgroundColor,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(50),
            ),
            child: SvgPicture.asset(
              iconAssetPath,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 12),
          // Judul dan Progress Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                // 1. Bungkus Progress Bar dan Persentase dengan Row
                Row(
                  children: [
                    // Progress bar sekarang akan mengambil sisa ruang
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: progressBarBackgroundColor,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Teks Persentase di sampingnya
                    Text(
                      '${(percentage * 100).toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 2. Beri lebar tetap pada container teks nilai
          SizedBox(
            width: 110, // Lebar tetap untuk konsistensi
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${value.toStringAsFixed(1)}/${target.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  ),
                ]
              ),
              textAlign: TextAlign.end,
            ),
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