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
      // home menentukan halaman utama yang ditampilkan, diubah ke MainScreen untuk navigasi.
      home: const MainScreen(),
    );
  }
}

// Menggunakan StatefulWidget agar bisa mengelola state dari Navigation bar.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Variabel state untuk menyimpan index halaman yang sedang aktif di Navigation bar.
  int _selectedIndex = 0;

  // Daftar halaman (widget) yang akan ditampilkan berdasarkan index Navigation bar.
  final List<Widget> _pages = [
    const HomeContent(), // Index 0: Beranda
    const CartPage(),    // Index 1: Keranjang (Halaman baru)
    const Center(
      // Center digunakan untuk memosisikan widget di tengah layar.
      child: Text('Halaman Profil'), // Text digunakan untuk menampilkan string teks.
    ),                   // Index 2: Profil
  ];

  // Fungsi pembantu untuk mengubah halaman saat item navigasi ditekan.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur dasar halaman aplikasi Mobile.
    return Scaffold(
      backgroundColor: Colors.white, // backgroundColor mengatur warna latar.

      // body menampilkan widget dari list _pages berdasarkan index yang dipilih.
      body: _pages[_selectedIndex],

      // bottomNavigationBar adalah widget di bawah yang fungsinya sebagai navigasi.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Menandai item mana yang sedang aktif.
        onTap: _onItemTapped, // Menjalankan fungsi perubahan index saat item ditekan.
        // items berisi daftar menu pada navigasi bawah.
        items: const [
          BottomNavigationBarItem(
            // Icon digunakan untuk menampilkan ikon visual.
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
}

// Widget untuk isi Halaman Beranda (sebelumnya bernama HomePage di kode awal).
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    // SafeArea berfungsi untuk memastikan child-nya tidak tertutup oleh area sistem perangkat.
    return SafeArea(
      // SingleChildScrollView fungsinya agar halaman bisa di-scrolling jika konten melebihi layar.
      child: SingleChildScrollView(
        // Padding berfungsi untuk memberi ruang antar child dengan batas luar.
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          // Column digunakan untuk menyusun widget secara vertikal.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // children menampung kumpulan widget di dalam Column.
            children: [
              // TextField merupakan widget untuk input text dari pengguna.
              TextField(
                // Menggunakan properti decoration dengan InputDecoration untuk mempercantik input.
                decoration: InputDecoration(
                  hintText: 'Cari Instrumen...', // hintText menampilkan placeholder dari input.
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  // suffixIcon menampilkan icon di ujung kanan sebuah TextField.
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.search,
                      size: 24,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  // OutlineInputBorder memberikan garis batas di sekeliling TextField.
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),

              // SizedBox difungsikan untuk memberikan jarak vertikal dengan menggunakan height.
              const SizedBox(height: 24),

              // Memanggil fungsi _buildProductCard untuk menampilkan daftar produk.
              _buildProductCard('Gitar Elektrik - Garasi Gitar 3', 'Rp4.500.000'),
              const SizedBox(height: 16),
              _buildProductCard('Keyboard Synthesizer - Borneo Cantata', 'Rp8.200.000'),
              const SizedBox(height: 16),
              _buildProductCard('Set Drum Akustik', 'Rp12.000.000'),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi pembantu untuk membuat desain Card Produk yang berulang.
  Widget _buildProductCard(String title, String price) {
    // Container difungsikan untuk membungkus widget dan sering digunakan untuk membuat card.
    return Container(
      padding: const EdgeInsets.all(16), // Mengatur jarak dalam Container.
      // BoxDecoration digunakan untuk mengatur warna background, bingkai (border), dan kelengkungan (borderRadius).
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      // Row digunakan untuk menyusun widget secara horizontal (gambar ke teks).
      child: Row(
        children: [
          // Container ini digunakan sebagai placeholder gambar produk.
          // (Dapat diganti dengan Image.asset jika gambar tersedia).
          Container(
            width: 80, // Menggunakan width untuk mengatur lebar.
            height: 80, // Menggunakan height untuk mengatur tinggi.
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          // SizedBox difungsikan memberikan jarak horizontal antar elemen.
          const SizedBox(width: 16),

          // Expanded berfungsi untuk memaksa widget anak mengisi sisa ruang horizontal yang ada.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text digunakan karena aplikasi memuat teks untuk judul.
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

                // Tombol "Masukkan Keranjang" buatan manual dengan Container.
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

// Halaman CartPage yang ditambahkan untuk Navigation Bar.
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Stack digunakan untuk menumpuk beberapa widget pada area yang sama.
      // Sangat cocok untuk membuat area total/checkout yang melayang di bawah.
      child: Stack(
        children: [
          // Widget pertama pada Stack (Berada di lapisan belakang).
          // Positioned mengatur posisi widget di dalam Stack.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 80, // Memberi jarak agar konten tidak tertutup oleh area bawah (checkout).
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildCartItem('Gitar Elektrik - Garasi Gitar 3', 'Rp4.500.000'),
                    const SizedBox(height: 16),
                    _buildCartItem('Keyboard Synthesizer - Borneo Cantata', 'Rp8.200.000'),
                  ],
                ),
              ),
            ),
          ),

          // Widget kedua pada Stack (Berada di lapisan terdepan / di atas).
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                // BoxShadow digunakan untuk memberikan bayangan (shadow) pada widget.
                // Ini memberikan ilusi kedalaman sehingga terlihat seperti melayang di atas konten scroll.
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10, // Mengatur tingkat kekaburan bayangan.
                    offset: const Offset(0, -3), // Menentukan arah dan posisi bayangan ke atas.
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total', style: TextStyle(fontSize: 14)),
                      Text(
                        'Rp12.700.000',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // ElevatedButton adalah widget tombol bawaan Material dengan gaya timbul.
                  ElevatedButton(
                    onPressed: () {
                      // Kosongkan atau isi dengan Navigator.push() jika ada halaman konfirmasi.
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Checkout', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi pembuat item di keranjang.
  Widget _buildCartItem(String title, String price) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.music_note, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(price, style: const TextStyle(color: Colors.black54, fontSize: 14)),
              ],
            ),
          ),
          // Membatasi ukuran TextField agar tidak memenuhi layar.
          SizedBox(
            width: 50,
            child: TextField(
              textAlign: TextAlign.center,
              // keyboardType mengatur input agar user hanya dapat memasukkan data angka.
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '1',
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}