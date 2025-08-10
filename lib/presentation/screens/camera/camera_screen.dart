import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // 1. Minta izin kamera
    var status = await Permission.camera.request();
    if (status.isGranted) {
      // 2. Dapatkan daftar kamera yang tersedia
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final firstCamera = cameras.first;
        
        // 3. Buat dan inisialisasi CameraController
        _controller = CameraController(
          firstCamera,
          ResolutionPreset.high,
          enableAudio: false, // Kita tidak butuh audio
        );

        setState(() {
          _initializeControllerFuture = _controller!.initialize();
        });
      }
    } else {
      // Handle jika izin ditolak
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin kamera ditolak. Fitur tidak dapat digunakan.')),
      );
    }
  }

  void _onTakePicture() async {
    try {
      // Pastikan controller sudah diinisialisasi
      await _initializeControllerFuture;
      if (_controller == null || !_controller!.value.isInitialized) {
        return;
      }
      
      // Ambil gambar
      final image = await _controller!.takePicture();
      
      // Setelah gambar diambil, kita akan proses ke tahap selanjutnya
      _processImage(File(image.path));

    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  void _processImage(File imageFile) {
    // TODO (Tahap Berikutnya): 
    // 1. Tampilkan Modal Bottom Sheet
    // 2. Panggil DetectionBloc untuk memulai proses unggah & deteksi
    // 3. Tampilkan hasil di modal

    // Untuk sekarang, kita tampilkan dialog sederhana untuk konfirmasi
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text("Gambar Dipilih"),
        content: Image.file(imageFile),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("OK"))
        ],
      )
    );
  }

  @override
  void dispose() {
    // Penting: Buang controller saat widget tidak digunakan
    _controller?.dispose();
    super.dispose();
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
              // Jika controller siap, tampilkan pratinjau kamera dan tombol
              return Stack(
                children: [
                  Positioned.fill(
                    child: CameraPreview(_controller!),
                  ),
                  _buildControls(), // UI untuk tombol-tombol
                ],
              );
            } else {
              // Jika tidak ada kamera atau izin ditolak
              return const Center(child: Text("Kamera tidak tersedia atau izin ditolak.", style: TextStyle(color: Colors.white)));
            }
          } else {
            // Selama menunggu, tampilkan loading indicator
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  // Widget untuk UI kontrol kamera
  Widget _buildControls() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 150,
        color: Colors.black.withOpacity(0.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Tombol Galeri
            IconButton(
              onPressed: () {
                // TODO: Implementasi image_picker untuk galeri
              },
              icon: const Icon(Icons.photo_library, color: Colors.white, size: 30),
            ),
            // Tombol Ambil Gambar
            GestureDetector(
              onTap: _onTakePicture,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.pink, width: 4),
                ),
              ),
            ),
            // Tombol Flashlight
            IconButton(
              onPressed: () {
                // TODO: Implementasi flashlight
              },
              icon: const Icon(Icons.flash_on, color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}