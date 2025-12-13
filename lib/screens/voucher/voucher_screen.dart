// lib/screens/voucher/voucher_screen.dart
import 'package:flutter/material.dart';
import '../../models/voucher_model.dart';
import '../../services/voucher_service.dart';
import '../../utils/constants.dart';
import 'widgets/voucher_card.dart';

class VoucherScreen extends StatelessWidget {
  const VoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Sử dụng DefaultTabController để quản lý các tab
    return DefaultTabController(
      length: 2, // Số lượng tab
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primaryLight,
          shadowColor: AppColors.textLight.withOpacity(0.5),
        ),

        // SỬA #2: ĐƯA TABBAR VÀ TABBARVIEW VÀO TRONG BODY
        body: Column(
          children: [
            // --- Widget TabBar được đặt ở đây ---
            Container(
              color: AppColors.surface, // Màu nền cho khu vực TabBar
              child: TabBar(
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textGrey,
                indicatorWeight: 3.0,
                labelStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Có thể dùng'),
                  Tab(text: 'Hết hiệu lực'),
                ],
              ),
            ),

            // --- Phần nội dung của các tab ---
            // Expanded để TabBarView chiếm hết phần không gian còn lại
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Voucher còn hạn
                  _buildVoucherList(context, VoucherService.getAvailableVouchers()),
                  // Tab 2: Voucher hết hạn
                  _buildVoucherList(context, VoucherService.getUnavailableVouchers(), isUnavailable: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget chung để hiển thị danh sách voucher (Không thay đổi)
  Widget _buildVoucherList(BuildContext context, Stream<List<VoucherModel>> stream, {bool isUnavailable = false}) {
    final theme = Theme.of(context);

    return StreamBuilder<List<VoucherModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}', style: const TextStyle(color: AppColors.error)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_offer_outlined, size: 60, color: AppColors.textLight),
                const SizedBox(height: 16),
                Text(
                  'Bạn không có voucher nào ở đây.',
                  style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textGrey),
                ),
              ],
            ),
          );
        }

        final vouchers = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0), // Bỏ padding dưới
          itemCount: vouchers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: VoucherCard(voucher: vouchers[index], isUnavailable: isUnavailable),
            );
          },
        );
      },
    );
  }
}
