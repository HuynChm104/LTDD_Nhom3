// lib/screens/home/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../utils/constants.dart';
import '../../utils/string_helper.dart'; // File chứa hàm removeDiacritics
import 'widgets/app_bar.dart';
import 'widgets/product_card.dart';
import 'widgets/home_content.dart'; // <--- Import file vừa tạo ở Bước 1

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchKeyword = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Chỉ coi là đang tìm kiếm khi CÓ CHỮ trong ô input
    bool hasKeyword = _searchKeyword.isNotEmpty;

    return Scaffold(
      // SỬA MÀU #1: Sử dụng màu nền chung từ constants
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,

      // APP BAR XỬ LÝ TÌM KIẾM
      appBar: CustomAppBar(
        onSearch: (keyword) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();

          if (keyword.isEmpty) {
            // Xóa chữ -> Cập nhật ngay lập tức
            setState(() => _searchKeyword = '');
          } else {
            // Đang gõ -> Đợi 0.5s để đỡ lag
            _debounce = Timer(const Duration(milliseconds: 500), () {
              if (mounted) setState(() => _searchKeyword = keyword);
            });
          }
        },
      ),

      // STACK: XẾP CHỒNG 2 LỚP
      body: Stack(
        children: [
          // LỚP 1: TRANG CHỦ (BANNER + CATEGORY + LIST)
          // const HomeContent() -> Giúp nó "Bất tử", không bị vẽ lại -> KHÔNG NHÁY
          const HomeContent(),

          // LỚP 2: MÀN HÌNH TÌM KIẾM (CHỈ HIỆN KHI CÓ CHỮ)
          if (hasKeyword)
            Container(
              // SỬA MÀU #2: Sử dụng màu nền chung để che đi trang chủ
              color: AppColors.background,
              width: double.infinity,
              height: double.infinity,
              child: _buildSearchResults(),
            ),
        ],
      ),
    );
  }

  // Widget hiển thị kết quả tìm kiếm (Lọc client-side)
  Widget _buildSearchResults() {
    return CustomScrollView(
      slivers: [
        StreamBuilder<List<ProductModel>>(
          stream: ProductService.getAllProducts(), // Lấy hết về để lọc
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                child: SizedBox(
                  height: 300,
                  // SỬA MÀU #3: Dùng màu chủ đạo cho vòng xoay loading
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ),
              );
            }
            try {
              var products = snapshot.data ?? [];

              // Logic lọc tìm kiếm
              final keywordNoSign = removeDiacritics(_searchKeyword);
              products = products.where((p) {
                final nameNoSign = removeDiacritics(p.name ?? "");
                return nameNoSign.contains(keywordNoSign);
              }).toList();

              if (products.isEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    height: 300,
                    alignment: Alignment.center,
                    child: Text(
                      "Không tìm thấy món nào tên \"$_searchKeyword\"",
                      // Sử dụng style từ theme để đồng bộ
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textGrey),
                    ),
                  ),
                );
              }

              return SliverPadding(
                // Padding Top lớn (120) để né cái SearchBar
                padding: const EdgeInsets.fromLTRB(20, 120, 20, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.82, // Cập nhật lại tỷ lệ cho khớp với ProductCard
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  delegate: SliverChildBuilderDelegate((ctx, i) {
                    final p = products[i];
                    return ProductCard(
                      image: p.image,
                      name: p.name,
                      price: p.basePrice.toInt().toString(),
                      onTap: () => Navigator.pushNamed(context, '/product-detail', arguments: p),
                      onCart: () => Navigator.pushNamed(context, '/product-detail', arguments: p),
                    );
                  }, childCount: products.length),
                ),
              );
            } catch (e) {
              return SliverToBoxAdapter(
                  child: Center(
                      child: Text(
                        "Lỗi: $e",
                        style: const TextStyle(color: AppColors.error),
                      )
                  )
              );
            }
          },
        ),
      ],
    );
  }
}
