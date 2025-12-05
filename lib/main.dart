// main.dart
import 'package:bongbieng_app/models/product_model.dart';
import 'package:bongbieng_app/providers/branch_provider.dart';
import 'package:bongbieng_app/screens/cart/cart_screen.dart';
import 'package:bongbieng_app/screens/home/home_screen.dart';
import 'package:bongbieng_app/screens/products/product_detail_screen.dart';
import 'package:bongbieng_app/screens/profile/profile_screen.dart';
import 'package:bongbieng_app/screens/splash/splash_screen.dart';
import 'package:bongbieng_app/screens/voucher/voucher_screen.dart';
import 'package:bongbieng_app/widgets/bottom_nav_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BongBiengApp());
}

class BongBiengApp extends StatelessWidget {
  const BongBiengApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BranchProvider(),
        ),
        // Thêm các provider khác ở đây sau
        // ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          //scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Poppins', // Tùy chọn: thêm font đẹp
          useMaterial3: true,
        ),
        // --- PHẦN THÊM VÀO ĐỂ ĐIỀU HƯỚNG ---
        onGenerateRoute: (settings) {
          // Kiểm tra nếu tên đường dẫn là '/product-detail'
          if (settings.name == '/product-detail') {
            // Lấy dữ liệu (ProductModel) được gửi kèm
            final args = settings.arguments as ProductModel;

            // Trả về màn hình chi tiết với dữ liệu đó
            return MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: args),
            );
          }
          return null; // Để mặc định nếu không khớp
        },
        // --------------------------------------------------
        home: const SplashScreen(),
      ),
    );
  }
}

// Main Shell với Bottom Navigation
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Danh sách 4 màn hình chính
  static final List<Widget> _pages = [
    HomeScreen(),
    const VoucherScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}