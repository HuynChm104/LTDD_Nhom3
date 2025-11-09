import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Giỏ hàng"),
      ),
      body: const Center(
        child: Text("Danh sách giỏ hàng demo"),
      ),
    );
  }
}
