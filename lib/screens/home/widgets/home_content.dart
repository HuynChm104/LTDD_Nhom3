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

class _HomeContentState extends State<HomeContent> with AutomaticKeepAliveClientMixin {
  String selectedCategory = 'bestseller';

  // SỬA 1: Khai báo biến để lưu giữ luồng dữ liệu, tránh bị tạo lại khi rebuild
  late Stream<List<ProductModel>> _productStream;

  final List<Map<String, dynamic>> staticCategories = [
    {'id': 'all', 'label': 'Tất cả', 'icon': Icons.menu},
    {'id': 'bestseller', 'label': 'Best Seller', 'icon': Icons.star},
  ];

  @override
  bool get wantKeepAlive => true;

  // SỬA 2: Khởi tạo luồng dữ liệu 1 lần duy nhất khi màn hình được tạo
  @override
  void initState() {
    super.initState();
    _productStream = _getProductStream();
  }

  // Hàm xử lý khi chọn danh mục
  void _onCategoryChanged(String newCategoryId) {
    if (selectedCategory == newCategoryId) return;

    setState(() {
      selectedCategory = newCategoryId;
      _productStream = _getProductStream(); // Chỉ tạo luồng mới khi đổi danh mục
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
            margin: const EdgeInsets.only(top: 0),
            decoration: const BoxDecoration(
              color: AppColors.white, // Hoặc AppColors.background tùy theme
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: StreamBuilder<List<CategoryModel>>(
              // Lưu ý: Bỏ key ở đây để tránh rebuild không cần thiết
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
                  height: 50,
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
                          // SỬA 3: Gọi hàm _onCategoryChanged thay vì setState trực tiếp
                          onTap: () => _onCategoryChanged(cat['id']),
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
          stream: _productStream, // SỬA 4: Dùng biến đã lưu, KHÔNG gọi hàm _getProductStream() ở đây
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.82,
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