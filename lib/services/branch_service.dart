// services/branch_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/branch_model.dart';
import 'location_service.dart'; // ← IMPORT AUTH SERVICE

class BranchService {
  /// Lấy tất cả chi nhánh
  static Future<List<BranchModel>> getAllBranches() async {
    final snapshot = await FirebaseFirestore.instance.collection('branches').get();
    return snapshot.docs
        .map((doc) => BranchModel.fromJson(doc.id, doc.data()))
        .toList();
  }

  /// Lấy chi nhánh gần nhất
  static Future<BranchModel?> getNearestBranch() async {
    // GỌI TỪ AUTH SERVICE
    final position = await LocationService.getCurrentPosition();
    if (position == null) return null;

    final branches = await getAllBranches();
    if (branches.isEmpty) return null;

    branches.sort((a, b) =>
        a.distanceTo(position.latitude, position.longitude)
            .compareTo(b.distanceTo(position.latitude, position.longitude)));

    return branches.first;
  }
}