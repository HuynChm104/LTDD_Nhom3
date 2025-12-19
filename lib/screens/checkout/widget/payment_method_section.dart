import 'package:flutter/material.dart';
import '../../../../utils/constants.dart';

class PaymentMethodSection extends StatelessWidget {
  final String selectedMethod; // 'cod', 'banking', hoặc 'zalopay'
  final ValueChanged<String> onChanged;

  const PaymentMethodSection({
    Key? key,
    required this.selectedMethod,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Phương thức thanh toán",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),

          // 1. Tiền mặt
          _buildMethodItem(
            id: 'cod',
            title: "Tiền mặt (COD)",
            subtitle: "Thanh toán khi nhận hàng",
            icon: Icons.payments_outlined,
          ),
          const Divider(height: 1),

          // 2. Chuyển khoản ngân hàng
          _buildMethodItem(
            id: 'banking',
            title: "Chuyển khoản ngân hàng",
            subtitle: "Quét mã VietQR để thanh toán",
            icon: Icons.account_balance_outlined,
          ),
          const Divider(height: 1),

          // 3. ZaloPay
          _buildMethodItem(
            id: 'zalopay',
            title: "Ví điện tử ZaloPay",
            subtitle: "Thanh toán qua ứng dụng ZaloPay",
            icon: Icons.account_balance_wallet_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildMethodItem({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    bool isSelected = selectedMethod == id;
    return InkWell(
      onTap: () => onChanged(id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textGrey,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : AppColors.textDark,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: id,
              groupValue: selectedMethod,
              onChanged: (val) => onChanged(val!),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}