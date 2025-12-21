// lib/screens/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bongbieng_app/providers/auth_provider.dart';
import 'package:bongbieng_app/models/user_model.dart';
import 'package:bongbieng_app/utils/constants.dart';
import 'package:flutter/services.dart';

class EditProfileScreen extends StatefulWidget {
  // Nhận UserModel để biết dữ liệu cũ
  final UserModel currentUser;
  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController; // THÊM: Controller cho địa chỉ

  @override
  void initState() {
    super.initState();
    // SỬA: Điền dữ liệu từ `widget.currentUser` (UserModel) vào các ô
    _nameController = TextEditingController(text: widget.currentUser.name);
    _phoneController = TextEditingController(text: widget.currentUser.phone);
    _addressController = TextEditingController(text: widget.currentUser.address); // THÊM: Khởi tạo cho địa chỉ
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose(); // THÊM: Dispose controller địa chỉ
    super.dispose();
  }

  // SỬA: Cập nhật lại toàn bộ hàm này
  Future<void> _handleSaveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();

    // Gọi hàm `updateUserProfile` với đầy đủ tham số
    final success = await authProvider.updateUserProfile(
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(), // THÊM: Truyền địa chỉ vào hàm
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Cập nhật hồ sơ thành công!' : (authProvider.errorMessage ?? 'Cập nhật thất bại.')),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bool isLoading = authProvider.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chỉnh Sửa Hồ Sơ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Email", style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textGrey)),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: widget.currentUser.email,
                readOnly: true,
                style: const TextStyle(color: AppColors.textGrey),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text("Tên hiển thị", style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Nhập tên của bạn',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tên hiển thị không được để trống';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text("Số điện thoại", style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  LengthLimitingTextInputFormatter(15),
                ],
                decoration: const InputDecoration(
                  hintText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  // Nếu để trống hoặc chỉ có khoảng trắng thì hợp lệ
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }
                  // Nếu đã nhập thì phải kiểm tra độ dài
                  if (value.trim().length < 7) {
                    return 'Số điện thoại không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // THÊM: Trường nhập địa chỉ
              Text("Địa chỉ", style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'Địa chỉ giao hàng',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) {
                  // Cho phép để trống địa chỉ
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }
                  // Nếu nhập thì nên nhập dài hơn 5 ký tự để có ý nghĩa
                  if (value.trim().length < 5) {
                    return 'Nhập địa chỉ chi tiết hơn nhé!';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: isLoading ? null : _handleSaveChanges,
                child: isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
                    : const Text('Lưu thay đổi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
