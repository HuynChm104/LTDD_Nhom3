// lib/main.dart
import 'package:bongbieng_app/providers/auth_provider.dart';
import 'package:bongbieng_app/providers/cart_provider.dart';
import 'package:bongbieng_app/providers/order_provider.dart';
import 'package:bongbieng_app/providers/product_provider.dart';
import 'package:bongbieng_app/screens/auth/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:bongbieng_app/models/product_model.dart';
import 'package:bongbieng_app/providers/branch_provider.dart';
import 'package:bongbieng_app/screens/cart/cart_screen.dart';
import 'package:bongbieng_app/screens/voucher/voucher_screen.dart';
import 'package:bongbieng_app/screens/home/home_screen.dart';
import 'package:bongbieng_app/screens/products/product_detail_screen.dart';
import 'package:bongbieng_app/screens/profile/profile_screen.dart';
import 'package:bongbieng_app/widgets/bottom_nav_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Facebook SDK
    await FacebookAuth.instance.webAndDesktopInitialize(
      appId: "876477621565568",
      cookie: true,
      xfbml: true,
      version: "v17.0",
    );

  runApp(const BongBiengApp());

}

class BongBiengApp extends StatelessWidget {
  const BongBiengApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BranchProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),

        ChangeNotifierProxyProvider2<AuthProvider, ProductProvider, CartProvider>(
          create: (context) => CartProvider(),
          update: (context, auth, products, previousCart) {
            final cart = previousCart ?? CartProvider();
            cart.update(products);

            if (auth.isAuthenticated) {

              if (cart.items.isEmpty) cart.fetchCartItems();
            }

            return cart;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Bông Biêng App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: AppColors.createMaterialColor(AppColors.primary),
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Inter',
          useMaterial3: true,
          // ... (phần theme của bạn giữ nguyên)
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
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasData) {
              return const MainShell();
            }

            return const WelcomeScreen();
          },
        ),

      ),
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
