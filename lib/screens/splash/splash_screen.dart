import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart'; // Import thư viện animate
import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  // Điều hướng sau khoảng 3 giây để hiệu ứng được trọn vẹn
  void _navigateToHome() {
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainShell(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Hiệu ứng chuyển cảnh mờ dần cho mượt mà
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFafcbe1), // Nền xanh nhạt
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. HIỆU ỨNG BÔNG HOA NỞ
            Image.asset(
              'assets/images/logo/hoa_logo.jpg',
              width: 150, // Kích thước của bông hoa
            )
                .animate()
                .fade(duration: 1200.ms) // Xuất hiện từ từ
                .scale(
              begin: const Offset(0.5, 0.5), // Bắt đầu từ 50% kích thước
              end: const Offset(1, 1),     // Phóng lớn đến 100%
              duration: 1500.ms,
              curve: Curves.easeOutQuint, // Đường cong mượt mà, nhanh ở đầu và chậm ở cuối
            )
                .rotate(
              begin: -0.1, // Hơi nghiêng sang trái
              end: 0,      // Xoay về vị trí thẳng đứng
              duration: 1500.ms,
              curve: Curves.easeInOut,
            ),

            const SizedBox(height: 0),

            // 2. TÊN THƯƠNG HIỆU XUẤT HIỆN
            Image.asset(
              'assets/images/logo/logo_chu.jpg',
              width: 220,
            )
                .animate()
                .fade(
              delay: 800.ms,  // Xuất hiện sau khi bông hoa đã bắt đầu nở
              duration: 1200.ms,
            ),
          ],
        ),
      ),
    );
  }
}
