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
  ui.Image? _imageInfo;

  @override
  void initState() {
    super.initState();
    _loadImageInfo();
  }

  Future<void> _loadImageInfo() async {
    final bytes = await widget.imageFile.readAsBytes();
    final image = await decodeImageFromList(bytes);
    if (mounted) {
      setState(() {
        _imageInfo = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imageInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        width: double.infinity,
        child: CustomPaint(
          painter: BoundingBoxPainter(
            image: _imageInfo!,
            foodItems: widget.foodItems,
          ),
          child: AspectRatio(
            // PERBAIKAN: Gunakan aspect ratio backend, bukan Flutter image
            aspectRatio: 1280 / 720, // Backend ratio: landscape
            child: Container(),
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
    print('=== DEBUGGING ORIENTATION FIX ===');
    print('Canvas size: ${size.width} x ${size.height}');
    print('Flutter Image size: ${image.width} x ${image.height}');
    
    // PERBAIKAN UTAMA: Gunakan dimensi backend sebagai ground truth
    final backendImageWidth = 1280.0;  // Backend width
    final backendImageHeight = 720.0;  // Backend height
    
    print('Backend image size: ${backendImageWidth} x ${backendImageHeight}');
    
    // 1. Tentukan apakah perlu rotasi koordinat
    bool needsRotation = false;
    if ((image.width < image.height) && (backendImageWidth > backendImageHeight)) {
      // Flutter image portrait, backend landscape - butuh rotasi
      needsRotation = true;
      print('ROTATION NEEDED: Flutter image is portrait, backend is landscape');
    }
    
    // 2. Gambar background image (Flutter image apa adanya)
    final imagePaint = Paint()..filterQuality = FilterQuality.high;
    final imageRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final srcRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    
    canvas.drawImageRect(image, srcRect, imageRect, imagePaint);
    
    // 3. Hitung scaling berdasarkan canvas yang mengikuti backend aspect ratio
    final scaleX = size.width / backendImageWidth;
    final scaleY = size.height / backendImageHeight;
    
    print('Scale factors: scaleX=$scaleX, scaleY=$scaleY');
    
    // 4. Warna untuk setiap detection
    final colors = [
      Colors.red,
      Colors.green, 
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.cyan,
      Colors.pink,
    ];

    // 5. Gambar bounding boxes
    int detectionIndex = 0;
    for (int foodIndex = 0; foodIndex < foodItems.length; foodIndex++) {
      final foodItem = foodItems[foodIndex];
      
      for (int boxIndex = 0; boxIndex < foodItem.boundingBoxes.length; boxIndex++) {
        final box = foodItem.boundingBoxes[boxIndex];
        
        if (box.length >= 4) {
          final color = colors[detectionIndex % colors.length];
          detectionIndex++;
          
          // Koordinat dari backend (dalam sistem koordinat 1280x720)
          double xMin = box[0].toDouble();
          double yMin = box[1].toDouble(); 
          double xMax = box[2].toDouble();
          double yMax = box[3].toDouble();
          
          print('--- Detection ${detectionIndex} ---');
          print('Food: ${foodItem.name}, Box ${boxIndex + 1}');
          print('Original backend coords: [$xMin, $yMin, $xMax, $yMax]');
          
          // PERBAIKAN: Jika perlu rotasi koordinat (dari landscape ke portrait)
          if (needsRotation) {
            // Rotasi 90 derajat: (x,y) -> (y, width-x)
            double newXMin = yMin;
            double newYMin = backendImageWidth - xMax;
            double newXMax = yMax; 
            double newYMax = backendImageWidth - xMin;
            
            xMin = newXMin;
            yMin = newYMin;
            xMax = newXMax;
            yMax = newYMax;
            
            // Update dimensi referensi setelah rotasi
            final rotatedWidth = backendImageHeight; // 720
            final rotatedHeight = backendImageWidth; // 1280
            
            // Recalculate scale dengan dimensi yang sudah dirotasi
            final rotatedScaleX = size.width / rotatedWidth;
            final rotatedScaleY = size.height / rotatedHeight;
            
            print('After rotation coords: [$xMin, $yMin, $xMax, $yMax]');
            print('Rotated scale: scaleX=$rotatedScaleX, scaleY=$rotatedScaleY');
            
            // Konversi ke koordinat canvas
            final canvasXMin = xMin * rotatedScaleX;
            final canvasYMin = yMin * rotatedScaleY;
            final canvasXMax = xMax * rotatedScaleX;
            final canvasYMax = yMax * rotatedScaleY;
            
            print('Final canvas coords: [$canvasXMin, $canvasYMin, $canvasXMax, $canvasYMax]');
            
            _drawBoundingBox(canvas, canvasXMin, canvasYMin, canvasXMax, canvasYMax, color, '${foodItem.name} ${boxIndex + 1}');
          } else {
            // Tidak perlu rotasi, langsung scale
            final canvasXMin = xMin * scaleX;
            final canvasYMin = yMin * scaleY;
            final canvasXMax = xMax * scaleX;
            final canvasYMax = yMax * scaleY;
            
            print('Direct canvas coords: [$canvasXMin, $canvasYMin, $canvasXMax, $canvasYMax]');
            
            _drawBoundingBox(canvas, canvasXMin, canvasYMin, canvasXMax, canvasYMax, color, '${foodItem.name} ${boxIndex + 1}');
          }
        }
      }
    }
    
    print('=== END DEBUG ===');
  }

  void _drawBoundingBox(Canvas canvas, double xMin, double yMin, double xMax, double yMax, Color color, String label) {
    // Validasi
    if (xMax <= xMin || yMax <= yMin) {
      print('Skipping invalid box: [$xMin, $yMin, $xMax, $yMax]');
      return;
    }

    final rect = Rect.fromLTRB(xMin, yMin, xMax, yMax);
    
    // Gambar outline putih tebal untuk kontras
    final outlinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, outlinePaint);
    
    // Gambar bounding box dengan warna
    final boxPaint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, boxPaint);
    
    // Gambar corner markers yang lebih besar
    final cornerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final cornerSize = 12.0;
    // Corner circles
    canvas.drawCircle(Offset(xMin, yMin), cornerSize / 2, cornerPaint);
    canvas.drawCircle(Offset(xMax, yMin), cornerSize / 2, cornerPaint);
    canvas.drawCircle(Offset(xMin, yMax), cornerSize / 2, cornerPaint);
    canvas.drawCircle(Offset(xMax, yMax), cornerSize / 2, cornerPaint);
    
    // Gambar label
    _drawLabel(canvas, label, Offset(xMin, yMin), color);
  }

  void _drawLabel(Canvas canvas, String text, Offset position, Color color) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black,
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final padding = 8.0;
    final labelRect = Rect.fromLTWH(
      position.dx,
      position.dy - textPainter.height - padding * 2,
      textPainter.width + padding * 2,
      textPainter.height + padding * 2,
    );

    // Background dengan outline
    final backgroundPaint = Paint()..color = color;
    final outlinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
      
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, Radius.circular(6)),
      backgroundPaint
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, Radius.circular(6)),
      outlinePaint
    );
    
    textPainter.paint(
      canvas,
      Offset(position.dx + padding, position.dy - textPainter.height - padding),
    );
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return image != oldDelegate.image || foodItems != oldDelegate.foodItems;
  }
}