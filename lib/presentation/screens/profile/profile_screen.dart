import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bundacare/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // <-- Pastikan import ini ada

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Pindahkan _selectDate ke dalam kelas agar bisa mengakses context
  Future<void> _selectDate(BuildContext context) async {
    // Ambil tanggal yang sudah ada untuk nilai awal picker
    final authState = context.read<AuthBloc>().state;
    DateTime initialDate = DateTime.now();
    if (authState is Authenticated && authState.profile?.pregnancyStartDate != null) {
      initialDate = authState.profile!.pregnancyStartDate!;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(DateTime.now().year - 2), // 2 tahun ke belakang
      lastDate: DateTime.now(),
    );
    if (picked != null && context.mounted) {
      context.read<AuthBloc>().add(AuthPregnancyStartDateUpdated(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan BlocBuilder agar UI otomatis update saat state berubah
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Siapkan data default
        String fullName = 'Nama Pengguna';
        String avatarUrl = '';
        DateTime? pregnancyStartDate;

        // Jika state-nya Authenticated, ambil data dari profil
        if (state is Authenticated && state.profile != null) {
          fullName = state.profile!.fullName;
          avatarUrl = state.profile!.avatarUrl;
          pregnancyStartDate = state.profile!.pregnancyStartDate;
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. App Bar Kustom
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      'assets/logo/app_bar_logo.svg', // Pastikan path ini benar
                      height: 35,
                      colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.notification, size: 28),
                      onPressed: () => context.push('/notifications'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 2. Info Profil
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: (avatarUrl.isNotEmpty)
                          ? Image.network(
                              avatarUrl,
                              width: 80, height: 80, fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                            )
                          : _buildPlaceholderImage(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bunda",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade400),
                          ),
                          Text(
                            fullName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // 3. Menu Tambahan
                const Text(
                  "Menu Lain",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                _buildMenuTile(
                  icon: Iconsax.calendar_1,
                  title: "Awal Kehamilan",
                  subtitle: pregnancyStartDate != null
                      ? DateFormat('dd MMMM yyyy', 'id_ID').format(pregnancyStartDate)
                      : "Setel Tanggal",
                  onTap: () => _selectDate(context),
                ),
                const Divider(color: Colors.white12, height: 1),
                _buildMenuTile(
                  icon: Iconsax.document_text,
                  title: "Riwayat Penyakit",
                  subtitle: null, // Beri nilai null jika tidak ada subtitle
                  onTap: () {},
                ),
                const Divider(color: Colors.white12, height: 1),
                _buildMenuTile(
                  icon: Iconsax.message_question,
                  title: "FAQs",
                  subtitle: null,
                  onTap: () {},
                ),
                const Divider(color: Colors.white12, height: 1),
                _buildMenuTile(
                  icon: Iconsax.info_circle,
                  title: "Tentang BundaCare",
                  subtitle: null,
                  onTap: () {},
                ),
                const SizedBox(height: 40),

                // 4. Tombol Logout
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthSignOutRequested());
                    },
                    child: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  // Placeholder untuk gambar profil jika error atau kosong
  Widget _buildPlaceholderImage() {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Iconsax.user, size: 40, color: Colors.grey),
    );
  }

  // Widget helper untuk membuat baris menu (sudah diperbarui)
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String? subtitle, // Ubah menjadi nullable
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.grey.shade400),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey.shade500)) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}