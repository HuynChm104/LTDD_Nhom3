import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart'; // <--- THÊM IMPORT NÀY

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
    // Lắng nghe provider để lấy trạng thái và dữ liệu mới nhất
    final provider = context.watch<BranchProvider>();
    final selectedBranch = provider.selectedBranch;
    final status = provider.status;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            // Truyền trạng thái mới vào _buildNormalBar
            child: isSearching ? _buildSearchField() : _buildNormalBar(selectedBranch, status),
          ),
        ),
      ),
    );
  }

  // WIDGET NÀY ĐƯỢC NÂNG CẤP ĐỂ HIỂN THỊ ĐÚNG THEO TỪNG TRẠNG THÁI
  Widget _buildNormalBar(BranchModel? branch, BranchStatus status) {
    String displayText;
    Widget leadingIcon;
    bool isClickable = true;
    VoidCallback? onTapAction = () => _showBranchPicker(context);

    switch (status) {
      case BranchStatus.finding:
        displayText = "Đang tìm chi nhánh...";
        leadingIcon = const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDark),
        );
        isClickable = false;
        onTapAction = null; // Không cho bấm khi đang tìm
        break;
      case BranchStatus.foundNearest:
        displayText = branch?.name ?? "Chọn chi nhánh";
        leadingIcon = const Icon(Icons.location_on, size: 18, color: AppColors.primaryDark);
        break;
      case BranchStatus.tooFar:
        displayText = "Bạn ở quá xa, hãy chọn thủ công";
        leadingIcon = const Icon(Icons.warning_amber_rounded, size: 18, color: Colors.orange);
        break;
      case BranchStatus.permissionDenied:
        displayText = "Hãy cấp quyền vị trí";
        leadingIcon = const Icon(Icons.location_off, size: 18, color: Colors.red);
        // Khi bị từ chối, bấm vào sẽ yêu cầu mở cài đặt
        onTapAction = () => _showPermissionDialog(context);
        break;
      case BranchStatus.error:
      // Khi lỗi, bấm vào sẽ thử lại
        displayText = "Lỗi! Bấm để thử lại";
        leadingIcon = const Icon(Icons.error_outline, size: 18, color: Colors.red);
        onTapAction = () => context.read<BranchProvider>().retryInitialization();
        break;
      case BranchStatus.notSelected:
        displayText = "Chọn chi nhánh phục vụ";
        leadingIcon = const Icon(Icons.storefront, size: 18, color: AppColors.primaryDark);
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
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  leadingIcon, // Icon thay đổi linh hoạt
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      displayText, // Text thay đổi linh hoạt
                      style: const TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.black),
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
            // --- SỬA ĐOẠN NÀY: NÚT THÔNG BÁO REALTIME ---
            StreamBuilder<int>(
              stream:
              NotificationService.getUnreadCount(), // Lắng nghe số lượng tin chưa đọc
              builder: (context, snapshot) {
                // Nếu chưa có dữ liệu hoặc lỗi thì hiện số 0
                int unreadCount = snapshot.data ?? 0;

                return _iconButton(
                  Icons.notifications,
                      () {
                    // Chuyển sang màn hình NotificationScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationScreen(),
                      ),
                    );
                  },
                  badge: unreadCount, // Truyền số lượng thật vào đây
                );
              },
            ),
            // ---------------------------------------------
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
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: AppColors.buttonDark),
            ),
            onChanged: (value) {
              widget.onSearch(value);
            },
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => setState(() {
            isSearching = false;
            _controller.clear();
            widget.onSearch('');
          }),
          child: const Icon(Icons.close, color: AppColors.buttonDark),
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
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: AppColors.buttonDark),
          ),
        ),
        if (badge > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
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

  // NÂNG CẤP MODAL CHỌN CHI NHÁNH
  void _showBranchPicker(BuildContext context) {
    // Dùng context.read vì chỉ cần gọi hàm, không cần rebuild khi provider thay đổi
    final provider = context.read<BranchProvider>();
    final allBranches = provider.allBranches;
    final selectedBranchId = provider.selectedBranch?.id;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  // Thêm thông báo nếu người dùng ở quá xa
                  provider.status == BranchStatus.tooFar
                      ? "Bạn ở khá xa chúng tôi!\nVui lòng chọn một chi nhánh để phục vụ."
                      : "Chọn chi nhánh gần bạn",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
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
                      title: Text(branch.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      subtitle: Text(branch.address),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primaryDark)
                          : null,
                      onTap: () {
                        // Khi người dùng bấm chọn, gọi hàm trong provider
                        provider.selectBranch(branch);
                        Navigator.of(ctx).pop(); // Đóng modal
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

  // HÀM MỚI ĐỂ XỬ LÝ KHI NGƯỜI DÙNG TỪ CHỐI QUYỀN
  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cần quyền truy cập vị trí"),
        content: const Text(
          "Bồng Biêng cần vị trí của bạn để tìm chi nhánh gần nhất. Bạn có muốn mở cài đặt để cấp quyền không?",
        ),
        actions: [
          TextButton(child: const Text("Để sau"), onPressed: () => Navigator.of(ctx).pop()),
          TextButton(
            child: const Text("Mở Cài Đặt"),
            onPressed: () {
              openAppSettings(); // Mở thẳng đến cài đặt của ứng dụng
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
