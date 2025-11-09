// lib/screens/home/home_screen.dart
import 'package:bongbieng_app/models/product_model.dart';
import 'package:bongbieng_app/screens/home/widgets/app_bar.dart';
import 'package:bongbieng_app/screens/home/widgets/category_card.dart';
import 'package:bongbieng_app/screens/home/widgets/product_card.dart';
import 'package:bongbieng_app/services/product_service.dart';
import 'package:bongbieng_app/utils/constants.dart';
import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../../services/category_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // MẶC ĐỊNH CHỌN "Best Seller"
  String selectedCategory = 'bestseller';

  // Danh sách category tĩnh: "All" + "Best Seller"
  final List<Map<String, dynamic>> staticCategories = [
    {'id': 'all', 'label': 'Tất cả', 'icon': Icons.menu},
    {'id': 'bestseller', 'label': 'Best Seller', 'icon': Icons.star},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(),
      body: CustomScrollView(
        slivers: [
          // BANNER
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

          // CATEGORY + ĐÈ LÊN BANNER
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: 0),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: StreamBuilder<List<CategoryModel>>(
                key: ValueKey(selectedCategory), // Rebuild khi chọn
                stream: CategoryService.getCategories() as Stream<List<CategoryModel>>?,
                builder: (context, snapshot) {
                  // DANH SÁCH CATEGORY
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
                    height: 45,
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

          // PRODUCT GRID – LỌC THEO CATEGORY HOẶC BESTSELLER
          StreamBuilder<List<ProductModel>>(
            stream: _getProductStream(),
            builder: (context, snapshot) {
              // ĐANG TẢI
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator(color: AppColors.primaryDark)),
                  ),
                );
              }

              // LỖI
              if (snapshot.hasError) {
                return const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: Center(child: Text("Lỗi tải sản phẩm.")),
                  ),
                );
              }

              // DỮ LIỆU
              final List<ProductModel> products = snapshot.data ?? [];

              if (products.isEmpty) {
                return const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: Center(child: Text("Không có sản phẩm nào.")),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.88,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                      final p = products[i];
                      return ProductCard(
                        image: p.image,
                        name: p.name,
                        price: p.basePrice.toInt().toString(),
                        onTap: () => Navigator.pushNamed(context, '/product-detail', arguments: p.id),
                        onCart: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${p.name} đã thêm vào giỏ")),
                          );
                        },
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // XỬ LÝ STREAM THEO LOẠI
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