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
    // Sử dụng DefaultTabController để quản lý các tab
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.primary, // Nền xanh nhạt cho toàn màn hình
        appBar: AppBar(
          /*title: const Text(
            'Kho Voucher',
            style: TextStyle(
              color: AppColors.primaryDark, // Chữ màu xanh đậm
              fontWeight: FontWeight.bold,
            ),
          ),*/
          backgroundColor: AppColors.primary, // AppBar màu xanh nhạt
          elevation: 0,
          automaticallyImplyLeading: false, // Ẩn nút back
          centerTitle: true, // Căn giữa tiêu đề cho đẹp
        ),
        body: Column(
          children: [
            // --- THANH LỌC (TABBAR) MỚI ---
            Container(
              color: Colors.white, // Giữ nền xanh nhạt cho thanh lọc
              child: const TabBar(
                indicatorColor: AppColors.primaryDark, // Màu của thanh trượt bên dưới
                labelColor: AppColors.primaryDark, // Màu chữ của tab được chọn
                unselectedLabelColor: AppColors.textLight, // Màu chữ của tab không được chọn
                indicatorWeight: 3.0, // Làm thanh trượt dày hơn
                tabs: [
                  Tab(text: 'Có thể dùng'),
                  Tab(text: 'Hết hiệu lực'),
                ],
              ),
            ),
            // --- DANH SÁCH VOUCHER ---
            Expanded(
              child: Container(
                color: AppColors.white, // Nền trắng cho khu vực danh sách
                child: TabBarView(
                  children: [
                    // Tab 1: Voucher còn hạn
                    _buildVoucherList(VoucherService.getAvailableVouchers()),
                    // Tab 2: Voucher hết hạn
                    _buildVoucherList(VoucherService.getUnavailableVouchers(), isUnavailable: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget chung để hiển thị danh sách voucher (không thay đổi logic)
  Widget _buildVoucherList(Stream<List<VoucherModel>> stream, {bool isUnavailable = false}) {
    return StreamBuilder<List<VoucherModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Sử dụng màu xanh đậm cho vòng xoay
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_offer_outlined, size: 60, color: AppColors.textLight),
                SizedBox(height: 16),
                Text('Bạn không có voucher nào ở đây.'),
              ],
            ),
          );
        }

        final vouchers = snapshot.data!;
        // Thêm một lớp nền để có khoảng cách với mép
        return Container(
          color: const Color(0xFFF4F6F9), // Màu nền xám rất nhạt
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: vouchers.length,
            itemBuilder: (context, index) {
              return VoucherCard(voucher: vouchers[index], isUnavailable: isUnavailable);
            },
          ),
        );
      },
    );
  }
}
