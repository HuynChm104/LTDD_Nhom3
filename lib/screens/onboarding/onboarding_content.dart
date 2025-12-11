// lib/screens/onboarding/onboarding_content.dart
import 'package:flutter/material.dart';

// Widget này giờ chỉ chịu trách nhiệm hiển thị ảnh nền
class OnboardingContent extends StatelessWidget {
  const OnboardingContent({
    super.key,
    required this.image,
  });

  final String image;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      image,
      // BoxFit.cover đảm bảo ảnh lấp đầy toàn bộ không gian mà không bị méo
      fit: BoxFit.cover,
      // Đặt height và width để đảm bảo nó lấp đầy màn hình trong Stack
      height: double.infinity,
      width: double.infinity,
      // Thêm alignment để ảnh được căn giữa khi cover
      alignment: Alignment.center,
    );
  }
}
