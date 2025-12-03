// lib/screens/voucher/widgets/voucher_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dotted_line/dotted_line.dart';
import '../../../models/voucher_model.dart';
import '../../../utils/constants.dart';

class VoucherCard extends StatelessWidget {
  final VoucherModel voucher;
  final bool isUnavailable;

  const VoucherCard({
    super.key,
    required this.voucher,
    this.isUnavailable = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final expiryFormatted = DateFormat('dd/MM/yyyy').format(voucher.expiredAt.toDate());

    // Áp dụng bảng màu mới
    final color = isUnavailable ? AppColors.textLight : AppColors.primaryDark;
    final buttonColor = isUnavailable ? Colors.grey : AppColors.secondary;
    final backgroundColor = isUnavailable ? const Color(0xFFF0F0F0) : AppColors.primary.withOpacity(0.3);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // --- Phần Icon bên trái (ĐÃ LÀM TO HƠN) ---
            Container(
              width: 130, // Tăng chiều rộng
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.confirmation_number, color: color, size: 48), // Icon to hơn
                  const SizedBox(height: 8),
                  Text(
                    voucher.code,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // Chữ to hơn
                    ),
                  ),
                ],
              ),
            ),
            // --- Phần đường cắt ---
            SizedBox(
              width: 20,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned.fill(
                    child: DottedLine(
                      direction: Axis.vertical,
                      lineLength: double.infinity,
                      dashColor: Color(0xFFE0E0E0),
                      dashGapLength: 4,
                      dashLength: 4,
                    ),
                  ),
                  Positioned(
                    top: -10,
                    left: 10,
                    child: CircleAvatar(backgroundColor: const Color(0xFFF4F6F9), radius: 10),
                  ),
                  Positioned(
                    bottom: -10,
                    left: 10,
                    child: CircleAvatar(backgroundColor: const Color(0xFFF4F6F9), radius: 10),
                  ),
                ],
              ),
            ),
            // --- Phần thông tin bên phải ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voucher.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16, // Chữ to hơn
                        fontWeight: FontWeight.bold,
                        color: isUnavailable ? AppColors.textLight : AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Đơn tối thiểu: ${currencyFormatter.format(voucher.minOrder)}',
                      style: const TextStyle(color: AppColors.textLight, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'HSD: $expiryFormatted',
                      style: const TextStyle(color: AppColors.textLight, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: isUnavailable
                            ? null
                            : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã sao chép mã: ${voucher.code}')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10,),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(isUnavailable ? 'Đã hết' : 'Dùng ngay'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
