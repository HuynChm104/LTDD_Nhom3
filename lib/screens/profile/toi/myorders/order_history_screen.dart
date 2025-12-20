import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../models/order_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/order_provider.dart';
import '../../../../utils/constants.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const Scaffold(body: Center(child: Text("Vui lòng đăng nhập")));

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text("Đơn hàng của tôi", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.primaryLight,
          centerTitle: true,
          bottom: TabBar(
            // SỬA: Bật scrollable và căn lề start để tab đầu tiên sát lề trái
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textGrey,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "Chờ xác nhận"),
              Tab(text: "Đang giao hàng"),
              Tab(text: "Đã hoàn thành"),
              Tab(text: "Hủy"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrderListByStatusTab(userId: user.id, statuses: ['processing', 'waiting_confirm']),
            _OrderListByStatusTab(userId: user.id, statuses: ['shipping']),
            _OrderListByStatusTab(userId: user.id, statuses: ['completed']),
            _OrderListByStatusTab(userId: user.id, statuses: ['cancelled']),
          ],
        ),
      ),
    );
  }
}

class _OrderListByStatusTab extends StatelessWidget {
  final String userId;
  final List<String> statuses;

  const _OrderListByStatusTab({required this.userId, required this.statuses});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
      stream: context.read<OrderProvider>().getOrdersStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        }

        final orders = snapshot.data?.where((o) => statuses.contains(o.status)).toList() ?? [];

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text("Không có đơn hàng nào", style: TextStyle(color: Colors.grey[400])),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (context, index) => _OrderCard(order: orders[index]),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

// Trong hàm _handleCancel của file order_history_screen.dart

  void _handleCancel(BuildContext context) {
    // Điều kiện thanh toán online
    bool isOnlinePayment = order.paymentMethod == 'zalopay' || order.paymentMethod == 'banking';
    // Điều kiện đã trả tiền
    bool showRefundNote = order.isPaid && isOnlinePayment;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận hủy đơn"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Bạn có chắc chắn muốn hủy đơn hàng này không?"),
            if (showRefundNote) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "⚠️ Lưu ý: Đơn hàng đã thanh toán. Tiền sẽ được hoàn trả tự động vào tài khoản của bạn.",
                  style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ]
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ĐÓNG")),
          TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await context.read<OrderProvider>().cancelOrder(order);
              },
              child: const Text("HỦY ĐƠN", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    bool canCancel = order.status == 'processing' || order.status == 'waiting_confirm';

    int totalItems = 0;
    for (var item in order.items) {
      totalItems += (item['quantity'] as num? ?? 0).toInt();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Đơn hàng: ${order.id.length > 12 ? order.id.substring(0, 12) : order.id}...",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Thanh toán: ${order.paymentMethod.toUpperCase()}",
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])
                ),
                Text(
                    order.isPaid ? "● Đã thanh toán" : "● Chưa thanh toán",
                    style: TextStyle(
                        color: order.isPaid ? Colors.green : Colors.orange,
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    )
                ),
              ],
            ),
            const Divider(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                        "$totalItems sản phẩm",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)
                    ),
                  ],
                ),
                Text(
                    priceFormat.format(order.totalAmount),
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 17
                    )
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dòng nút bấm hành động - SỬA: Thu nhỏ padding và height
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 38, // Giảm chiều cao nút
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.zero, // Loại bỏ padding mặc định để chữ không bị che
                      ),
                      child: const Text("XEM CHI TIẾT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ),

                if (canCancel) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 38, // Giảm chiều cao nút
                      child: OutlinedButton(
                        onPressed: () => _handleCancel(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text("HỦY ĐƠN", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ),
                ],
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'shipping': color = Colors.blue; label = "Đang giao hàng"; break;
      case 'completed': color = Colors.green; label = "Đã hoàn thành"; break;
      case 'cancelled': color = Colors.red; label = "Đã hủy"; break;
      case 'waiting_confirm': color = Colors.orange; label = "Chờ xác nhận"; break;
      default: color = Colors.orange; label = "Đang xử lý";
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }


}