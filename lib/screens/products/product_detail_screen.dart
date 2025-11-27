import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thư viện để format tiền tệ (ví dụ: 10.000đ)
import '../../models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  // Nhận dữ liệu sản phẩm từ màn hình Home gửi sang
  final ProductModel product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // --- 1. KHAI BÁO MÀU SẮC & STYLE ---
  // Màu xanh đậm chủ đạo
  final Color _accentColor = const Color(0xFF87B2DD);
  // Màu chữ tiêu đề đậm
  final Color _darkTextColor = const Color(0xFF2C3E50);

  // --- 2. QUẢN LÝ TRẠNG THÁI (STATE) ---
  // Các biến này sẽ thay đổi khi người dùng thao tác trên màn hình
  String _selectedSize = 'M';          // Mặc định chọn Size M
  String _selectedSugar = '100%';      // Mặc định 100% đường
  String _selectedIce = 'Bình thường'; // Mặc định đá bình thường
  int _quantity = 1;                   // Số lượng mặc định là 1

  // Dùng Set để lưu danh sách topping (Set giúp tránh chọn trùng 1 loại topping 2 lần)
  final Set<String> _selectedToppings = {};

  // --- 3. CẤU HÌNH MENU (Dữ liệu tĩnh) ---
  // Option Size và giá tiền cộng thêm
  final Map<String, double> _sizeOptions = {
    'M': 0,      // Size M giữ nguyên giá
    'L': 10000,  // Size L cộng thêm 10k
  };

  // Các mức đường (Chỉ để chọn, không ảnh hưởng giá)
  final List<String> _sugarOptions = ['0%', '30%', '50%', '70%', '100%', '120%'];

  // Các mức đá
  final List<String> _iceOptions = ['Không đá', 'Ít đá', 'Bình thường'];

  // Danh sách Topping và giá tiền tương ứng
  final Map<String, double> _toppingOptions = {
    'Trân châu (Hoàng kim)': 10000,
    'Ngọc (Trân châu trắng)': 10000,
    'Mây (Kem frappe)': 20000,
    'Kem (Kem phô mai)': 20000,
    'Kem Dẻ Cười': 20000,
  };

  // --- 4. LOGIC TÍNH TỔNG TIỀN ---
  // Công thức: (Giá gốc + Giá Size + Giá Topping) * Số lượng
  double get _totalPrice {
    double sizePrice = _sizeOptions[_selectedSize] ?? 0;

    double toppingPrice = 0;
    for (var topping in _selectedToppings) {
      toppingPrice += _toppingOptions[topping] ?? 0;
    }

    return (widget.product.basePrice + sizePrice + toppingPrice) * _quantity;
  }

  // Hàm tiện ích để hiển thị số tiền đẹp (VD: 50000.0 -> 50.000đ)
  String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Sử dụng Stack để đặt các thành phần chồng lên nhau
      body: Stack(
        children: [
          // Phần nội dung cuộn được (Ảnh + Thông tin)
          CustomScrollView(
            slivers: [
              // A. PHẦN ẢNH SẢN PHẨM (SliverAppBar)
              // Hiệu ứng: Khi cuộn lên thì ảnh thu nhỏ lại, giữ lại thanh tiêu đề
              SliverAppBar(
                expandedHeight: 300, // Chiều cao tối đa của ảnh
                pinned: true,        // Giữ thanh Appbar lại khi cuộn hết
                backgroundColor: _accentColor,
                elevation: 0,
                // Nút Back tròn màu trắng
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Load ảnh từ mạng (hoặc assets nếu lỗi/local)
                      Image.network(
                        widget.product.image.startsWith('http')
                            ? widget.product.image
                            : 'assets/images/${widget.product.image}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: _accentColor.withOpacity(0.3)),
                      ),
                      // Tạo một lớp gradient trắng mờ ở chân ảnh để bo góc đẹp hơn
                      Positioned(
                        bottom: -1,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Colors.white,
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
                      // 1. Tên món và Giá gốc
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.name,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: _darkTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            formatCurrency(widget.product.basePrice),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _accentColor, // Giá tiền dùng màu xanh chủ đạo
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      // 2. Mô tả sản phẩm
                      Text(
                        widget.product.description.isEmpty
                            ? "Hương vị tuyệt vời đánh thức mọi giác quan..." // Fallback nếu DB chưa có mô tả
                            : widget.product.description,
                        style: TextStyle(color: Colors.grey[600], height: 1.5),
                      ),
                      const SizedBox(height: 25),

                      // 3. Chọn Size
                      _buildSectionTitle("Chọn Size"),
                      const SizedBox(height: 10),
                      Row(
                        children: _sizeOptions.keys.map((size) {
                          bool isSelected = _selectedSize == size;
                          double price = _sizeOptions[size]!;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedSize = size),
                            child: Container(
                              // Căn chỉnh khoảng cách các nút
                              margin: const EdgeInsets.only(right: 15),
                              // QUAN TRỌNG: Fix cứng chiều cao để Size M và L bằng nhau
                              height: 50,
                              constraints: const BoxConstraints(minWidth: 90), // Chiều rộng tối thiểu
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              decoration: BoxDecoration(
                                color: isSelected ? _accentColor : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? _accentColor : Colors.transparent,
                                  width: 1.5, // Viền đậm hơn chút khi chọn
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center, // Căn giữa nội dung
                                children: [
                                  Text(
                                    "Size $size",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  // Chỉ hiện giá cộng thêm nếu > 0
                                  if (price > 0)
                                    Text(
                                      " +${price.toInt() ~/ 1000}k",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected ? Colors.white.withValues(alpha: 0.9) : Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 25),

                      // 4. Chọn Đường (Sugar Level) - Dùng ChoiceChip
                      _buildSectionTitle("Độ ngọt (Sugar Level)"),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _sugarOptions.map((level) {
                          bool isSelected = _selectedSugar == level;
                          return ChoiceChip(
                            label: Text(level),
                            selected: isSelected,
                            selectedColor: _accentColor,
                            backgroundColor: Colors.grey[100],
                            // Chỉnh màu chữ khi chọn/không chọn
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedSugar = level);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 25),

                      // 5. Chọn Đá (Ice Level)
                      _buildSectionTitle("Lượng đá (Ice Level)"),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _iceOptions.map((level) {
                          bool isSelected = _selectedIce == level;
                          return ChoiceChip(
                            label: Text(level),
                            selected: isSelected,
                            selectedColor: _accentColor,
                            backgroundColor: Colors.grey[100],
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedIce = level);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 25),

                      // 6. Chọn Topping (Checkbox)
                      _buildSectionTitle("Topping Extra"),
                      const SizedBox(height: 5),
                      Column(
                        children: _toppingOptions.entries.map((entry) {
                          bool isSelected = _selectedToppings.contains(entry.key);
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            activeColor: _accentColor, // Màu tick xanh
                            title: Text(entry.key, style: const TextStyle(fontSize: 15)),
                            secondary: Text(
                              "+${formatCurrency(entry.value)}",
                              style: TextStyle(fontWeight: FontWeight.bold, color: _accentColor),
                            ),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedToppings.add(entry.key); // Thêm vào danh sách
                                } else {
                                  _selectedToppings.remove(entry.key); // Bỏ khỏi danh sách
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),

                      // Khoảng trống dưới cùng để không bị che bởi thanh BottomBar
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // C. THANH BOTTOM BAR (SỐ LƯỢNG & NÚT ĐẶT)
          // Dùng Positioned để ghim xuống đáy màn hình
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                // Tạo bóng mờ phía trên thanh này cho đẹp
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Cụm nút Tăng/Giảm số lượng
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_quantity > 1) setState(() => _quantity--);
                            },
                            icon: const Icon(Icons.remove, size: 20),
                          ),
                          Text(
                            "$_quantity",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _quantity++),
                            icon: const Icon(Icons.add, size: 20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),

                    // Nút Thêm vào giỏ (Nút to)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Sau này sẽ gọi Provider để thêm vào Cart ở đây
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: _accentColor,
                              content: Text(
                                "Đã thêm ${_quantity}x ${widget.product.name} vào giỏ!",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Thêm vào giỏ",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                              ),
                            ),
                            Text(
                              formatCurrency(_totalPrice), // Hiển thị tổng tiền
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget con dùng để vẽ Tiêu đề từng mục (Size, Topping...)
  // Tách ra để code đỡ lặp lại
  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        // Tạo cái vạch màu xanh bên trái tiêu đề
        border: Border(left: BorderSide(color: _accentColor, width: 4)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}