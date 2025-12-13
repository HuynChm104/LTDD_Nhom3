// lib/screens/home/widgets/home_content.dart
import 'package:flutter/material.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import '../../../services/category_service.dart';
import '../../../services/product_service.dart';
import '../../../utils/constants.dart';
import 'category_card.dart';
import 'product_card.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

// BƯỚC QUAN TRỌNG: Thêm 'with AutomaticKeepAliveClientMixin'
class _HomeContentState extends State<HomeContent> with AutomaticKeepAliveClientMixin {
  String selectedCategory = 'bestseller';

  final List<Map<String, dynamic>> staticCategories = [
    {'id': 'all', 'label': 'Tất cả', 'icon': Icons.menu},
    {'id': 'bestseller', 'label': 'Best Seller', 'icon': Icons.star},
  ];

  // BẮT BUỘC: Để giữ giao diện không bị load lại
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // BẮT BUỘC

    // ĐÂY LÀ ĐOẠN CODE CŨ CỦA BẠN (CustomScrollView) ĐƯỢC CHUYỂN SANG ĐÂY
    // CustomScrollView sẽ tự động lấy màu nền từ Scaffold, không cần đặt màu nền ở đây.
    return CustomScrollView(
      slivers: [
        // 1. BANNER
        SliverAppBar(
          expandedHeight: 280,
          floating: false,
          pinned: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                  child: Image.asset(
                    'assets/images/main_banner.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      // SỬA MÀU #1: Đảm bảo dùng đúng màu chủ đạo
                      color: AppColors.primary,
                      child: const Center(
                        child: Text("Banner", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. CATEGORY
        SliverToBoxAdapter(
          child: Container(
            // Đoạn này tạo hiệu ứng "nâng" khu vực category lên trên banner một chút
            // do bo tròn của banner bị che đi.
            // Bằng cách đổi màu nền thành màu nền chung của app, nó sẽ liền mạch hơn.
            margin: const EdgeInsets.only(top: 0),
            decoration: const BoxDecoration(
              // SỬA MÀU #2: Đồng bộ với màu nền của Scaffold
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: StreamBuilder<List<CategoryModel>>(
              key: ValueKey(selectedCategory),
              stream: CategoryService.getCategories(),
              builder: (context, snapshot) {
                List<Map<String, dynamic>> allCategories = List.from(staticCategories);
                final List<CategoryModel> firestoreCats = snapshot.data ?? [];

                if (firestoreCats.isNotEmpty) {
                  allCategories.addAll(
                    firestoreCats.map((cat) => {
                      'id': cat.id,
                      'label': cat.name,
                      'icon': Icons.local_drink_outlined,
                    }),
                  );
                }

                return SizedBox(
                  height: 50, // Tăng chiều cao một chút để thẻ CategoryCard không bị quá chật
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: allCategories.length,
                    itemBuilder: (ctx, i) {
                      final cat = allCategories[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: CategoryCard(
                          label: cat['label'],
                          icon: cat['icon'],
                          isSelected: selectedCategory == cat['id'],
                          onTap: () {
                            setState(() {
                              selectedCategory = cat['id'];
                            });
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),

        // 3. PRODUCT GRID
        StreamBuilder<List<ProductModel>>(
          stream: _getProductStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  // SỬA MÀU #3: Dùng màu chủ đạo cho vòng xoay loading
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ),
              );
            }
            if (snapshot.hasError) {
              return const SliverToBoxAdapter(
                child: SizedBox(height: 200, child: Center(child: Text("Lỗi tải sản phẩm."))),
              );
            }
            final products = snapshot.data ?? [];
            if (products.isEmpty) {
              return const SliverToBoxAdapter(
                child: SizedBox(height: 200, child: Center(child: Text("Không có sản phẩm nào."))),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100), // Padding bottom để né nút giỏ hàng
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.82, // Điều chỉnh tỷ lệ để card sản phẩm cân đối hơn
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                delegate: SliverChildBuilderDelegate((ctx, i) {
                  final p = products[i];
                  // ProductCard sẽ cần được cập nhật ở một file riêng
                  return ProductCard(
                    image: p.image,
                    name: p.name,
                    price: p.basePrice.toInt().toString(),
                    onTap: () => Navigator.pushNamed(context, '/product-detail', arguments: p),
                    onCart: () => Navigator.pushNamed(context, '/product-detail', arguments: p),
                  );
                },
                  childCount: products.length,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Stream<List<ProductModel>> _getProductStream() {
    if (selectedCategory == 'all') {
      return ProductService.getAllProducts();
    } else if (selectedCategory == 'bestseller') {
      return ProductService.getBestSellers();
    } else {
      return ProductService.getProductsByCategory(selectedCategory);
    }
  }
}
