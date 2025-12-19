// lib/screens/voucher/voucher_screen.dart
import 'package:flutter/material.dart';
import '../../models/voucher_model.dart';
import '../../services/voucher_service.dart';
import '../../utils/constants.dart';
import 'widgets/voucher_card.dart';

class VoucherScreen extends StatelessWidget {
  // Thêm tham số này để biết có phải đang chọn voucher cho checkout không
  final bool isSelectionMode;

  const VoucherScreen({super.key, this.isSelectionMode = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(isSelectionMode ? 'Chọn Voucher' : 'Kho Voucher'),
          backgroundColor: AppColors.primaryLight,
        ),
        body: Column(
          children: [
            Container(
              color: AppColors.surface,
              child: TabBar(
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textGrey,
                tabs: const [
                  Tab(text: 'Có thể dùng'),
                  Tab(text: 'Hết hiệu lực'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildVoucherList(context, VoucherService.getAvailableVouchers()),
                  _buildVoucherList(context, VoucherService.getUnavailableVouchers(), isUnavailable: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherList(BuildContext context, Stream<List<VoucherModel>> stream, {bool isUnavailable = false}) {
    return StreamBuilder<List<VoucherModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có voucher nào.'));
        }

        final vouchers = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: vouchers.length,
          itemBuilder: (context, index) {
            final voucher = vouchers[index];
            return GestureDetector(
              onTap: () {
                // LOGIC QUAN TRỌNG: Nếu đang chọn và voucher còn hạn -> Trả về data
                if (isSelectionMode && !isUnavailable) {
                  Navigator.pop(context, voucher);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: VoucherCard(voucher: voucher, isUnavailable: isUnavailable),
              ),
            );
          },
        );
      },
    );
  }
}
