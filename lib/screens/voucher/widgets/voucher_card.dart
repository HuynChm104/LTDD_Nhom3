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
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final expiryFormatted = DateFormat('dd/MM/yyyy').format(voucher.expiredAt.toDate());

    // --- SỬA #1: Định nghĩa lại các màu sắc cho rõ ràng và nhất quán ---
    // Màu cho các nội dung chính (icon, text)
    final Color contentColor = isUnavailable ? AppColors.textLight : AppColors.primary;
    // Màu nền cho phần icon bên trái
    final Color leftBackgroundColor = isUnavailable ? const Color(0xFFF5F5F5) : AppColors.primaryLight;
    // Màu nền của toàn bộ card
    const Color cardBackgroundColor = AppColors.surface;
    // Màu nền của nút bấm
    final Color buttonBackgroundColor = isUnavailable ? AppColors.textLight : AppColors.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
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
            // --- Phần Icon bên trái ---
            Container(
              width: 120, // Giảm một chút cho cân đối
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              decoration: BoxDecoration(
                color: leftBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.confirmation_num_outlined, color: contentColor, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    voucher.code,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: contentColor,
                      fontWeight: FontWeight.bold,
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
                alignment: Alignment.center,
                children: [
                  // SỬA #2: Dùng màu từ constants
                  const Positioned.fill(
                    child: DottedLine(
                      direction: Axis.vertical,
                      lineLength: double.infinity,
                      dashColor: AppColors.primaryLight,
                      dashGapLength: 4,
                      dashLength: 4,
                    ),
                  ),
                  Positioned(
                    top: -10,
                    child: CircleAvatar(backgroundColor: cardBackgroundColor, radius: 10),
                  ),
                  Positioned(
                    bottom: -10,
                    child: CircleAvatar(backgroundColor: cardBackgroundColor, radius: 10),
                  ),
                ],
              ),
            ),

            // --- Phần thông tin bên phải ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      voucher.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      // SỬA #3: Sử dụng style từ theme
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isUnavailable ? AppColors.textLight : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đơn tối thiểu: ${currencyFormatter.format(voucher.minOrder)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'HSD: $expiryFormatted',
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
                    ),
                    const Spacer(), // Đẩy nút xuống dưới cùng
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: isUnavailable ? null : () {
                          // TODO: Xử lý sao chép mã và thông báo
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã sao chép mã: ${voucher.code}')),
                          );
                        },
                        // SỬA #4: Tùy chỉnh lại style của nút
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonBackgroundColor,
                          disabledBackgroundColor: AppColors.textLight.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: theme.textTheme.labelLarge,
                        ).copyWith(
                          // Ghi đè style từ theme chung để có nút nhỏ hơn
                          minimumSize: MaterialStateProperty.all(const Size(0, 36)),
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
