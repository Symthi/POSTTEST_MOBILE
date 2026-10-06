import 'package:flutter/material.dart';

void main() {
  runApp(const MusikStoreApp());
}

// --- MODEL DATA ---
// Class Product digunakan sebagai cetak biru (blueprint) data produk.
class Product {
  final String name;
  final int price;
  int stock; // stock tidak final karena nilainya akan berubah (berkurang) saat dimasukkan keranjang.

  Product({required this.name, required this.price, required this.stock});
}

// Class CartItem digunakan untuk menyimpan produk apa saja yang ada di keranjang beserta jumlahnya.
class CartItem {
  final Product product;
  int quantity; // quantity bisa berubah sesuai input pengguna.

  CartItem({required this.product, this.quantity = 1});
}
// ------------------

// StatelessWidget digunakan di sini karena konfigurasi awal aplikasi (tema, judul) bersifat statis/tetap.
class MusikStoreApp extends StatelessWidget {
  const MusikStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp adalah widget wrapper utama dari aplikasi Flutter.
    return MaterialApp(
      title: 'Musik Store',
      debugShowCheckedModeBanner: false, // Menyembunyikan pita debug di pojok kanan atas.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        fontFamily: 'Inter',
      ),
      // home menentukan halaman pertama yang dimuat.
      home: const MainScreen(),
    );
  }
}

// Menggunakan StatefulWidget karena MainScreen harus mengelola state navigasi (Tab mana yang aktif),
// serta menyimpan data keranjang belanja dan sisa stok produk.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // State: Variabel untuk menyimpan index tab navigasi bawah yang sedang aktif.
  int _selectedIndex = 0;

  // State: Daftar produk statis yang tersedia di aplikasi beserta stok awalnya.
  final List<Product> _products = [
    Product(name: 'Gitar Elektrik - Garasi Gitar 3', price: 4500000, stock: 5),
    Product(name: 'Keyboard Synthesizer - Borneo Cantata', price: 8200000, stock: 2),
    Product(name: 'Set Drum Akustik', price: 12000000, stock: 0), // Sengaja diset 0 untuk melihat efek tombol mati (disabled).
  ];

  // State: List kosong yang nantinya akan menampung item yang dimasukkan ke keranjang.
  final List<CartItem> _cart = [];

  // Fungsi untuk memindahkan halaman melalui Bottom Navigation.
  void _onItemTapped(int index) {
    // setState WAJIB dipanggil setiap kali kita ingin mengubah tampilan berdasarkan data yang baru.
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fungsi untuk menambah produk ke keranjang.
  void _addToCart(Product product) {
    setState(() {
      // Mengecek apakah produk yang ditekan sudah ada di keranjang.
      final existingIndex = _cart.indexWhere((item) => item.product.name == product.name);

      if (existingIndex >= 0) {
        // Jika sudah ada, tambahkan saja kuantitasnya (jumlahnya).
        _cart[existingIndex].quantity += 1;
      } else {
        // Jika belum ada, buat item baru di keranjang.
        _cart.add(CartItem(product: product));
      }
      // Kurangi stok produk asli sebesar 1 setiap kali tombol ditekan.
      product.stock -= 1;
    });
  }

  // Fungsi untuk mengubah jumlah barang langsung dari halaman keranjang (Text input).
  void _changeQuantity(CartItem item, int newQuantity) {
    setState(() {
      // Hitung selisih angka baru dengan angka lama.
      int difference = newQuantity - item.quantity;
      // Kurangi stok produk berdasarkan selisih (bisa bertambah atau berkurang).
      item.product.stock -= difference;
      // Perbarui nilai kuantitas di keranjang.
      item.quantity = newQuantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Daftar halaman yang akan ditampilkan sesuai nilai _selectedIndex.
    final List<Widget> pages = [
      HomeContent(
        products: _products, // Mengirim data produk ke halaman beranda
        onAddToCart: _addToCart, // Mengirim fungsi tambah keranjang ke halaman beranda
      ),
      CartPage(
        cartItems: _cart, // Mengirim data isi keranjang
        onChangeQuantity: _changeQuantity, // Mengirim fungsi ubah jumlah ke halaman keranjang
      ),
      const Center(child: Text('Halaman Profil')), // Center digunakan untuk memosisikan widget di tengah.
    ];

    // Scaffold menyediakan struktur dasar (kanvas) untuk halaman aplikasi.
    return Scaffold(
      backgroundColor: Colors.white,
      // body menampilkan widget dari list pages.
      body: pages[_selectedIndex],
      // bottomNavigationBar digunakan untuk membuat menu navigasi di bagian bawah.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Indikator menu mana yang menyala/aktif.
        onTap: _onItemTapped, // Menjalankan fungsi perpindahan tab.
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Keranjang'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// --- HALAMAN BERANDA ---
// Menjadi StatefulWidget karena kita perlu menyimpan teks pencarian pengguna secara realtime.
class HomeContent extends StatefulWidget {
  final List<Product> products;
  final Function(Product) onAddToCart;

  const HomeContent({
    super.key,
    required this.products,
    required this.onAddToCart,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // State: Variabel untuk menyimpan apa yang diketik pengguna di kolom pencarian.
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Memfilter data: Hanya menampilkan produk yang namanya mengandung teks pencarian.
    final visibleProducts = widget.products.where((product) {
      return product.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    // SafeArea mencegah UI tertutup oleh poni layar (notch) atau status bar HP.
    return SafeArea(
      // SingleChildScrollView agar layar bisa di-scroll ke bawah jika isi produk banyak.
      child: SingleChildScrollView(
        // Padding memberikan jarak/ruang kosong di sekeliling konten.
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          // Column menyusun widget dari atas ke bawah.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TextField adalah kolom input untuk user mengetik teks.
              TextField(
                // onChanged dipanggil setiap kali ada huruf baru yang diketik.
                // Disinilah kita menggunakan setState() untuk memperbarui searchQuery.
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Cari Instrumen...', // Teks bayangan saat kosong.
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(Icons.search, size: 24, color: Colors.grey.shade400),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              const SizedBox(height: 24), // SizedBox sebagai spasi vertikal.

              // Looping (mengulang) pembuatan kartu produk sesuai dengan daftar produk yang sudah difilter.
              ...visibleProducts.map((product) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildProductCard(product),
              )),

              // Menampilkan pesan teks jika tidak ada produk yang sesuai dengan pencarian.
              if (visibleProducts.isEmpty)
                const Center(child: Text("Tidak ada produk tersedia.")),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi pembuat desain masing-masing kartu produk.
  Widget _buildProductCard(Product product) {
    // Container sering digunakan sebagai bungkus/kotak luar dengan dekorasi.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300), // Garis pinggir abu-abu.
        borderRadius: BorderRadius.circular(8), // Membuat sudut tumpul.
      ),
      // Row menyusun widget secara menyamping (Kiri ke Kanan).
      child: Row(
        children: [
          // Container abu-abu ini adalah placeholder (tempat sementara) untuk gambar produk.
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),
          // Expanded memaksa teks dan tombol untuk mengisi seluruh sisa ruang di sebelah kanan gambar.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp${product.price}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text('Sisa stok: ${product.stock}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),

                // InkWell memberikan efek sentuhan (ripple) ketika diklik.
                // Jika stok > 0, onTap diisi fungsi onAddToCart. Jika stok <= 0, onTap diisi null (tombol mati).
                InkWell(
                  onTap: product.stock > 0 ? () => widget.onAddToCart(product) : null,
                  child: Container(
                    width: double.infinity, // Memenuhi lebar penuh.
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      // Warna tombol berubah jadi abu-abu jika stok habis.
                      color: product.stock > 0 ? Colors.black : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        'Masukkan Keranjang',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
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

// --- HALAMAN KERANJANG ---
class CartPage extends StatelessWidget {
  final List<CartItem> cartItems;
  final Function(CartItem, int) onChangeQuantity;

  const CartPage({
    super.key,
    required this.cartItems,
    required this.onChangeQuantity,
  });

  @override
  Widget build(BuildContext context) {
    // Menghitung total harga belanjaan (State turunan).
    int currentGrandTotal = 0;
    for (var item in cartItems) {
      currentGrandTotal += (item.product.price * item.quantity);
    }

    return SafeArea(
      // Stack menumpuk widget seperti lapisan kue (Layering).
      // Widget yang ditulis lebih dulu akan berada di belakang.
      child: Stack(
        children: [
          // Positioned digunakan di dalam Stack untuk menentukan koordinat pasti widget tersebut.
          // Ini adalah layer belakang (Daftar barang).
          Positioned(
            top: 0, left: 0, right: 0, bottom: 80, // bottom 80 agar tidak tertutup kotak total checkout.
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: cartItems.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: CartProductCard(
                      item: item,
                      onQuantityChanged: (newQuantity) {
                        onChangeQuantity(item, newQuantity);
                      },
                    ),
                  )).toList(),
                ),
              ),
            ),
          ),

          // Layer Depan/Bawah (Kotak Hitung Total dan Checkout) yang menutupi list.
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                // BoxShadow memberikan efek bayangan sehingga kontainer ini terlihat melayang di atas konten.
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10, offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Memisah Total ke kiri dan Tombol ke kanan.
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 14)),
                      Text(
                        'Rp$currentGrandTotal',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // ElevatedButton adalah tombol bawaan Flutter dengan gaya timbul.
                  ElevatedButton(
                    // Tombol ini hanya akan aktif jika total belanja > 0.
                    // Jika total 0 (keranjang kosong), nilainya null sehingga tombol otomatis disabled.
                    onPressed: currentGrandTotal > 0 ? () {
                      // Menampilkan pop-up notifikasi (SnackBar) saat checkout ditekan.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Berhasil Checkout!')),
                      );
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey, // Warna saat nilai onPressed adalah null.
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
}

// --- KARTU PRODUK DI DALAM KERANJANG ---
// Menjadi StatefulWidget karena TextField butuh TextEditingController untuk mengontrol angka di dalamnya.
class CartProductCard extends StatefulWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;

  const CartProductCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
  });

  @override
  State<CartProductCard> createState() => _CartProductCardState();
}

class _CartProductCardState extends State<CartProductCard> {
  // TextEditingController bertugas mengatur, membaca, dan mengubah teks di dalam TextField.
  late TextEditingController quantityController;

  // initState dipanggil SATU KALI saat widget ini pertama kali diciptakan di layar.
  @override
  void initState() {
    super.initState();
    // Mengisi nilai awal TextField dengan jumlah/kuantitas dari keranjang.
    quantityController = TextEditingController(text: '${widget.item.quantity}');
  }

  // didUpdateWidget dipanggil setiap kali widget induk (CartPage) mengirim data 'item' yang baru.
  @override
  void didUpdateWidget(covariant CartProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika jumlah di memori berbeda dengan yang tertulis di TextField, perbarui isi TextField.
    if (oldWidget.item.quantity != widget.item.quantity &&
        quantityController.text != '${widget.item.quantity}') {
      quantityController.text = '${widget.item.quantity}';
    }
  }

  // dispose dipanggil saat widget ini dihancurkan (misal keluar dari halaman) untuk mencegah kebocoran memori.
  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  // Fungsi validasi saat user mengetik kuantitas secara manual (misal diketik angka 10).
  void updateQuantity(String value) {
    // int.tryParse mencoba mengubah string menjadi integer (angka). Jika gagal (misal user mengetik huruf), hasilnya null.
    final parsed = int.tryParse(value);

    // Jika user menginput bukan angka atau angka kurang dari 1, kita batalkan perubahannya.
    if (parsed == null || parsed < 1) {
      quantityController.text = '${widget.item.quantity}'; // Kembalikan ke angka semula.
      return;
    }

    // Menghitung batas maksimum yang bisa dibeli user (stok yang sudah di keranjang + stok asli toko).
    int maxQuantity = widget.item.quantity + widget.item.product.stock;

    // clamp memastikan angka akhir tidak kurang dari 1 dan tidak melebihi stok yang ada.
    int finalQuantity = parsed.clamp(1, maxQuantity);

    // Memberitahu fungsi di MainScreen bahwa kuantitas berubah.
    widget.onQuantityChanged(finalQuantity);
    // Mengubah tampilan teks pada TextField dengan angka yang sudah divalidasi.
    quantityController.text = '$finalQuantity';
  }

  @override
  Widget build(BuildContext context) {
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
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.music_note, color: Colors.grey), // Icon bawaan Flutter.
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Rp${widget.item.product.price}', style: const TextStyle(color: Colors.black54, fontSize: 14)),
              ],
            ),
          ),
          // Membatasi ukuran lebar kotak TextField agar tidak terlalu panjang.
          SizedBox(
            width: 50,
            child: TextField(
              controller: quantityController, // Mengikat controller yang dibuat di atas.
              textAlign: TextAlign.center, // Posisi teks di tengah.
              keyboardType: TextInputType.number, // Menampilkan keyboard khusus angka di HP.
              onSubmitted: updateQuantity, // Dijalankan saat user memencet 'Enter' / 'Done' di keyboard.
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}