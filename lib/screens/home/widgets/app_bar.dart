import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final branch = context.watch<BranchProvider>().nearestBranch;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isSearching ? _buildSearchField() : _buildNormalBar(branch),
          ),
        ),
      ),
    );
  }

  Widget _buildNormalBar(BranchModel? branch) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: () => _showBranchPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: AppColors.primaryDark,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      branch?.name ?? '',
                      style: const TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppColors.black,
                  ),
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
            //_iconButton(Icons.notifications, () => Navigator.pushNamed(context, '/notifications'), badge: 3),
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

  void _showBranchPicker(BuildContext context) {
    // Modal như trước
  }
}
