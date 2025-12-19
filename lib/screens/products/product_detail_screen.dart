// lib/screens/products/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../utils/constants.dart';
import '../cart/cart_screen.dart'; // SỬA #1: Import file constants

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // --- 2. QUẢN LÝ TRẠNG THÁI (STATE) ---
  String _selectedSize = 'M';
  String _selectedSugar = '100%';
  String _selectedIce = 'Bình thường';
  int _quantity = 1;
  final Set<String> _selectedToppings = {};

  // --- 3. CẤU HÌNH MENU (Dữ liệu tĩnh) ---
  final Map<String, double> _sizeOptions = {'M': 0, 'L': 10000};
  final List<String> _sugarOptions = ['0%', '30%', '50%', '70%', '100%', '120%'];
  final List<String> _iceOptions = ['Không đá', 'Ít đá', 'Bình thường'];
  final Map<String, double> _toppingOptions = {
    'Trân châu Hoàng kim': 10000,
    'Trân châu trắng': 10000,
    'Kem phô mai Macchiato': 15000,
    'Pudding Trứng': 10000,
    'Thạch Dừa': 10000,
  };

  // --- 4. LOGIC TÍNH TỔNG TIỀN ---
  double get _totalPrice {
    double sizePrice = _sizeOptions[_selectedSize] ?? 0;
    double toppingPrice = _selectedToppings.fold(0, (prev, topping) => prev + (_toppingOptions[topping] ?? 0));
    return (widget.product.basePrice + sizePrice + toppingPrice) * _quantity;
  }

  // Hàm tiện ích để format tiền tệ
  String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);
  }

  // HÀM GỌI PROVIDER ĐỂ THÊM VÀO GIỎ
  void _addToCart() {
    final cartProvider = context.read<CartProvider>();
    cartProvider.addItem(
      product: widget.product,
      quantity: _quantity,
      size: _selectedSize,
      sugarLevel: _selectedSugar,
      iceLevel: _selectedIce,
      toppings: _selectedToppings,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy theme ra để sử dụng
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // A. PHẦN ẢNH SẢN PHẨM (SliverAppBar)
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primaryLight, // SỬA #3
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: CircleAvatar(
                backgroundColor: AppColors.surface.withOpacity(0.8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20), // SỬA #4
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          actions: [
      Padding(
      padding: const EdgeInsets.only(right: 12.0),
        child: CircleAvatar(
            backgroundColor: AppColors.surface.withOpacity(0.8),
            child: Consumer<CartProvider>(
                builder: (context, cart, child) {
                  return Badge(
                    // Lấy tổng số sản phẩm từ CartProvider
                    label: Text('${cart.totalItems}'),
                    // Chỉ hiển thị badge khi có sản phẩm
                    isLabelVisible: cart.items.isNotEmpty,
                    // Căn chỉnh vị trí của badge
                    offset: const Offset(-2, -2),
                    child: child,
                  );
                },
              // Widget con này sẽ không bị rebuild khi cart thay đổi
              child: IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textDark, size: 22),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen()));
                },
              ),
            ),
        ),
      ),
          ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.primaryLight),
                  ),
                  // Lớp phủ gradient mờ ở chân ảnh để bo góc đẹp hơn
                  Positioned(
                    bottom: -1,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      decoration: const BoxDecoration(
                        color: AppColors.background, // SỬA #5
                        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // B. PHẦN THÔNG TIN CHI TIẾT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold), // SỬA #6
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        formatCurrency(widget.product.basePrice),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary, // SỬA #7
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.product.description.isEmpty
                        ? "Hương vị tuyệt vời đánh thức mọi giác quan, mang đến trải nghiệm khó quên..."
                        : widget.product.description,
                    style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textGrey, height: 1.5), // SỬA #8
                  ),
                  const SizedBox(height: 25),

                  _buildSectionTitle("Chọn Size"),
                  const SizedBox(height: 15),
                  Row(
                    children: _sizeOptions.keys.map((size) {
                      bool isSelected = _selectedSize == size;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSize = size),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 15),
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.surface, // SỬA #9
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Size $size",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColors.textDark, // SỬA #10
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 25),

                  // Các lựa chọn đường và đá
                  _buildChoicesSection("Độ ngọt", _sugarOptions, _selectedSugar, (val) => setState(() => _selectedSugar = val)),
                  const SizedBox(height: 25),
                  _buildChoicesSection("Lượng đá", _iceOptions, _selectedIce, (val) => setState(() => _selectedIce = val)),
                  const SizedBox(height: 25),

                  // Chọn Topping
                  _buildSectionTitle("Topping"),
                  const SizedBox(height: 5),
                  ..._toppingOptions.entries.map((entry) {
                    bool isSelected = _selectedToppings.contains(entry.key);
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                      title: Text(entry.key, style: theme.textTheme.bodyLarge),
                      secondary: Text(
                        "+${formatCurrency(entry.value)}",
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) _selectedToppings.add(entry.key);
                          else _selectedToppings.remove(entry.key);
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 120), // Khoảng trống dưới cùng
                ],
              ),
            ),
          ),
        ],
      ),
      // C. THANH BOTTOM BAR
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  // Tách widget con để code sạch hơn
  Widget _buildSectionTitle(String title) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold));
  }

  // Widget chung cho các lựa chọn (đường, đá)
  Widget _buildChoicesSection(String title, List<String> options, String selectedValue, Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 5,
          children: options.map((level) {
            bool isSelected = selectedValue == level;
            return ChoiceChip(
              label: Text(level),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface, // SỬA #12
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textDark, // SỬA #13
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              checkmarkColor: Colors.white,
              onSelected: (selected) {
                if (selected) onSelect(level);
              },
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Widget cho thanh Bottom Bar
  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
      decoration: BoxDecoration(
        color: AppColors.surface, // SỬA #14
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          // Cụm nút Tăng/Giảm số lượng
          Container(
            decoration: BoxDecoration(
              color: AppColors.background, // SỬA #15
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => setState(() { if (_quantity > 1) _quantity--; }),
                  icon: const Icon(Icons.remove, size: 20, color: AppColors.textGrey),
                ),
                Text("$_quantity", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => setState(() => _quantity++),
                  icon: const Icon(Icons.add, size: 20, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),

          // Nút Thêm vào giỏ
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _addToCart();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 2),
                    content: Text(
                      "Đã thêm ${_quantity}x ${widget.product.name} vào giỏ!",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16), // Tăng độ dày nút
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Thêm vào giỏ - ${formatCurrency(_totalPrice)}"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
