import 'package:flutter/material.dart';
import 'package:bundacare/domain/entities/food_log.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Pindahkan konstanta warna ke sini agar bisa digunakan kembali
const Color calorieColor = Color(0xFFE66400);
const Color proteinColor = Color(0xFF0CE600);
const Color carbsColor = Color(0xFFE6E600);
const Color fatColor = Color(0xFFA13E00);
const Color cardColor = Color(0xFF353535);

class FoodDetailScreen extends StatelessWidget {
  final FoodLog foodLog;

  const FoodDetailScreen({super.key, required this.foodLog});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(foodLog.createdAt);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Detail Makanan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar Utama
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                foodLog.imageUrl,
                height: 250,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(heightFactor: 4, child: CircularProgressIndicator());
                },
              ),
            ),
            const SizedBox(height: 24),

            // Info Makanan
            Text(formattedDate, style: TextStyle(color: Colors.grey.shade400)),
            Text(
              foodLog.foodName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Tombol Aksi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Iconsax.trash),
                    label: const Text('Hapus'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade400,
                      side: BorderSide(color: Colors.red.shade400),
                    ),
                    onPressed: () {
                      // TODO: Implementasi logika hapus
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Iconsax.edit),
                    label: const Text('Ubah'),
                    onPressed: () {
                      // TODO: Implementasi logika ubah
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Detail Nutrisi
            const Text('Nutrisi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _buildNutritionTile(context, title: 'Kalori', iconAssetPath: 'assets/icons/calorie_icon.svg', value: foodLog.calories, unit: 'kcal', color: calorieColor),
                _buildNutritionTile(context, title: 'Protein', iconAssetPath: 'assets/icons/protein_icon.svg', value: foodLog.protein, unit: 'g', color: proteinColor),
                _buildNutritionTile(context, title: 'Karbo', iconAssetPath: 'assets/icons/carb_icon.svg', value: foodLog.carbohydrate, unit: 'kcal', color: carbsColor),
                _buildNutritionTile(context, title: 'Lemak', iconAssetPath: 'assets/icons/fat_icon.svg', value: foodLog.fat, unit: 'g', color: fatColor),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Widget helper untuk kartu nutrisi
Widget _buildNutritionTile(
  BuildContext context, {
  required String title,
  required String iconAssetPath,
  required double value,
  required String unit,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: SvgPicture.asset(
            iconAssetPath,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('${value.toStringAsFixed(1)} $unit', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          ],
        )
      ],
    ),
  );
}