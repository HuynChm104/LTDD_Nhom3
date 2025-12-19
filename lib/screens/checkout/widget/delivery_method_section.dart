import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class DeliveryMethodSection extends StatelessWidget {
  final int selectedType;
  final ValueChanged<int> onChanged;

  const DeliveryMethodSection({Key? key, required this.selectedType, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildItem(0, "Giao hàng", Icons.delivery_dining),
          const SizedBox(width: 12),
          _buildItem(1, "Tại quán", Icons.storefront),
        ],
      ),
    );
  }

  Widget _buildItem(int index, String label, IconData icon) {
    bool isSelected = selectedType == index;
    return Expanded(
      child: InkWell(
        onTap: () => onChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.05) : AppColors.white,
            border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : AppColors.textGrey),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textDark, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }
}