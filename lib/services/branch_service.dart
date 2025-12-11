// lib/services/branch_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart'; // <--- IMPORT THƯ VIỆN MỚI
import '../models/branch_model.dart';

class BranchService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<List<BranchModel>> getAllBranches() async {
    try {
      final snapshot = await _firestore.collection('branches').get();
      if (snapshot.docs.isEmpty) {
        return [];
      }

      // Chuyển đổi các tài liệu Firestore thành một danh sách các "công việc" Geocoding
      final branchFutures = snapshot.docs.map((doc) async {
        // 1. Tạo một đối tượng BranchModel chỉ với thông tin cơ bản (id, name, address)
        BranchModel branch = BranchModel.fromJson(doc.id, doc.data());

        // 2. Bắt đầu quá trình Geocoding để tìm tọa độ từ địa chỉ
        try {
          // Lấy danh sách các vị trí khớp với địa chỉ (thường chỉ lấy kết quả đầu tiên)
          List<Location> locations = await locationFromAddress(branch.address);

          if (locations.isNotEmpty) {
            // 3. Nếu tìm thấy, cập nhật tọa độ cho đối tượng branch
            branch.latitude = locations.first.latitude;
            branch.longitude = locations.first.longitude;
            print('✅ Tìm thấy tọa độ cho "${branch.name}": Lat ${branch.latitude}, Lng ${branch.longitude}');
          } else {
            print('⚠️ Không thể tìm thấy tọa độ cho địa chỉ: "${branch.address}"');
          }
        } catch (e) {
          // Nếu có lỗi trong quá trình Geocoding (ví dụ: mất mạng, địa chỉ không tồn tại)
          // tọa độ của chi nhánh sẽ giữ nguyên là 0.0
          print('❌ Lỗi Geocoding cho địa chỉ "${branch.address}": $e');
        }

        // 4. Trả về đối tượng branch đã được cập nhật (hoặc chưa nếu có lỗi)
        return branch;
      }).toList();

      // Chờ cho tất cả các "công việc" Geocoding hoàn thành
      final List<BranchModel> branches = await Future.wait(branchFutures);

      print('--- Quá trình Geocoding hoàn tất cho ${branches.length} chi nhánh ---');
      return branches;

    } catch (e) {
      print("Lỗi nghiêm trọng khi lấy danh sách chi nhánh: $e");
      return [];
    }
  }
}

