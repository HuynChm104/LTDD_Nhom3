// lib/screens/home/widgets/app_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../models/branch_model.dart';
import '../../../providers/branch_provider.dart';
import '../../../utils/constants.dart';
import '../../../services/notification_service.dart';
import '../../notification/notification_screen.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Function(String) onSearch;
  const CustomAppBar({super.key, required this.onSearch});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool isSearching = false;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BranchProvider>();
    final selectedBranch = provider.selectedBranch;
    final status = provider.status;

    // AppBar đã có theme chung từ main.dart, không cần set màu ở đây
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isSearching ? _buildSearchField() : _buildNormalBar(selectedBranch, status, provider.message),
          ),
        ),
      ),
    );
  }

  Widget _buildNormalBar(BranchModel? branch, BranchStatus status, String message) {
    String displayText;
    Widget leadingIcon;
    bool isClickable = true;
    VoidCallback? onTapAction = () => _showBranchPicker(context);

    // Dùng theme để lấy màu sắc đã định nghĩa
    final theme = Theme.of(context);
    final primaryColor = AppColors.primary; // Màu xanh đậm chủ đạo
    final errorColor = AppColors.error; // Màu đỏ từ theme

    switch (status) {
      case BranchStatus.finding:
        displayText = "Đang tìm chi nhánh...";
        leadingIcon = SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
        );
        isClickable = false;
        onTapAction = null;
        break;
      case BranchStatus.foundNearest:
        displayText = branch?.name ?? "Chọn chi nhánh";
        leadingIcon = Icon(Icons.location_on, size: 18, color: primaryColor);
        break;
      case BranchStatus.permissionDenied:
        displayText = message.isNotEmpty ? message : "Hãy cấp quyền vị trí";
        leadingIcon = Icon(Icons.location_off, size: 18, color: errorColor);
        onTapAction = () => _showPermissionDialog(context);
        break;
      case BranchStatus.error:
        displayText = message.isNotEmpty ? message : "Lỗi! Bấm để thử lại";
        leadingIcon = Icon(Icons.error_outline, size: 18, color: errorColor);
        onTapAction = () => context.read<BranchProvider>().retryInitialization();
        break;
      case BranchStatus.notSelected:
        displayText = message.isNotEmpty ? message : "Chọn chi nhánh phục vụ";
        leadingIcon = Icon(Icons.storefront, size: 18, color: primaryColor);
        break;
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: isClickable ? onTapAction : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                // SỬA MÀU #1: Dùng màu xanh nhạt từ constants
                color: AppColors.primaryLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  leadingIcon,
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      displayText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        // SỬA MÀU #2: Dùng màu text từ constants
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // SỬA MÀU #3: Dùng màu text từ constants
                  const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textDark),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        Row(
          children: [
            _iconButton(Icons.search, () => setState(() => isSearching = true)),
            const SizedBox(width: 12),
            StreamBuilder<int>(
              stream: NotificationService.getUnreadCount(),
              builder: (context, snapshot) {
                int unreadCount = snapshot.data ?? 0;
                return _iconButton(
                  Icons.notifications,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationScreen()),
                    );
                  },
                  badge: unreadCount,
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Tìm kiếm sản phẩm...",
              filled: true,
              // SỬA MÀU #4: Dùng màu nền từ constants
              fillColor: AppColors.surface,
              hintStyle: const TextStyle(color: AppColors.textGrey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              // SỬA MÀU #5: Dùng màu chủ đạo từ constants
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            ),
            onChanged: widget.onSearch,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => setState(() {
            isSearching = false;
            _controller.clear();
            widget.onSearch('');
          }),
          // SỬA MÀU #6: Dùng màu chủ đạo từ constants
          child: const Icon(Icons.close, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap, {int badge = 0}) {
    return Stack(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              // SỬA MÀU #7: Dùng màu nền từ constants
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            // SỬA MÀU #8: Dùng màu chủ đạo từ constants
            child: Icon(icon, size: 22, color: AppColors.primary),
          ),
        ),
        if (badge > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.error, // Dùng màu lỗi từ constants
                shape: BoxShape.circle,
              ),
              child: Text(
                badge.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showBranchPicker(BuildContext context) {
    final provider = context.read<BranchProvider>();
    final allBranches = provider.allBranches;
    final selectedBranchId = provider.selectedBranch?.id;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      // SỬA MÀU #9: Dùng màu nền từ constants
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                // Sử dụng style từ theme
                child: Text("Chọn chi nhánh gần bạn", style: theme.textTheme.headlineSmall),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allBranches.length,
                  itemBuilder: (_, index) {
                    final branch = allBranches[index];
                    final isSelected = branch.id == selectedBranchId;
                    return ListTile(
                      title: Text(
                        branch.name,
                        style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.primary : AppColors.textDark),
                      ),
                      subtitle: Text(branch.address, style: const TextStyle(color: AppColors.textGrey)),
                      trailing: isSelected
                      // SỬA MÀU #10: Dùng màu chủ đạo từ constants
                          ? const Icon(Icons.check_circle, color: AppColors.primary)
                          : null,
                      onTap: () {
                        provider.selectBranch(branch);
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPermissionDialog(BuildContext context) {
    // AlertDialog sẽ tự động lấy style từ theme chung trong main.dart
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cần quyền truy cập vị trí"),
        content: const Text("Bồng Biêng cần vị trí của bạn để tìm chi nhánh gần nhất. Bạn có muốn mở cài đặt để cấp quyền không?"),
        actions: [
          TextButton(child: const Text("Để sau"), onPressed: () => Navigator.of(ctx).pop()),
          TextButton(
            child: const Text("Mở Cài Đặt"),
            onPressed: () {
              openAppSettings();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
