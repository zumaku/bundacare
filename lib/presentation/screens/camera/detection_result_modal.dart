import 'dart:io';
import 'package:bundacare/domain/entities/nutrition_result.dart';
import 'package:bundacare/presentation/widgets/image_with_bounding_boxes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bundacare/core/injection_container.dart' as di;
import 'package:bundacare/domain/repositories/detection_repository.dart';
import 'package:bundacare/presentation/bloc/detection/detection_bloc.dart';
import 'package:bundacare/presentation/bloc/food/food_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';

const Color calorieColor = Color(0xFFE66400);
const Color proteinColor = Color(0xFF0CE600);
const Color carbsColor = Color(0xFFE6E600);
const Color fatColor = Color(0xFFA13E00);

class DetectionResultModal extends StatefulWidget {
  final File imageFile;
  const DetectionResultModal({super.key, required this.imageFile});

  @override
  State<DetectionResultModal> createState() => _DetectionResultModalState();
}

class _DetectionResultModalState extends State<DetectionResultModal> {
  bool _isActionTaken = false;
  DetectionBloc? _detectionBloc;

  @override
  void dispose() {
    if (_detectionBloc != null) {
      final currentState = _detectionBloc!.state;
      if (currentState is DetectionSuccess && !_isActionTaken) {
        final detectionRepo = di.sl<DetectionRepository>();
        detectionRepo.deleteUploadedImage(currentState.imageUrl);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        _detectionBloc = di.sl<DetectionBloc>();
        return _detectionBloc!..add(DetectFoodStarted(widget.imageFile));
      },
      child: BlocListener<DetectionBloc, DetectionState>(
        listener: (context, state) {
          if (state is DetectionSaveSuccess) {
            _isActionTaken = true;
            context.read<FoodBloc>().add(FetchTodaysFood());
            if (mounted) Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Log makanan berhasil disimpan!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is DetectionFailure) {
            _isActionTaken = true;
            if (mounted) Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 1.0,
          minChildSize: 0.6,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2C2C2C),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: BlocBuilder<DetectionBloc, DetectionState>(
                builder: (context, state) {
                  // Pengecekan baru yang lebih aman
                  if (state is DetectionResultState) {
                    return _buildSuccessUI(
                      context,
                      state.result,
                      widget.imageFile,
                      scrollController,
                      state is DetectionSaveInProgress,
                    );
                  }
                  if (state is DetectionLoading || state is DetectionInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _buildFailureUI(context);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuccessUI(
    BuildContext context,
    NutritionResult result,
    File imageFile,
    ScrollController scrollController,
    bool isSaving,
  ) {
    final formattedDate = DateFormat(
      'dd MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());
    const Color cardColor = Color(0xFF353535);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            height: 5,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                imageFile,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                  // --- PERUBAHAN DI SINI: Gunakan nama gabungan ---
                  Text(
                    result.combinedFoodName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),

        if (result.foods.length > 1) ...[
          const SizedBox(height: 16),
          const Text(
            "Makanan Terdeteksi:",
            style: TextStyle(color: Colors.grey),
          ),
          ...result.foods.map(
            (food) => Text("• ${food.name} (${food.count} buah)"),
          ),
        ],

        const SizedBox(height: 16),

        // Di dalam method _buildSuccessUI di detection_result_modal.dart
        Row(
          children: [
            // Tombol Ulangi
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade300,
                side: BorderSide(color: Colors.grey.shade700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              // Gunakan parameter 'icon' dan 'label'
              icon: const Icon(Iconsax.refresh, size: 20),
              label: const Text('Ulangi'),
              onPressed: isSaving ? null : () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 12),

            // Tombol Simpan
            Expanded(
              flex: 2, // Beri jatah 2 bagian dari ruang (lebih lebar)
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  disabledBackgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.5),
                ),
                onPressed: isSaving
                    ? null
                    : () {
                        setState(() {
                          _isActionTaken = true;
                        });
                        context.read<DetectionBloc>().add(
                          DetectionSaveRequested(),
                        );
                      },
                child: isSaving
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Menyimpan...'),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.save_21, size: 20),
                          SizedBox(width: 8),
                          Text('Simpan'),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Tombol Info
            Expanded(
              flex: 1, // Beri jatah 1 bagian dari ruang
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade300,
                  side: BorderSide(color: Colors.grey.shade700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: isSaving ? null : () {},
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
        const Text(
          'Nutrisi',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            _buildNutritionTile(
              title: 'Kalori',
              iconAssetPath: 'assets/icons/calorie_icon.svg',
              value: result.totalCalories,
              unit: 'kcal',
              color: calorieColor, // <-- Gunakan warna spesifik
            ),
            _buildNutritionTile(
              title: 'Protein',
              iconAssetPath: 'assets/icons/protein_icon.svg',
              value: result.totalProtein,
              unit: 'g',
              color: proteinColor, // <-- Gunakan warna spesifik
            ),
            _buildNutritionTile(
              title: 'Karbo',
              iconAssetPath: 'assets/icons/carb_icon.svg',
              value: result.totalCarbohydrate,
              unit: 'g',
              color: carbsColor, // <-- Gunakan warna spesifik
            ),
            _buildNutritionTile(
              title: 'Lemak',
              iconAssetPath: 'assets/icons/fat_icon.svg',
              value: result.totalFat,
              unit: 'g',
              color: fatColor, // <-- Gunakan warna spesifik
            ),
          ],
        ),
        const SizedBox(height: 24),
        ImageWithBoxes(
          imageFile: imageFile,
          foodItems: result.foods,
          originalImageDimensions: result.imageDimensions,
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildFailureUI(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.danger, color: Colors.amber, size: 50),
          const SizedBox(height: 16),
          const Text(
            "Deteksi Gagal",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tidak dapat mengenali makanan pada gambar. Coba lagi dengan gambar yang lebih jelas.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionTile({
    required String title,
    required String iconAssetPath,
    required double value,
    required String unit,
    required Color color, // Warna ini sekarang untuk ikon
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
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
            child: SvgPicture.asset(iconAssetPath),
          ),
          const SizedBox(width: 12),
          // Kolom untuk teks
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      // Tambahkan overflow agar teks panjang tidak error
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${value.toStringAsFixed(1)} $unit',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
