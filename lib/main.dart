import 'package:flutter/material.dart';

void main() {
  runApp(const MusikStoreApp());
}

class MusikStoreApp extends StatelessWidget {
  const MusikStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp adalah widget wrapper utama dari aplikasi yang dibangun menggunakan Flutter.
    return MaterialApp(
      title: 'Musik Store', // title diisi dengan string untuk nama aplikasi.
      debugShowCheckedModeBanner: false, // Digunakan untuk menonaktifkan tulisan debug di pojok kanan atas.
      theme: ThemeData(
        // theme untuk menentukan aturan visual umum aplikasi.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        fontFamily: 'Inter',
      ),
      home: const HomePage(), // home menentukan halaman utama yang ditampilkan
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur dasar halaman aplikasi Mobile.
    return Scaffold(
      backgroundColor: Colors.white, // backgroundColor mengatur warna latar yang biasanya mengikuti tema.

      // SafeArea berfungsi untuk memastikan child-nya tidak tertutup oleh area perangkat.
      body: SafeArea(
        // SingleChildScrollView fungsinya agar halaman bisa di-scrolling jika konten melebihi layar.
        child: SingleChildScrollView(
          // Padding berfungsi untuk memberi ruang antar child.
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            // Column digunakan untuk menyusun widget secara vertikal (sumbu utamanya vertikal).
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // TextField merupakan widget untuk input text.
                TextField(
                  // Menggunakan properti decoration dengan InputDecoration.
                  decoration: InputDecoration(
                    hintText: 'Cari Instrumen...', // hintText menampilkan placeholder dari input.
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    // suffixIcon menampilkan icon di ujung kanan sebuah TextField.
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      // Icon digunakan untuk menampilkan icon, propertinya meliputi Icons, size, dan color.
                      child: Icon(
                        Icons.search,
                        size: 24,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),

                // SizedBox difungsikan untuk memberikan jarak vertikal dengan menggunakan height.
                const SizedBox(height: 24),

                // Menampilkan daftar produk
                _buildProductCard('Gitar Elektrik - Garasi Gitar 3', 'Rp4.500.000'),
                const SizedBox(height: 16),
                _buildProductCard('Keyboard Synthesizer - Borneo Cantata', 'Rp8.200.000'),
                const SizedBox(height: 16),
                _buildProductCard('Set Drum Akustik', 'Rp12.000.000'),
              ],
            ),
          ),
        ),
      ),

      // bottomNavigationBar adalah widget di bawah yang fungsinya sebagai navigasi.
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // Fungsi pembantu untuk membuat desain Card Produk yang berulang
  Widget _buildProductCard(String title, String price) {
    // Container difungsikan untuk membungkus widget dan sering digunakan untuk membuat card.
    return Container(
      padding: const EdgeInsets.all(16), // Container dapat mengatur padding di dalamnya.
      // BoxDecoration digunakan untuk mengatur warna background, bingkai (border), dan kelengkungan (borderRadius).
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      // Row digunakan untuk menyusun widget secara horizontal.
      child: Row(
        children: [
          // Container ini digunakan sebagai placeholder gambar produk
          Container(
            width: 80, // Menggunakan width untuk mengatur lebar.
            height: 80, // Menggunakan height untuk mengatur tinggi.
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          // SizedBox difungsikan memberikan jarak horizontal menggunakan width.
          const SizedBox(width: 16),

          // Expanded berfungsi untuk memaksa widget anak (child) untuk mengisi sisa ruang yang tersedia di dalam tata letak Row.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text digunakan karena aplikasi memuat teks.
                Text(
                  title,
                  // style dengan properti TextStyle digunakan untuk mengatur gaya seperti fontSize dan fontWeight.
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                // Tombol "Masukkan Keranjang"
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      'Masukkan Keranjang',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}