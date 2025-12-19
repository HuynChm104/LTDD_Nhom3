import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/order_model.dart';
import '../../../../utils/constants.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Chi tiết đơn hàng",
            style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primaryLight,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatusHeader(),
            _buildAddressSection(),
            _buildItemsSection(priceFormat), // Phần chứa thông tin Topping/Đường/Đá
            _buildPaymentSummary(priceFormat),
            _buildOrderInfo(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 1. Header Trạng thái (Giữ nguyên)
  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          Icon(
            order.status == 'completed' ? Icons.check_circle : Icons.local_shipping,
            color: AppColors.primary, size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            _getStatusText(order.status).toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text("Mã đơn: ${order.id}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }

  // 2. Địa chỉ (Giữ nguyên)
  Widget _buildAddressSection() {
    return _buildSection(
      title: "Thông tin giao hàng",
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text(order.customerPhone, style: const TextStyle(color: AppColors.textGrey)),
          const SizedBox(height: 4),
          Text(order.address, style: const TextStyle(color: AppColors.textGrey)),
        ],
      ),
    );
  }

  // 3. DANH SÁCH MÓN ĂN - CẬP NHẬT ẢNH VÀ THÔNG TIN CHI TIẾT
  Widget _buildItemsSection(NumberFormat format) {
    return _buildSection(
      title: "Sản phẩm đã chọn",
      icon: Icons.coffee_outlined,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: order.items.length,
        separatorBuilder: (_, __) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final item = order.items[index];

          // Lấy thông tin topping, đường, đá từ map
          final String sugar = item['sugar'] ?? '100% đường';
          final String ice = item['ice'] ?? '100% đá';
          final List<dynamic> toppings = item['toppings'] ?? [];

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SỬA LỖI ẢNH: Kiểm tra key 'picture' hoặc 'image'
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item['picture'] ?? item['image'] ?? '',
                  width: 70, height: 70, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      width: 70, height: 70, color: Colors.grey[100],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey)
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['productName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text("Size: ${item['size']} x ${item['quantity']}", style: const TextStyle(color: AppColors.textDark, fontSize: 13)),

                    // HIỂN THỊ ĐƯỜNG, ĐÁ, TOPPING
                    const SizedBox(height: 4),
                    Text("Tùy chọn: $sugar, $ice", style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic)),
                    if (toppings.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                            "Topping: ${toppings.join(', ')}",
                            style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic)
                        ),
                      ),
                  ],
                ),
              ),
              Text(format.format((item['price'] ?? 0) * (item['quantity'] ?? 1)), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          );
        },
      ),
    );
  }

  // 4. Thanh toán (Giữ nguyên)
  Widget _buildPaymentSummary(NumberFormat format) {
    return _buildSection(
      title: "Chi tiết thanh toán",
      icon: Icons.payment_outlined,
      child: Column(
        children: [
          _buildPriceRow("Tạm tính", format.format(order.subtotal)),
          _buildPriceRow("Phí vận chuyển", format.format(order.shippingFee)),
          if (order.discountAmount > 0)
            _buildPriceRow("Giảm giá", "-${format.format(order.discountAmount)}", isDiscount: true),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tổng cộng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(format.format(order.totalAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  // 5. Thông tin khác (Giữ nguyên)
  Widget _buildOrderInfo() {
    return _buildSection(
      title: "Thông tin khác",
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildInfoRow("Phương thức", order.paymentMethod.toUpperCase()),
          _buildInfoRow("Thanh toán", order.isPaid ? "Đã thanh toán" : "Chưa thanh toán"),
          _buildInfoRow("Ghi chú", "Không có"),
        ],
      ),
    );
  }

  // Các Helper Widgets (Giữ nguyên)
  Widget _buildSection({required String title, required IconData icon, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
          child,
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGrey)),
          Text(value, style: TextStyle(color: isDiscount ? Colors.green : AppColors.textDark, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGrey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'processing': return "Đang xử lý";
      case 'shipping': return "Đang giao hàng";
      case 'completed': return "Đã hoàn thành";
      case 'cancelled': return "Đã hủy đơn";
      case 'waiting_confirm': return "Chờ xác nhận";
      default: return "Đang xử lý";
    }
  }
}