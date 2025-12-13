// lib/screens/onboarding/onboarding_screen.dart
import 'dart:async';
import 'package:bongbieng_app/screens/auth/login_screen.dart'; // Giữ lại import này để tham khảo
import 'package:bongbieng_app/screens/auth/register_screen.dart'; // Giữ lại import này để tham khảo
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'onboarding_content.dart';
import 'dot_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onCompleted;
  const OnboardingScreen({super.key, required this.onCompleted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _pageIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageIndex < _onboardingData.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      } else {
        _timer?.cancel();
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/onboarding/7.jpg",
      "title": "Chào Mừng Bạn Đến Bông Biêng",
      "description":
      "Khám phá thế giới đồ uống đa dạng và độc đáo của chúng tôi.",
    },
    {
      "image": "assets/images/onboarding/6.jpg",
      "title": "Đặt Hàng Nhanh Chóng",
      "description":
      "Chỉ với vài cú chạm, đồ uống yêu thích sẽ được giao đến tận nơi.",
    },
    {
      "image": "assets/images/onboarding/5.jpg",
      "title": "Bắt Đầu Ngay Thôi!",
      "description":
      "Tạo tài khoản để nhận ưu đãi hoặc đăng nhập để tiếp tục trải nghiệm.",
    },
  ];

  // Hàm này giữ nguyên, nó chỉ báo cho AuthWrapper biết onboarding đã xong
  void _completeOnboarding() {
    widget.onCompleted();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Lớp 1 và 2: PageView và Gradient Overlay (Giữ nguyên)
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _pageIndex = index;
              });
              _resetTimer();
            },
            itemBuilder: (context, index) => OnboardingContent(
              image: _onboardingData[index]['image']!,
            ),
          ),
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.4),
                    AppColors.primary.withOpacity(0.5),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Lớp 3: Nội dung UI
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Nút Bỏ qua (Giữ nguyên)
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                      child: const Text("Bỏ qua"),
                    ),
                  ),
                  const Spacer(),

                  // Phần Text và DotIndicator (Giữ nguyên)
                  Column(
                    children: [
                      Text(
                        _onboardingData[_pageIndex]['title']!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _onboardingData[_pageIndex]['description']!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8), height: 1.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                          (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: DotIndicator(isActive: index == _pageIndex),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Phần nút bấm chính
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _pageIndex == _onboardingData.length - 1
                      // === SỬA ĐỔI TẠI ĐÂY: TÁCH THÀNH 2 NÚT RIÊNG BIỆT ===
                          ? Column(
                        key: const ValueKey('auth_buttons'),
                        children: [
                          // Nút 1: TẠO TÀI KHOẢN (Nút chính)
                          ElevatedButton(
                            onPressed: () {
                              // Báo cho AuthWrapper biết onboarding đã xong
                              _completeOnboarding();
                              // Sau đó điều hướng đến màn hình Đăng ký
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                            },
                            child: const Text("Tạo tài khoản"),
                          ),
                          const SizedBox(height: 16),

                          // Nút 2: ĐĂNG NHẬP (Nút phụ)
                          OutlinedButton(
                            onPressed: () {
                              _completeOnboarding();
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white.withOpacity(0.8), width: 1.5),
                              backgroundColor: Colors.white.withOpacity(0.1),
                            ),
                            child: const Text("Đăng nhập"),
                          ),
                        ],
                      )
                      // ========================================================
                          : ElevatedButton( // Nút "Tiếp tục" (Giữ nguyên)
                        key: const ValueKey('continue_button'),
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                          _resetTimer();
                        },
                        child: const Text("Tiếp tục"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
