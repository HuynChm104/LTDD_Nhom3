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
  tooFar,           // Vị trí người dùng quá xa (hiện cảnh báo)
  notSelected,      // Người dùng đã bỏ qua, chưa chọn chi nhánh (hiện "Chọn chi nhánh")
  permissionDenied, // Người dùng từ chối quyền vị trí (hiện "Cấp quyền vị trí")
  error,            // Có lỗi xảy ra (hiện thông báo lỗi)
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

  /// Thông báo đi kèm (ví dụ: "Bạn ở quá xa", "Lỗi định vị",...).
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
    _status = BranchStatus.foundNearest;
    notifyListeners();
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

  /// Logic cốt lõi: xin quyền, lấy vị trí, tính toán và quyết định.
  Future<void> _findAndSetNearestBranch() async {
    // 1. Kiểm tra và xin quyền vị trí.
    final permissionStatus = await Permission.location.request();
    if (!permissionStatus.isGranted) {
      _updateStatus(BranchStatus.permissionDenied, "Vui lòng cấp quyền vị trí để tìm chi nhánh gần nhất.");
      return;
    }

    // 2. Lấy vị trí hiện tại của người dùng.
    try {
      final Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), // Tránh treo nếu không lấy được vị trí
      );

      // 3. Tìm chi nhánh gần nhất từ danh sách _allBranches.
      BranchModel? nearestBranch;
      double minDistance = double.infinity;

      for (final branch in _allBranches) {
        // Sử dụng hàm distanceTo từ model của bạn. distanceTo trả về km.
        final distance = branch.distanceTo(userPosition.latitude, userPosition.longitude);
        if (distance < minDistance) {
          minDistance = distance;
          nearestBranch = branch;
        }
      }

      // 4. Kiểm tra khoảng cách và quyết định trạng thái.
      const double maxDistanceInKm = 20.0; // Giới hạn 20km

      if (nearestBranch != null && minDistance <= maxDistanceInKm) {
        // Tìm thấy và trong phạm vi cho phép -> Tự động chọn chi nhánh đó.
        _selectedBranch = nearestBranch;
        _updateStatus(BranchStatus.foundNearest);
      } else {
        // Quá xa hoặc không tìm thấy chi nhánh nào.
        _selectedBranch = null; // Không tự động chọn
        _updateStatus(BranchStatus.tooFar, "Bạn ở quá xa, vui lòng chọn chi nhánh thủ công.");
      }
    } on TimeoutException {
      _updateStatus(BranchStatus.error, "Không thể lấy vị trí của bạn. Vui lòng kiểm tra GPS và thử lại.");
    } catch (e) {
      _updateStatus(BranchStatus.error, "Đã xảy ra lỗi khi định vị: ${e.toString()}");
    }
  }

  /// Hàm helper để cập nhật trạng thái và thông báo, sau đó báo cho UI vẽ lại.
  void _updateStatus(BranchStatus status, [String message = '']) {
    _status = status;
    _message = message;
    notifyListeners();
  }
}
