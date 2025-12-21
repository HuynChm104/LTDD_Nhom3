import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../utils/constants.dart';
import '../profile/toi/myorders/order_history_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderModel order;

  const OrderSuccessScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // Logic xác định loại đơn hàng dựa trên chuỗi địa chỉ
// SỬA LOGIC TẠI ĐÂY
    bool isPickUp = order.address != null &&
        (!order.address.contains(',') || order.address == "Tại quán");

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Thành công
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 24),
              const Text(
                "Đặt hàng thành công!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Cảm ơn bạn đã tin tưởng Bông Biêng Coffee.\nĐơn hàng của bạn đang được xử lý.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),

              // Khung thông tin đơn hàng tóm tắt
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildInfoRow("Mã đơn hàng", order.id),
                    _buildInfoRow("Tổng tiền", NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(order.totalAmount)),
                    _buildInfoRow("Thanh toán", order.paymentMethod.toUpperCase()),
                    _buildInfoRow(
                        isPickUp ? "Nhận tại chi nhánh" : "Địa chỉ giao hàng",
                        order.address ?? "Không có thông tin"
                    ),

                    _buildInfoRow("Trạng thái", "Đang xử lý")
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Nút bấm điều hướng
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Về trang chủ và xóa hết các màn hình trước đó
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "VỀ TRANG CHỦ",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // TODO: Chuyển hướng đến màn hình Lịch sử đơn hàng
                  Navigator.push(context, MaterialPageRoute(builder: (_) => OrderHistoryScreen()));
                },
                child: const Text(
                  "Xem lịch sử đơn hàng",
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(width: 20),
          Expanded( // Dùng Expanded để chữ tự động xuống dòng nếu quá dài
            child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14)
            ),
          ),
        ],
      ),
    );
  }
}