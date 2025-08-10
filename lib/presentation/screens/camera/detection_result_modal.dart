import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bundacare/core/injection_container.dart' as di;
import 'package:bundacare/domain/repositories/detection_repository.dart'; // <-- 1. TAMBAHKAN IMPORT INI
import 'package:bundacare/presentation/bloc/detection/detection_bloc.dart';
import 'package:bundacare/presentation/bloc/food/food_bloc.dart';
import 'package:intl/intl.dart';

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
    // 2. UBAH LOGIKA DI DALAM DISPOSE
    if (_detectionBloc != null) {
      final currentState = _detectionBloc!.state;
      if (currentState is DetectionSuccess && !_isActionTaken) {
        // Panggil repository secara langsung, bukan via event BLoC
        final detectionRepo = di.sl<DetectionRepository>();
        detectionRepo.deleteUploadedImage(currentState.imageUrl);
        debugPrint("Modal dismissed, deleting orphaned image via repository: ${currentState.imageUrl}");
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
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Log makanan berhasil disimpan!'), backgroundColor: Colors.green),
            );
          }
          if (state is DetectionFailure) {
            _isActionTaken = true;
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red),
            );
             Navigator.of(context).pop();
          }
        },
        child: DraggableScrollableSheet(
          initialChildSize: 0.85, maxChildSize: 0.85,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2C2C2C),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                   Padding(
                    padding: const EdgeInsets.only(top: 8, right: 8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: 5, width: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade600,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<DetectionBloc, DetectionState>(
                      builder: (context, state) {
                        if (state is DetectionLoading || state is DetectionInitial) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (state is DetectionSuccess) {
                          return _buildSuccessUI(context, state, widget.imageFile);
                        }
                        return const Center(child: Text("Gagal mendeteksi..."));
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuccessUI(BuildContext context, DetectionSuccess state, File imageFile) {
    final result = state.result;
    final formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(imageFile, height: 200, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(imageFile, width: 50, height: 50, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formattedDate, style: TextStyle(color: Colors.grey.shade400)),
                  Text(result.foodName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Ulangi'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
                  onPressed: () {
                    setState(() { _isActionTaken = true; });
                    context.read<DetectionBloc>().add(DetectionSaveRequested());
                  },
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                child: const Icon(Icons.info_outline),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Nutrisi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _buildNutritionTile('Kalori', result.calories, 'kcal', Colors.orange),
              _buildNutritionTile('Protein', result.protein, 'g', Colors.green),
              _buildNutritionTile('Karbo', result.carbohydrate, 'kcal', Colors.yellow.shade700),
              _buildNutritionTile('Lemak', result.fat, 'g', Colors.red.shade400),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildNutritionTile(String title, double value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${value.toStringAsFixed(1)} $unit', style: TextStyle(color: Colors.grey.shade400)),
            ],
          )
        ],
      ),
    );
  }
}