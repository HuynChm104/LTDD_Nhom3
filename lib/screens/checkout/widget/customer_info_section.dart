import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../models/branch_model.dart';

class CustomerInfoSection extends StatelessWidget {
  final int deliveryType;
  final TextEditingController nameController, phoneController, addressController, noteController;
  final List<BranchModel> branches;
  final String? selectedBranchId;
  final Function(String?) onBranchChanged;
  final bool isLocating;
  final VoidCallback onLocate;

  const CustomerInfoSection({
    Key? key, required this.deliveryType, required this.nameController,
    required this.phoneController, required this.addressController,
    required this.noteController, required this.branches,
    this.selectedBranchId, required this.onBranchChanged,
    required this.isLocating, required this.onLocate
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Thông tin khách hàng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          _buildField(nameController, "Họ và tên", Icons.person_outline),
          const SizedBox(height: 12),
          _buildField(phoneController, "Số điện thoại", Icons.phone_android_outlined, type: TextInputType.phone),
          const SizedBox(height: 12),
          if (deliveryType == 0)
            Row(
              children: [
                Expanded(child: _buildField(addressController, "Địa chỉ nhận hàng", Icons.location_on_outlined)),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: isLocating ? null : onLocate,
                  icon: isLocating ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location, color: AppColors.primary),
                )
              ],
            )
          else
            DropdownButtonFormField<String>(
              value: selectedBranchId,
              decoration: _inputDeco("Chọn chi nhánh", Icons.store_outlined),
              items: branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
              onChanged: onBranchChanged,
            ),
          const SizedBox(height: 12),
          _buildField(noteController, "Ghi chú (Ví dụ: Ít đường, ít đá...)", Icons.edit_note_outlined),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      decoration: _inputDeco(hint, icon),
      style: const TextStyle(fontSize: 14),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 20, color: AppColors.textGrey),
      hintText: hint,
      filled: true, fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }
}