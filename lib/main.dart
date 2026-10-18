import 'package:flutter/material.dart';

void main() {
  runApp(const ShopApp());
}

// ============================================================
// DỮ LIỆU SẢN PHẨM
// ============================================================

class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final double oldPrice;
  final String image;
  final String description;
  final double rating;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.oldPrice,
    required this.image,
    required this.description,
    required this.rating,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });
}

// ============================================================
// DỮ LIỆU MẪU
// ============================================================

final List<Product> products = [
  const Product(
    id: 1,
    name: 'iPhone 16 Pro Max',
    category: 'Điện thoại',
    price: 29990000,
    oldPrice: 32990000,
    image:
    'https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=800',
    description:
    'iPhone 16 Pro Max với thiết kế cao cấp, hiệu năng mạnh mẽ, camera chuyên nghiệp và màn hình Super Retina XDR.',
    rating: 4.9,
  ),
  const Product(
    id: 2,
    name: 'MacBook Pro M4',
    category: 'Laptop',
    price: 38990000,
    oldPrice: 41990000,
    image:
    'https://images.unsplash.com/photo-1517336714739-489689fd1ca8?w=800',
    description:
    'MacBook Pro sử dụng chip Apple M4, hiệu năng cao, thiết kế mỏng nhẹ, phù hợp học tập và công việc.',
    rating: 4.8,
  ),
  const Product(
    id: 3,
    name: 'AirPods Pro 2',
    category: 'Phụ kiện',
    price: 5490000,
    oldPrice: 6490000,
    image:
    'https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?w=800',
    description:
    'Tai nghe AirPods Pro 2 với chống ồn chủ động, âm thanh chất lượng cao và thiết kế tiện lợi.',
    rating: 4.7,
  ),
  const Product(
    id: 4,
    name: 'Apple Watch Series 10',
    category: 'Đồng hồ',
    price: 9990000,
    oldPrice: 10990000,
    image:
    'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=800',
    description:
    'Apple Watch Series 10 với màn hình đẹp, nhiều tính năng theo dõi hoạt động và thiết kế hiện đại.',
    rating: 4.8,
  ),
  const Product(
    id: 5,
    name: 'Sony WH-1000XM5',
    category: 'Tai nghe',
    price: 8490000,
    oldPrice: 9490000,
    image:
    'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=800',
    description:
    'Tai nghe Sony WH-1000XM5 nổi bật với khả năng chống ồn hàng đầu và chất lượng âm thanh tuyệt vời.',
    rating: 4.9,
  ),
  const Product(
    id: 6,
    name: 'Nike Air Max',
    category: 'Giày',
    price: 3290000,
    oldPrice: 3990000,
    image:
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
    description:
    'Giày Nike Air Max thời trang, thoải mái và phù hợp sử dụng hàng ngày.',
    rating: 4.6,
  ),
  const Product(
    id: 7,
    name: 'Samsung Galaxy S25',
    category: 'Điện thoại',
    price: 22990000,
    oldPrice: 25990000,
    image:
    'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=800',
    description:
    'Samsung Galaxy S25 với thiết kế hiện đại, camera cao cấp và hiệu năng mạnh mẽ.',
    rating: 4.8,
  ),
  const Product(
    id: 8,
    name: 'iPad Pro M4',
    category: 'Tablet',
    price: 28990000,
    oldPrice: 31990000,
    image:
    'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=800',
    description:
    'iPad Pro M4 với màn hình chất lượng cao, hiệu năng mạnh và hỗ trợ Apple Pencil.',
    rating: 4.9,
  ),
];

// ============================================================
// GIỎ HÀNG TOÀN APP
// ============================================================

List<CartItem> cart = [];

String currentUser = '';

List<Map<String, dynamic>> orders = [];

// ============================================================
// APP
// ============================================================

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Shop App',

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF4D67),
        ),
      ),

      // ======================================================
      // NAMED ROUTES
      // ======================================================

      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainScreen(),
        '/cart': (context) => const CartScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/account': (context) => const AccountScreen(),
      },
    );
  }
}

// ============================================================
// LOGIN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );

    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin'),
        ),
      );
      return;
    }

    currentUser = emailController.text.trim();

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFF416C),
              Color(0xFFFF4B2B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 15,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shopping_bag_rounded,
                            size: 50,
                            color: Color(0xFFFF416C),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'SHOP APP',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Mua sắm dễ dàng - Giá tốt mỗi ngày',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 30),

                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email / Tài khoản',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon:
                            const Icon(Icons.visibility_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF416C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'ĐĂNG NHẬP',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Chưa có tài khoản? '),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/register',
                                );
                              },
                              child: const Text(
                                'Đăng ký',
                                style: TextStyle(
                                  color: Color(0xFFFF416C),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// REGISTER
// ============================================================

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  void register() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin'),
        ),
      );
      return;
    }

    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu xác nhận không khớp'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đăng ký thành công!'),
      ),
    );

    Future.delayed(const Duration(milliseconds: 700), () {
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFE4E9),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Icon(
                Icons.person_add_alt_1,
                size: 80,
                color: Color(0xFFFF416C),
              ),

              const SizedBox(height: 20),

              const Text(
                'Tạo tài khoản',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              _input(
                controller: nameController,
                label: 'Họ và tên',
                icon: Icons.person,
              ),

              const SizedBox(height: 15),

              _input(
                controller: emailController,
                label: 'Email',
                icon: Icons.email,
              ),

              const SizedBox(height: 15),

              _input(
                controller: passwordController,
                label: 'Mật khẩu',
                icon: Icons.lock,
                obscure: true,
              ),

              const SizedBox(height: 15),

              _input(
                controller: confirmController,
                label: 'Xác nhận mật khẩu',
                icon: Icons.lock_reset,
                obscure: true,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF416C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'TẠO TÀI KHOẢN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

// ============================================================
// MAIN SCREEN
// ============================================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const HomeScreen(),
    const CartScreen(),
    const OrdersScreen(),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cart.isNotEmpty,
              label: Text('${cart.length}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: cart.isNotEmpty,
              label: Text('${cart.length}'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Giỏ hàng',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Đơn hàng',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Tất cả';
  String searchText = '';

  final categories = [
    'Tất cả',
    'Điện thoại',
    'Laptop',
    'Phụ kiện',
    'Đồng hồ',
    'Tai nghe',
    'Giày',
    'Tablet',
  ];

  @override
  Widget build(BuildContext context) {
    List<Product> filteredProducts = products.where((product) {
      final matchCategory = selectedCategory == 'Tất cả' ||
          product.category == selectedCategory;

      final matchSearch = product.name
          .toLowerCase()
          .contains(searchText.toLowerCase());

      return matchCategory && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF416C),
        foregroundColor: Colors.white,
        title: const Text(
          'SHOP APP',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/cart').then((_) {
                setState(() {});
              });
            },
            icon: Badge(
              isLabelVisible: cart.isNotEmpty,
              label: Text('${cart.length}'),
              child: const Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(
            const Duration(milliseconds: 700),
          );

          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SEARCH
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF416C),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(25),
                  ),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm sản phẩm...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: const Icon(Icons.tune),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // BANNER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 170,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF758C),
                        Color(0xFFFF7EB3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        bottom: -30,
                        child: Icon(
                          Icons.shopping_bag,
                          size: 180,
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SALE 50%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Siêu ưu đãi hôm nay',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 15),
                            Text(
                              'Mua ngay →',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // CATEGORY
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Danh mục',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 90,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: selectedCategory == category
                              ? const Color(0xFFFF416C)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _categoryIcon(category),
                              color: selectedCategory == category
                                  ? Colors.white
                                  : const Color(0xFFFF416C),
                              size: 30,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              category,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: selectedCategory == category
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 25),

              // PRODUCT TITLE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sản phẩm nổi bật',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${filteredProducts.length} sản phẩm',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // PRODUCTS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredProducts.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.64,
                  ),
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: filteredProducts[index],
                      onChanged: () {
                        setState(() {});
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Điện thoại':
        return Icons.phone_android;
      case 'Laptop':
        return Icons.laptop;
      case 'Phụ kiện':
        return Icons.headphones;
      case 'Đồng hồ':
        return Icons.watch;
      case 'Tai nghe':
        return Icons.headset;
      case 'Giày':
        return Icons.directions_run;
      case 'Tablet':
        return Icons.tablet;
      default:
        return Icons.apps;
    }
  }
}

// ============================================================
// PRODUCT CARD
// ============================================================

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onChanged;

  const ProductCard({
    super.key,
    required this.product,
    required this.onChanged,
  });

  void addToCart(BuildContext context) {
    final index = cart.indexWhere(
          (item) => item.product.id == product.id,
    );

    if (index >= 0) {
      cart[index].quantity++;
    } else {
      cart.add(
        CartItem(product: product),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} đã thêm vào giỏ'),
        duration: const Duration(milliseconds: 900),
        action: SnackBarAction(
          label: 'XEM GIỎ',
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          },
        ),
      ),
    );

    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // ====================================================
        // MATERIAL PAGE ROUTE + TRUYỀN DỮ LIỆU
        // ====================================================

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: product,
            ),
          ),
        );
      },
      child: Hero(
        tag: 'product_${product.id}',
        child: Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        product.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                            ),
                          );
                        },
                      ),
                    ),

                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${(((product.oldPrice - product.price) / product.oldPrice) * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${product.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      formatMoney(product.price),
                      style: const TextStyle(
                        color: Color(0xFFFF416C),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      formatMoney(product.oldPrice),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => addToCart(context),
                        icon: const Icon(
                          Icons.add_shopping_cart,
                          size: 18,
                        ),
                        label: const Text('Thêm'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFFFF416C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PRODUCT DETAIL
// ============================================================

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends State<ProductDetailScreen> {
  int quantity = 1;

  void addToCart() {
    final index = cart.indexWhere(
          (item) => item.product.id == widget.product.id,
    );

    if (index >= 0) {
      cart[index].quantity += quantity;
    } else {
      cart.add(
        CartItem(
          product: widget.product,
          quantity: quantity,
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã thêm sản phẩm vào giỏ hàng'),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
            icon: Badge(
              isLabelVisible: cart.isNotEmpty,
              label: Text('${cart.length}'),
              child: const Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product_${product.id}',
              child: SizedBox(
                width: double.infinity,
                height: 330,
                child: Image.network(
                  product.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            color: Color(0xFFFF416C),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      Text(
                        '${product.rating}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    formatMoney(product.price),
                    style: const TextStyle(
                      fontSize: 28,
                      color: Color(0xFFFF416C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    formatMoney(product.oldPrice),
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade500,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Mô tả sản phẩm',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    product.description,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.6,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Số lượng',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                        ),
                        icon: const Icon(Icons.remove),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Text(
                          '$quantity',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                        ),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: addToCart,
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                          ),
                          label: const Text('Thêm vào giỏ'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                            const Color(0xFFFF416C),
                            side: const BorderSide(
                              color: Color(0xFFFF416C),
                            ),
                            minimumSize:
                            const Size(double.infinity, 55),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CheckoutScreen(
                                      product: product,
                                      quantity: quantity,
                                    ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFFFF416C),
                            foregroundColor: Colors.white,
                            minimumSize:
                            const Size(double.infinity, 55),
                          ),
                          child: const Text('Mua ngay'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CART
// ============================================================

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get total {
    return cart.fold(
      0,
          (sum, item) =>
      sum + item.product.price * item.quantity,
    );
  }

  void removeItem(int index) {
    setState(() {
      cart.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Giỏ hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Xóa giỏ hàng?'),
                      content: const Text(
                        'Bạn có chắc muốn xóa tất cả sản phẩm?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Hủy'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              cart.clear();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Xóa'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.delete_sweep),
            ),
        ],
      ),
      body: cart.isEmpty
          ? _emptyCart()
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];

                return Dismissible(
                  key: ValueKey(item.product.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.centerRight,
                    padding:
                    const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) {
                    removeItem(index);
                  },
                  child: Card(
                    elevation: 2,
                    margin:
                    const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius:
                            BorderRadius.circular(12),
                            child: Image.network(
                              item.product.image,
                              width: 85,
                              height: 85,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  maxLines: 2,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  formatMoney(
                                    item.product.price,
                                  ),
                                  style: const TextStyle(
                                    color:
                                    Color(0xFFFF416C),
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (item.quantity >
                                              1) {
                                            item.quantity--;
                                          }
                                        });
                                      },
                                      constraints:
                                      const BoxConstraints
                                          .tightFor(
                                        width: 32,
                                        height: 32,
                                      ),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.remove,
                                        size: 18,
                                      ),
                                    ),

                                    Text(
                                      '${item.quantity}',
                                      style:
                                      const TextStyle(
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),

                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          item.quantity++;
                                        });
                                      },
                                      constraints:
                                      const BoxConstraints
                                          .tightFor(
                                        width: 32,
                                        height: 32,
                                      ),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.add,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              removeItem(index);
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // TOTAL
          Container(
            padding: const EdgeInsets.fromLTRB(
              20,
              15,
              20,
              25,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng cộng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatMoney(total),
                      style: const TextStyle(
                        fontSize: 22,
                        color: Color(0xFFFF416C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CheckoutScreen(
                                cartItems:
                                List<CartItem>.from(cart),
                              ),
                        ),
                      ).then((_) {
                        setState(() {});
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFFFF416C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'TIẾN HÀNH ĐẶT HÀNG',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
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

  Widget _emptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          const Text(
            'Giỏ hàng đang trống',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Hãy thêm sản phẩm yêu thích vào giỏ hàng',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                '/home',
              );
            },
            child: const Text('MUA SẮM NGAY'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CHECKOUT
// ============================================================

class CheckoutScreen extends StatefulWidget {
  final Product? product;
  final int quantity;
  final List<CartItem>? cartItems;

  const CheckoutScreen({
    super.key,
    this.product,
    this.quantity = 1,
    this.cartItems,
  });

  @override
  State<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final addressController = TextEditingController();

  String payment = 'COD';

  List<CartItem> get items {
    if (widget.cartItems != null) {
      return widget.cartItems!;
    }

    return [
      CartItem(
        product: widget.product!,
        quantity: widget.quantity,
      ),
    ];
  }

  double get total {
    return items.fold(
      0,
          (sum, item) =>
      sum + item.product.price * item.quantity,
    );
  }

  void placeOrder() {
    if (addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập địa chỉ giao hàng'),
        ),
      );
      return;
    }

    orders.add({
      'id': 'DH${DateTime.now().millisecondsSinceEpoch}',
      'date': DateTime.now(),
      'total': total,
      'status': 'Đang xử lý',
      'items': items.map((item) {
        return {
          'name': item.product.name,
          'quantity': item.quantity,
          'price': item.product.price,
        };
      }).toList(),
    });

    cart.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              SizedBox(width: 10),
              Text('Đặt hàng thành công'),
            ],
          ),
          content: const Text(
            'Cảm ơn bạn đã mua hàng. Đơn hàng đang được xử lý.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                      (route) => false,
                );
              },
              child: const Text('VỀ TRANG CHỦ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận đơn hàng'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sản phẩm',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ...items.map(
                  (item) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.product.image,
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(item.product.name),
                  subtitle: Text(
                    'Số lượng: ${item.quantity}',
                  ),
                  trailing: Text(
                    formatMoney(
                      item.product.price * item.quantity,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Thông tin giao hàng',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: addressController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Địa chỉ nhận hàng',
                hintText: 'Nhập địa chỉ của bạn...',
                prefixIcon: const Icon(
                  Icons.location_on_outlined,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Phương thức thanh toán',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            RadioListTile(
              value: 'COD',
              groupValue: payment,
              onChanged: (value) {
                setState(() {
                  payment = value!;
                });
              },
              title: const Text('Thanh toán khi nhận hàng'),
              secondary: const Icon(
                Icons.local_shipping,
              ),
            ),

            RadioListTile(
              value: 'BANK',
              groupValue: payment,
              onChanged: (value) {
                setState(() {
                  payment = value!;
                });
              },
              title: const Text('Chuyển khoản ngân hàng'),
              secondary: const Icon(
                Icons.account_balance,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng thanh toán',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formatMoney(total),
                    style: const TextStyle(
                      color: Color(0xFFFF416C),
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: placeOrder,
                icon: const Icon(Icons.shopping_bag),
                label: const Text(
                  'ĐẶT HÀNG',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFFFF416C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ORDERS
// ============================================================

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Đơn hàng của tôi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: orders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 100,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            const Text(
              'Chưa có đơn hàng',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[
          orders.length - index - 1];

          return Card(
            margin:
            const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(18),
            ),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor:
                Colors.red.shade50,
                child: const Icon(
                  Icons.local_shipping,
                  color: Color(0xFFFF416C),
                ),
              ),
              title: Text(
                order['id'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                order['status'],
                style: const TextStyle(
                  color: Colors.orange,
                ),
              ),
              trailing: Text(
                formatMoney(order['total']),
                style: const TextStyle(
                  color: Color(0xFFFF416C),
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                ...List<Map<String, dynamic>>.from(
                  order['items'],
                ).map(
                      (item) => ListTile(
                    title: Text(item['name']),
                    subtitle: Text(
                      'SL: ${item['quantity']}',
                    ),
                    trailing: Text(
                      formatMoney(
                        item['price'] *
                            item['quantity'],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// ACCOUNT
// ============================================================

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          'Tài khoản',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFF416C),
                    Color(0xFFFF758C),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 55,
                      color: Color(0xFFFF416C),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    currentUser.isEmpty
                        ? 'Khách hàng'
                        : currentUser,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Thành viên Shop App',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _menu(
              context,
              Icons.shopping_bag_outlined,
              'Đơn mua',
                  () {
                Navigator.pushNamed(
                  context,
                  '/orders',
                );
              },
            ),

            _menu(
              context,
              Icons.location_on_outlined,
              'Địa chỉ nhận hàng',
                  () {
                _showMessage(
                  context,
                  'Chức năng quản lý địa chỉ',
                );
              },
            ),

            _menu(
              context,
              Icons.favorite_border,
              'Sản phẩm yêu thích',
                  () {
                _showMessage(
                  context,
                  'Danh sách yêu thích',
                );
              },
            ),

            _menu(
              context,
              Icons.notifications_none,
              'Thông báo',
                  () {
                _showMessage(
                  context,
                  'Bạn không có thông báo mới',
                );
              },
            ),

            _menu(
              context,
              Icons.settings_outlined,
              'Cài đặt',
                  () {
                _showMessage(
                  context,
                  'Màn hình cài đặt',
                );
              },
            ),

            const SizedBox(height: 10),

            _menu(
              context,
              Icons.logout,
              'Đăng xuất',
                  () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Đăng xuất'),
                      content: const Text(
                        'Bạn có chắc muốn đăng xuất?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Hủy'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            currentUser = '';

                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                                  (route) => false,
                            );
                          },
                          child: const Text('Đăng xuất'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 30),

            Text(
              'Shop App v1.0.0',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _menu(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: const Color(0xFFFF416C),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
      ),
    );
  }

  void _showMessage(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

// ============================================================
// FORMAT MONEY
// ============================================================

String formatMoney(double value) {
  final String text = value.toInt().toString();

  String result = '';
  int count = 0;

  for (int i = text.length - 1; i >= 0; i--) {
    result = text[i] + result;
    count++;

    if (count == 3 && i != 0) {
      result = '.$result';
      count = 0;
    }
  }

  return '$result đ';
}