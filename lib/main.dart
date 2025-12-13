// lib/main.dart
import 'package:bongbieng_app/providers/auth_provider.dart';
import 'package:bongbieng_app/providers/cart_provider.dart';
import 'package:bongbieng_app/providers/product_provider.dart';
import 'package:bongbieng_app/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:bongbieng_app/models/product_model.dart';
import 'package:bongbieng_app/providers/branch_provider.dart';
import 'package:bongbieng_app/screens/cart/cart_screen.dart';
import 'package:bongbieng_app/screens/voucher/voucher_screen.dart';
import 'package:bongbieng_app/screens/home/home_screen.dart';
import 'package:bongbieng_app/screens/onboarding/onboarding_screen.dart';
import 'package:bongbieng_app/screens/products/product_detail_screen.dart';
import 'package:bongbieng_app/screens/profile/profile_screen.dart';
import 'package:bongbieng_app/widgets/bottom_nav_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // SỬA: Không cần runApp ở đây nữa, sẽ gọi trong MultiProvider
  runApp(const BongBiengApp());
}

// === SỬA LẠI TOÀN BỘ WIDGET NÀY ===
class BongBiengApp extends StatelessWidget {
  const BongBiengApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider phải là widget gốc
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BranchProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        // CartProvider sẽ phụ thuộc vào AuthProvider và ProductProvider
        ChangeNotifierProxyProvider2<AuthProvider, ProductProvider, CartProvider>(
          create: (context) => CartProvider(),
          update: (context, auth, products, previousCart) {
            final cart = previousCart ?? CartProvider();
            // Cập nhật ProductProvider cho CartProvider để nó có thể tính giá
            cart.update(products);
            // Nếu người dùng đăng nhập, tải giỏ hàng của họ
            if (auth.isAuthenticated) {
              cart.fetchCartItems();
            } else {
              // Nếu đăng xuất, dọn dẹp giỏ hàng trên UI
              cart.clearCartOnSignOut();
            }
            return cart;
          },
        ),
      ],
      // MaterialApp phải là con của MultiProvider
      child: MaterialApp(
        title: 'Bông Biêng App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: AppColors.createMaterialColor(AppColors.primary),
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Inter',
          useMaterial3: true,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(56),
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 16),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textDark,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Inter',
            ),
          ),
        ),
        onGenerateRoute: (settings) {
          if (settings.name == '/product-detail') {
            final args = settings.arguments as ProductModel;
            return MaterialPageRoute(builder: (context) => ProductDetailScreen(product: args));
          }
          return null;
        },
        home: const AuthWrapper(),
      ),
    );
  }
}

// (AuthWrapper và MainShell)
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<bool> _hasSeenOnboardingFuture;

  @override
  void initState() {
    super.initState();
    _hasSeenOnboardingFuture = _checkIfOnboardingCompleted();
  }

  Future<bool> _checkIfOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasSeenOnboarding') ?? false;
  }

  void _onOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    setState(() {
      _hasSeenOnboardingFuture = Future.value(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAuthenticated) {
      return const MainShell();
    }

    return FutureBuilder<bool>(
      future: _hasSeenOnboardingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final hasSeenOnboarding = snapshot.data ?? false;

        if (hasSeenOnboarding) {
          return const LoginScreen();
        } else {
          return OnboardingScreen(onCompleted: _onOnboardingComplete);
        }
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      const VoucherScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
