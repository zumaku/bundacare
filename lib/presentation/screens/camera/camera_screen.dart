import 'dart:io';
import 'dart:ui';
import 'package:bundacare/presentation/bloc/food/food_bloc.dart';
import 'package:bundacare/presentation/screens/camera/detection_result_modal.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  FlashMode _flashMode = FlashMode.off;

  // --- 1. Variabel untuk mengelola Zoom ---
  double _currentZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  // Definisikan level zoom yang bisa dipilih
  final List<double> _zoomLevels = [1.0, 2.0, 3.0];
  int _currentZoomIndex = 0;


  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final firstCamera = cameras.first;
        _controller = CameraController(
          firstCamera,
          ResolutionPreset.high,
          enableAudio: false,
        );

        _initializeControllerFuture = _controller!.initialize().then((_) {
          _controller!.getMaxZoomLevel().then((value) => _maxZoomLevel = value);
        });
        if (mounted) {
          setState(() {});
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin kamera ditolak.')),
        );
      }
    }
  }

  Future<void> _onTakePicture() async {
    try {
      await _initializeControllerFuture;
      if (_controller == null || !_controller!.value.isInitialized) return;
      if (!mounted) return;

      final image = await _controller!.takePicture();
      
      if (!mounted) return;
      _processImage(File(image.path));
    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  Future<void> _onPickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (!mounted) return;
        _processImage(File(image.path));
      }
    } catch (e) {
      debugPrint("Error picking image from gallery: $e");
    }
  }

  void _processImage(File imageFile) {
    final foodBloc = context.read<FoodBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: foodBloc,
          child: DetectionResultModal(imageFile: imageFile),
        );
      },
    );
  }

  void _toggleFlash() {
    if (_controller != null) {
      setState(() {
        _flashMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
        _controller!.setFlashMode(_flashMode);
      });
    }
  }

  // --- 2. Fungsi baru untuk mengganti level Zoom ---
  void _cycleZoom() {
    // Pindah ke level zoom berikutnya
    _currentZoomIndex = (_currentZoomIndex + 1) % _zoomLevels.length;
    _currentZoomLevel = _zoomLevels[_currentZoomIndex];

    // Pastikan level zoom yang dipilih tidak melebihi batas maksimal kamera
    if (_currentZoomLevel > _maxZoomLevel) {
      _currentZoomIndex = 0;
      _currentZoomLevel = _zoomLevels[_currentZoomIndex];
    }

    setState(() {
      _controller!.setZoomLevel(_currentZoomLevel);
    });
  }


  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // WIDGET HELPER BARU UNTUK TOMBOL DENGAN EFEK BLUR
  Widget _buildCircularButton({required IconData icon, required VoidCallback onPressed}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50), // Membuat bentuknya melingkar sempurna
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Efek blur
        child: Container(
          width: 50,  // Lebar tetap
          height: 50, // Tinggi tetap
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3), // Background hitam transparan
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 24),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (_controller != null && _controller!.value.isInitialized) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(_controller!),
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/bounding_box.svg',
                      width: MediaQuery.of(context).size.width * 0.7,
                    ),
                  ),
                  _buildControlsOverlay(),
                ],
              );
            } else {
              return const Center(child: Text("Kamera tidak tersedia.", style: TextStyle(color: Colors.white)));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Kontrol Atas (Info & Flashlight)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCircularButton(
                icon: Iconsax.info_circle,
                onPressed: () {},
              ),
              _buildCircularButton(
                icon: _flashMode == FlashMode.torch ? Iconsax.flash_15 : Iconsax.flash_1,
                onPressed: _toggleFlash,
              ),
            ],
          ),
        ),
        
        // Kontrol Bawah (Galeri, Shutter, Zoom)
        Column(
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildCircularButton(
                    icon: Iconsax.gallery,
                    onPressed: _onPickImageFromGallery,
                  ),
                  GestureDetector(
                    onTap: _onTakePicture,
                    child: Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Center(
                        child: Container(
                          width: 58, height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _cycleZoom,
                    child: Container(
                      width: 50, // Samakan lebarnya agar simetris
                      height: 50, // Samakan tingginya agar simetris
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        '${_currentZoomLevel.toStringAsFixed(1)}x',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40)
          ],
        )
      ],
    );
  }
}