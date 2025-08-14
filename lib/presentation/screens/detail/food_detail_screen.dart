import 'dart:ui';
import 'package:bundacare/presentation/bloc/food/food_bloc.dart';
import 'package:flutter/material.dart';
import 'package:bundacare/domain/entities/food_log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

// Definisikan konstanta warna agar konsisten
const Color calorieColor = Color(0xFFE66400);
const Color proteinColor = Color(0xFF0CE600);
const Color carbsColor = Color(0xFFE6E600);
const Color fatColor = Color(0xFFA13E00);
const Color cardColor = Color(0xFF353535);

class FoodDetailScreen extends StatelessWidget {
  final FoodLog foodLog;// Metode baru untuk menampilkan dialog konfirmasi
  
  void _showDeleteConfirmationDialog(BuildContext context, int logId) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: const Text('Hapus Log Makanan?'),
          content: const Text('Apakah Anda yakin ingin menghapus catatan ini? Aksi ini tidak dapat dibatalkan.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: Text('Hapus', style: TextStyle(color: Colors.red.shade400)),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      // Panggil BLoC untuk menghapus data
      context.read<FoodBloc>().add(DeleteFoodLogRequested(logId));
      
      // --- PERBAIKAN DI SINI ---
      // Gunakan context.go('/') untuk kembali ke home secara eksplisit
      // daripada context.pop()
      context.go('/');
    }
  }

  const FoodDetailScreen({super.key, required this.foodLog});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(foodLog.createdAt);
    
    return Scaffold(
      // Hapus AppBar standar
      body: Stack(
        children: [
          // Lapisan 1: Gambar Utama Full-width
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

          // Lapisan 2: Tombol Kembali dengan efek blur
          Positioned(
            top: 50, // Sesuaikan posisi dari atas
            left: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go('/'),
                  ),
                ),
              ),
            ),
          ),

          // Lapisan 3: Konten Detail (menyerupai modal)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: BoxConstraints(
                // Batasi ketinggian maksimal agar tidak menutupi seluruh layar
                maxHeight: MediaQuery.of(context).size.height * 0.50, 
              ),
              padding: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        height: 5,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Info Makanan
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(foodLog.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(formattedDate, style: TextStyle(color: Colors.grey.shade400)),
                              Text(
                                foodLog.foodName,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Tombol Aksi (Hapus & Info)
                    Row(
                      children: [
                        // Tombol Hapus (sekarang OutlinedButton)
                        Expanded(
                          flex: 1, // Beri jatah 2 bagian dari ruang (lebih lebar)
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              disabledBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            ),
                            onPressed: () {
                              _showDeleteConfirmationDialog(context, foodLog.id);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Iconsax.trash, size: 20),
                                SizedBox(width: 8),
                                Text('Hapus'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Tombol Info (menggantikan tombol Ubah)
                        Expanded(
                          flex: 1, // Beri jatah 1 bagian dari ruang
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade300,
                              side: BorderSide(color: Colors.grey.shade700),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {},
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Iconsax.info_circle, size: 20),
                                SizedBox(width: 8),
                                Text('Info'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Detail Nutrisi
                    const Text('Nutrisi', style: TextStyle(fontSize: 16)),
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
                    ),
                    const SizedBox(height: 16), // Padding bawah
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget helper untuk kartu nutrisi (Sama seperti di modal)
Widget _buildNutritionTile(BuildContext context, {
  required String title,
  required String iconAssetPath,
  required double value,
  required String unit,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF353535), // Warna latar belakang kartu
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        // Latar belakang ikon yang melingkar
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            iconAssetPath,
          ),
        ),
        const SizedBox(width: 12),
        // Kolom untuk teks
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('${value.toStringAsFixed(1)} $unit',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          ],
        )
      ],
    ),
  );
}