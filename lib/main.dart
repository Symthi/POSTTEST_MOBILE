import 'package:flutter/material.dart';
// Import package flutter_bloc untuk menggunakan Cubit dan BlocBuilder
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MusikStoreApp());
}

// --- MODEL DATA ---
class Product {
  final String id; // Menambahkan ID untuk mempermudah pencarian unik
  final String name;
  final int price;
  int stock;

  Product({required this.id, required this.name, required this.price, required this.stock});
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

// ============================================================================
// --- STATE MANAGEMENT (CUBIT / BLoC PATTERN) ---
// ============================================================================

// 1. STATE CLASS (Pengganti properti-properti di dalam ChangeNotifier)
// Menyimpan seluruh data global yang dibutuhkan aplikasi.
class CartState {
  final List<Product> products;
  final List<CartItem> cartItems;

  CartState({required this.products, required this.cartItems});

  // copyWith: Konsep penting di Cubit. Karena state bersifat immutable (tidak bisa diubah langsung),
  // kita membuat duplikat state lama dengan data baru.
  CartState copyWith({List<Product>? products, List<CartItem>? cartItems}) {
    return CartState(
      products: products ?? this.products,
      cartItems: cartItems ?? this.cartItems,
    );
  }

  // Getter untuk total harga, sama seperti di modul Provider.
  int get grandTotal {
    return cartItems.fold(0, (total, item) => total + (item.product.price * item.quantity));
  }
}

// 2. CUBIT CLASS (Pengganti ChangeNotifier / CartProvider)
// Menangani semua fungsi logika bisnis (tambah keranjang, ubah jumlah).
class CartCubit extends Cubit<CartState> {
  // Constructor: Menetapkan state awal saat aplikasi pertama kali dijalankan.
  CartCubit() : super(CartState(
    products: [
      Product(id: 'p1', name: 'Gitar Elektrik - Garasi Gitar 3', price: 4500000, stock: 5),
      Product(id: 'p2', name: 'Keyboard Synthesizer - Borneo Cantata', price: 8200000, stock: 2),
      Product(id: 'p3', name: 'Set Drum Akustik', price: 12000000, stock: 0),
    ],
    cartItems: [],
  ));

  void addToCart(Product product) {
    if (product.stock <= 0) return;

    // Menduplikasi list agar Cubit dapat mendeteksi adanya perubahan referensi data.
    final newProducts = List<Product>.from(state.products);
    final newCartItems = List<CartItem>.from(state.cartItems);

    // Kurangi stok produk
    final productIndex = newProducts.indexWhere((p) => p.id == product.id);
    if (productIndex >= 0) newProducts[productIndex].stock--;

    // Tambahkan atau perbarui keranjang
    final cartIndex = newCartItems.indexWhere((item) => item.product.id == product.id);
    if (cartIndex >= 0) {
      newCartItems[cartIndex].quantity++;
    } else {
      // Perhatikan kita membuat referensi produk baru agar sinkron dengan state baru
      newCartItems.add(CartItem(product: newProducts[productIndex], quantity: 1));
    }

    // emit() adalah konsep Cubit yang berfungsi SAMA seperti notifyListeners() pada Provider.
    // Memberitahu UI (BlocBuilder) untuk merender ulang dengan State yang baru.
    emit(state.copyWith(products: newProducts, cartItems: newCartItems));
  }

  void changeQuantity(Product product, int newQuantity) {
    final newProducts = List<Product>.from(state.products);
    final newCartItems = List<CartItem>.from(state.cartItems);

    final cartIndex = newCartItems.indexWhere((item) => item.product.id == product.id);
    if (cartIndex == -1) return;

    final currentItem = newCartItems[cartIndex];
    int difference = newQuantity - currentItem.quantity;

    // Sesuaikan stok di list produk
    final productIndex = newProducts.indexWhere((p) => p.id == product.id);
    if (productIndex >= 0) newProducts[productIndex].stock -= difference;

    // Perbarui kuantitas
    currentItem.quantity = newQuantity;

    // Beritahu UI ada perubahan data
    emit(state.copyWith(products: newProducts, cartItems: newCartItems));
  }
}
// ============================================================================

class MusikStoreApp extends StatelessWidget {
  const MusikStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocProvider fungsinya persis sama dengan ChangeNotifierProvider.
    // Digunakan untuk "menyuntikkan" CartCubit agar bisa diakses oleh seluruh widget di bawahnya.
    return BlocProvider(
      create: (context) => CartCubit(),
      child: MaterialApp(
        title: 'Musik Store',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          fontFamily: 'Inter',
        ),
        home: const MainScreen(),
      ),
    );
  }
}

// MainScreen tetap menjadi StatefulWidget karena state index navigasi (bottom navbar)
// bersifat LOKAL dan hanya digunakan di halaman ini. Ini sesuai dengan anjuran modul.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tidak perlu lagi mengoper data (prop drilling) melalui constructor ke halaman anak!
    final List<Widget> pages = [
      const HomeContent(),
      const CartPage(),
      const Center(child: Text('Halaman Profil')),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Keranjang'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// HomeContent tetap StatefulWidget LOKAL karena ada fitur "searchQuery"
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Cari Instrumen...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(Icons.search, size: 24, color: Colors.grey.shade400),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              const SizedBox(height: 24),

              // BlocBuilder fungsinya SAMA seperti Consumer pada Provider.
              // Ia mendengarkan emit() dari Cubit dan akan membangun ulang (rebuild) bagian UI ini.
              BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  // Mengambil data products dari state global yang ada di Cubit
                  final visibleProducts = state.products.where((product) {
                    return product.name.toLowerCase().contains(searchQuery.toLowerCase());
                  }).toList();

                  if (visibleProducts.isEmpty) {
                    return const Center(child: Text("Tidak ada produk tersedia."));
                  }

                  return Column(
                    children: visibleProducts.map((product) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildProductCard(context, product),
                    )).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Rp${product.price}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Sisa stok: ${product.stock}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),

                InkWell(
                  onTap: product.stock > 0 ? () {
                    // context.read<CartCubit>() fungsinya persis seperti context.read<CartProvider>().
                    // Memanggil fungsi tanpa perlu mendengarkan perubahannya (tanpa me-rebuild dirinya sendiri).
                    context.read<CartCubit>().addToCart(product);
                  } : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: product.stock > 0 ? Colors.black : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text('Masukkan Keranjang', style: TextStyle(color: Colors.white, fontSize: 12)),
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

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Menggunakan BlocBuilder untuk merender daftar keranjang dan total harga.
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          return Stack(
            children: [
              Positioned(
                top: 0, left: 0, right: 0, bottom: 80,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: state.cartItems.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: CartProductCard(item: item),
                      )).toList(),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade300, blurRadius: 10, offset: const Offset(0, -3)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total', style: TextStyle(fontSize: 14)),
                          Text(
                            // Memanggil getter grandTotal dari CartState
                            'Rp${state.grandTotal}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: state.grandTotal > 0 ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Berhasil Checkout!')),
                          );
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Checkout', style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// CartProductCard masih butuh StatefulWidget untuk mengelola TextField TextEditingController secara lokal.
class CartProductCard extends StatefulWidget {
  final CartItem item;

  const CartProductCard({super.key, required this.item});

  @override
  State<CartProductCard> createState() => _CartProductCardState();
}

class _CartProductCardState extends State<CartProductCard> {
  late TextEditingController quantityController;

  @override
  void initState() {
    super.initState();
    quantityController = TextEditingController(text: '${widget.item.quantity}');
  }

  @override
  void didUpdateWidget(covariant CartProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.quantity != widget.item.quantity &&
        quantityController.text != '${widget.item.quantity}') {
      quantityController.text = '${widget.item.quantity}';
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  void updateQuantity(String value) {
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 1) {
      quantityController.text = '${widget.item.quantity}';
      return;
    }

    // Mendapatkan sisa stok saat ini dari Cubit state untuk divalidasi
    final globalProducts = context.read<CartCubit>().state.products;
    final originalProduct = globalProducts.firstWhere((p) => p.id == widget.item.product.id);

    int maxQuantity = widget.item.quantity + originalProduct.stock;
    int finalQuantity = parsed.clamp(1, maxQuantity);

    // Memanggil fungsi dari Cubit menggunakan context.read()
    context.read<CartCubit>().changeQuantity(widget.item.product, finalQuantity);
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
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.music_note, color: Colors.grey),
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
          SizedBox(
            width: 50,
            child: TextField(
              controller: quantityController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              onSubmitted: updateQuantity,
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