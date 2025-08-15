import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:bundacare/domain/entities/nutrition_result.dart';

class ImageWithBoundingBoxes extends StatefulWidget {
  final File imageFile;
  final List<FoodItem> foodItems;

  const ImageWithBoundingBoxes({
    super.key,
    required this.imageFile,
    required this.foodItems,
  });

  @override
  State<ImageWithBoundingBoxes> createState() => _ImageWithBoundingBoxesState();
}

class _ImageWithBoundingBoxesState extends State<ImageWithBoundingBoxes> {
  ui.Image? _backgroundImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  // Fungsi untuk memuat gambar dan mendapatkan ukurannya
  Future<void> _loadImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    final image = await decodeImageFromList(bytes);
    if (mounted) {
      setState(() {
        _backgroundImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading jika gambar belum siap
    if (_backgroundImage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        // Gunakan aspect ratio dari gambar asli agar tidak terdistorsi
        aspectRatio: _backgroundImage!.width / _backgroundImage!.height,
        child: CustomPaint(
          // Kirim gambar dan bounding box ke painter
          painter: BoundingBoxPainter(
            image: _backgroundImage!,
            foodItems: widget.foodItems,
          ),
        ),
      ),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final ui.Image image;
  final List<FoodItem> foodItems;

  BoundingBoxPainter({required this.image, required this.foodItems});

  @override
  void paint(Canvas canvas, Size size) {
    // Gambar latar belakang (gambar makanan)
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.width, size.height),
      image: image,
      fit: BoxFit.cover,
      alignment: Alignment.center,
    );

    // Hitung faktor skala
    final double scaleX = size.width / image.width;
    final double scaleY = size.height / image.height;

    final colors = [
      Colors.pink, Colors.green, Colors.yellow, Colors.blue, Colors.orange
    ];

    for (int i = 0; i < foodItems.length; i++) {
      final foodItem = foodItems[i];
      final color = colors[i % colors.length];
      
      final paint = Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      for (final box in foodItem.boundingBoxes) {
        // Asumsi format box sekarang adalah [x_min, y_min, x_max, y_max]
        if (box.length == 4) {
          // Buat Rect dari dua titik dan sesuaikan skalanya
          final scaledRect = Rect.fromLTRB(
            box[0] * scaleX, // x_min
            box[1] * scaleY, // y_min
            box[2] * scaleX, // x_max
            box[3] * scaleY, // y_max
          );
          canvas.drawRect(scaledRect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return image != oldDelegate.image || foodItems != oldDelegate.foodItems;
  }
}