// lib/providers/branch_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/branch_model.dart';
import '../services/branch_service.dart';

/// Enum để thể hiện các trạng thái của việc tìm kiếm, giúp giao diện
/// biết phải hiển thị gì.
enum BranchStatus {
  finding,          // Đang tìm vị trí và chi nhánh (hiện loading...)
  foundNearest,     // Đã tìm thấy chi nhánh gần nhất (hiện tên chi nhánh)
  // tooFar,        // Trạng thái này không còn được sử dụng
  notSelected,      // Người dùng đã bỏ qua, hoặc chưa chọn chi nhánh
  permissionDenied, // Người dùng từ chối quyền vị trí
  error,            // Có lỗi xảy ra
}

class BranchProvider with ChangeNotifier {
  // --- STATE VARIABLES ---

  List<BranchModel> _allBranches = [];
  BranchModel? _selectedBranch;
  BranchStatus _status = BranchStatus.finding; // Trạng thái ban đầu luôn là "Đang tìm"
  String _message = ''; // Dùng để chứa thông báo lỗi hoặc cảnh báo

  // --- GETTERS (để UI có thể đọc dữ liệu) ---

  /// Danh sách TẤT CẢ chi nhánh để người dùng có thể chọn thủ công.
  List<BranchModel> get allBranches => _allBranches;

  /// Chi nhánh ĐANG ĐƯỢC CHỌN (có thể do tự động tìm hoặc người dùng tự chọn).
  /// UI sẽ luôn hiển thị chi nhánh này.
  BranchModel? get selectedBranch => _selectedBranch;

  /// Trạng thái hiện tại của provider.
  BranchStatus get status => _status;

  /// Thông báo đi kèm (ví dụ: "Lỗi định vị",...).
  String get message => _message;

  /// Hàm khởi tạo, được gọi ngay khi provider được tạo ra trong `main.dart`.
  BranchProvider() {
    // Bắt đầu toàn bộ quy trình một cách tự động.
    _initialize();
  }

  // --- PUBLIC METHODS (để UI có thể gọi) ---

  /// Hàm cho phép người dùng tự chọn một chi nhánh từ danh sách.
  void selectBranch(BranchModel branch) {
    _selectedBranch = branch;
    // Khi người dùng đã chủ động chọn, trạng thái sẽ là foundNearest
    // vì đã có một chi nhánh được xác định để phục vụ.
    _updateStatus(BranchStatus.foundNearest);
  }

  /// Cho phép UI có thể kích hoạt lại quá trình tìm kiếm (ví dụ khi có lỗi).
  Future<void> retryInitialization() async {
    _status = BranchStatus.finding;
    notifyListeners();
    await _initialize();
  }

  // --- PRIVATE LOGIC ---

  /// Quy trình khởi tạo chính: Lấy danh sách chi nhánh và tìm vị trí.
  Future<void> _initialize() async {
    try {
      // Tải danh sách tất cả chi nhánh trước.
      _allBranches = await BranchService.getAllBranches();
      if (_allBranches.isEmpty) {
        throw Exception("Không có chi nhánh nào trong hệ thống.");
      }
      // Sau khi có danh sách, bắt đầu tìm chi nhánh gần nhất.
      await _findAndSetNearestBranch();
    } catch (e) {
      _updateStatus(BranchStatus.error, "Lỗi: ${e.toString()}");
    }
  }

  /// Logic cốt lõi: xin quyền, lấy vị trí, và LUÔN ĐỀ XUẤT chi nhánh gần nhất.
  Future<void> _findAndSetNearestBranch() async {
    // 1. Kiểm tra và xin quyền vị trí.
    final permissionStatus = await Permission.location.request();
    if (!permissionStatus.isGranted) {
      // Nếu không có quyền, chọn tạm chi nhánh đầu tiên để app tiếp tục chạy
      _handleLocationError(
          BranchStatus.permissionDenied,
          "Vui lòng cấp quyền vị trí để tìm chi nhánh gần nhất."
      );
      return;
    }

    // 2. Lấy vị trí hiện tại của người dùng.
    try {
      final Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), // Tránh treo nếu không lấy được vị trí
      );

      // 3. Tìm chi nhánh gần nhất từ danh sách _allBranches
      // Đảm bảo _allBranches không rỗng (đã được kiểm tra ở _initialize)
      BranchModel? nearestBranch = _allBranches.first;
      double minDistance = double.infinity;

      for (final branch in _allBranches) {
        final distance = branch.distanceTo(userPosition.latitude, userPosition.longitude);
        if (distance < minDistance) {
          minDistance = distance;
          nearestBranch = branch;
        }
      }

      // 4. LUÔN LUÔN ĐỀ XUẤT CHI NHÁNH GẦN NHẤT
      // Bất kể khoảng cách xa hay gần, chỉ cần tìm được là sẽ chọn.
      _selectedBranch = nearestBranch;
      _updateStatus(BranchStatus.foundNearest);

    } on TimeoutException {
      // Nếu không lấy được vị trí do hết giờ, chọn tạm chi nhánh đầu tiên
      _handleLocationError(BranchStatus.notSelected, "Không thể định vị, đã chọn tạm chi nhánh.");
    } catch (e) {
      // Nếu có lỗi khác, cũng chọn tạm chi nhánh đầu tiên
      _handleLocationError(BranchStatus.notSelected, "Lỗi định vị, đã chọn tạm chi nhánh.");
    }
  }

  /// Hàm helper để xử lý các lỗi liên quan đến vị trí một cách nhất quán
  void _handleLocationError(BranchStatus status, String message) {
    if (_allBranches.isNotEmpty) {
      _selectedBranch = _allBranches.first;
      // Trạng thái notSelected để UI hiểu là "chưa chọn được" và có thể hiển thị thông báo
      _updateStatus(status, message);
    } else {
      // Nếu không có chi nhánh nào thì mới báo lỗi nghiêm trọng
      _updateStatus(BranchStatus.error, "Không tìm thấy chi nhánh nào và không thể định vị.");
    }
  }

  /// Hàm helper để cập nhật trạng thái và thông báo, sau đó báo cho UI vẽ lại.
  void _updateStatus(BranchStatus status, [String message = '']) {
    _status = status;
    _message = message;
    notifyListeners();
  }
}
