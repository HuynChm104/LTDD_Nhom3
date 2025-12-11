// lib/screens/onboarding/onboarding_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'onboarding_content.dart';
import 'dot_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

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
      "description": "Khám phá thế giới đồ uống đa dạng và độc đáo của chúng tôi.",
    },
    {
      "image": "assets/images/onboarding/6.jpg",
      "title": "Đặt Hàng Nhanh Chóng",
      "description": "Chỉ với vài cú chạm, đồ uống yêu thích sẽ được giao đến tận nơi.",
    },
    {
      "image": "assets/images/onboarding/5.jpg",
      "title": "Bắt Đầu Ngay Thôi!",
      "description": "Tạo tài khoản để nhận ưu đãi hoặc đăng nhập để tiếp tục trải nghiệm.",
    },
  ];

  void _navigateToAuthScreen() {
    _pageController.animateToPage(
      _onboardingData.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // LỚP DƯỚI CÙNG: Ảnh nền có thể lướt được
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

          // LỚP PHỦ MÀU: Lớp này sẽ không nhận tương tác
          IgnorePointer( // <--- SỬA LỖI #1
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // LỚP TRÊN CÙNG: Chứa các nút và chữ
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // Nút "Bỏ qua" ở góc trên bên phải
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _navigateToAuthScreen,
                      child: const Text(
                        "Bỏ qua",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // PHẦN CHỮ: Bọc trong IgnorePointer để cho phép lướt
                  IgnorePointer( // <--- SỬA LỖI #2
                    child: Column(
                      children: [
                        Text(
                          _onboardingData[_pageIndex]['title']!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _onboardingData[_pageIndex]['description']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // DẤU CHẤM
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

                  // PHẦN NÚT: Các nút này vẫn phải bấm được nên chúng nằm ngoài IgnorePointer
                  if (_pageIndex == _onboardingData.length - 1)
                    Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            print("Chuyển đến màn hình Đăng nhập");
                          },
                          child: const Text("Đăng nhập"),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: AppColors.primary),
                          ),
                          onPressed: () {
                            print("Chuyển đến màn hình Đăng ký");
                          },
                          child: const Text("Tạo tài khoản", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    )
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                        _resetTimer();
                      },
                      child: const Text("Tiếp tục"),
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
