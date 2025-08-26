// Di dalam file detection_result_modal.dart, di bagian paling bawah

import 'dart:io';
import 'package:bundacare/domain/entities/nutrition_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;

class ImageWithBoxes extends StatefulWidget {
  final File imageFile;
  final List<FoodItem> foodItems;
  final Map<String, int>? originalImageDimensions;

  const ImageWithBoxes({
    required this.imageFile,
    required this.foodItems,
    required this.originalImageDimensions,
  });

  @override
  State<ImageWithBoxes> createState() => ImageWithBoxesState();
}

class ImageWithBoxesState extends State<ImageWithBoxes> {
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _calculateAspectRatio();
  }

  Future<void> _calculateAspectRatio() async {
    final imageBytes = await widget.imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image != null && mounted) {
      setState(() {
        _aspectRatio = image.width / image.height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil dimensi asli dari API jika tersedia
    final double? originalWidth = widget.originalImageDimensions?['width']?.toDouble();
    final double? originalHeight = widget.originalImageDimensions?['height']?.toDouble();

    // Gunakan aspect ratio yang dihitung dari file gambar jika tidak ada dari API
    final aspectRatio = _aspectRatio ?? originalWidth! / originalHeight!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scaleX = constraints.maxWidth / (originalWidth ?? 1);
            final scaleY = constraints.maxHeight / (originalHeight ?? 1);

            return Stack(
              fit: StackFit.expand,
              children: [
                Image.file(widget.imageFile, fit: BoxFit.cover),
                ..._buildBoundingBoxes(scaleX, scaleY, context),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildBoundingBoxes(double scaleX, double scaleY, BuildContext context) {
    final List<Widget> boxes = [];
    final colors = [
      Theme.of(context).colorScheme.primary,
      Colors.green, Colors.yellow, Colors.blue, Colors.orange
    ];

    for (int i = 0; i < widget.foodItems.length; i++) {
      final foodItem = widget.foodItems.elementAt(i);
      final color = colors.elementAt(i % colors.length);

      for (final box in foodItem.boundingBoxes) {
        if (box.length == 4) {
          final xMin = box.elementAt(0);
          final yMin = box.elementAt(1);
          final xMax = box.elementAt(2);
          final yMax = box.elementAt(3);

          boxes.add(
            Positioned(
              left: xMin * scaleX,
              top: yMin * scaleY,
              width: (xMax - xMin) * scaleX,
              height: (yMax - yMin) * scaleY,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: color, width: 3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }
      }
    }
    return boxes;
  }
}