import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/constants.dart';

class PaymentSummarySection extends StatelessWidget {
  final double subtotal, shippingFee, discount, total;

  const PaymentSummarySection({
    Key? key, required this.subtotal, required this.shippingFee, required this.discount, required this.total
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _BaseSection(
      title: "Chi tiết thanh toán",
      child: Column(
        children: [
          _row("Tạm tính", subtotal),
          _row("Phí vận chuyển", shippingFee, isFree: shippingFee == 0),
          if (discount > 0)
            _row("Giảm giá", -discount, isDiscount: true),

          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tổng cộng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(total),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double val, {bool isFree = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGrey)),
          Text(
            isFree ? "Miễn phí" : NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(val),
            style: TextStyle(
                color: isDiscount ? AppColors.error : (isFree ? AppColors.success : AppColors.textDark),
                fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }
}

class _BaseSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _BaseSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}