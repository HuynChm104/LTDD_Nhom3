import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../models/voucher_model.dart';

class VoucherSection extends StatelessWidget {
  final VoucherModel? selectedVoucher;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const VoucherSection({Key? key, this.selectedVoucher, required this.onTap, required this.onRemove}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.confirmation_number_outlined, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedVoucher == null ? "Chọn mã khuyến mãi" : "Đã áp dụng: ${selectedVoucher!.code}",
                style: TextStyle(color: selectedVoucher == null ? AppColors.textGrey : AppColors.primary, fontWeight: selectedVoucher != null ? FontWeight.bold : FontWeight.normal),
              ),
            ),
            if (selectedVoucher != null)
              IconButton(onPressed: onRemove, icon: const Icon(Icons.cancel, size: 20, color: AppColors.textGrey))
            else
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}