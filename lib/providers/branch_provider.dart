import 'package:flutter/material.dart';
import '../models/branch_model.dart';
import '../services/branch_service.dart'; // ← CHỈ IMPORT 1 LẦN

class BranchProvider with ChangeNotifier {
  BranchModel? _nearestBranch;
  BranchModel? _selectedBranch;
  List<BranchModel> _branches = [];
  bool _isLoading = false;

  BranchModel? get nearestBranch => _selectedBranch ?? _nearestBranch;
  List<BranchModel> get branches => _branches;
  bool get isLoading => _isLoading;

  Future<void> loadNearestBranch() async {
    _isLoading = true;
    notifyListeners();

    _nearestBranch = await BranchService.getNearestBranch(); // ← GỌI ĐÚNG
    _selectedBranch = _nearestBranch;
    _branches = await BranchService.getAllBranches();         // ← GỌI ĐÚNG

    _isLoading = false;
    notifyListeners();
  }

  void selectBranch(BranchModel branch) {
    _selectedBranch = branch;
    notifyListeners();
  }

  void resetToNearest() {
    _selectedBranch = _nearestBranch;
    notifyListeners();
  }
}