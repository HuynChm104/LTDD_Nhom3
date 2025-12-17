// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // SỬA: Cập nhật getter để trả về UserModel?
  UserModel? get user => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
    } else {
      // KIỂM TRA XEM ĐÂY CÓ PHẢI LÀ NGƯỜI DÙNG MỚI ĐƯỢC TẠO RA KHÔNG
      final isNewUser = firebaseUser.metadata.creationTime == firebaseUser.metadata.lastSignInTime;

      // NẾU LÀ NGƯỜI DÙNG MỚI, THÊM MỘT ĐỘ TRỄ NHỎ
      // Điều này để đảm bảo Cloud Firestore có đủ thời gian để ghi document mới
      // sau khi hàm register trong AuthService được gọi.
      if (isNewUser) {
        await Future.delayed(const Duration(seconds: 1));
      }

      try {
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get(
          // Luôn lấy dữ liệu mới nhất từ server, không dùng cache
          const GetOptions(source: Source.server),
        );

        if (doc.exists) {
          _currentUser = UserModel.fromFirestore(doc);
        } else {
          // Trường hợp này bây giờ rất hiếm khi xảy ra, nhưng vẫn giữ lại để phòng ngừa
          _currentUser = UserModel(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? '',
            email: firebaseUser.email ?? '',
            phone: firebaseUser.phoneNumber ?? '',
            avatar: firebaseUser.photoURL ?? '',
            address: '',
            vouchers: [],
            favoriteBranch: '',
            createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
          );
        }
      } catch (e) {
        print('Lỗi khi lấy dữ liệu người dùng từ Firestore: $e');
        _currentUser = null;
      }
    }
     notifyListeners();
  }

  Future<bool> updateUserProfile({
    required String fullName,
    String? phoneNumber,
    String? address, // Thêm
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.updateUserProfile(
        displayName: fullName,
        phoneNumber: phoneNumber,
        address: address, // Thêm
      );
      await _onAuthStateChanged(_authService.currentUser);
      _isLoading = false;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Hàm private để xử lý lỗi một cách nhất quán
  void _handleAuthError(Object e) {
    _errorMessage = e.toString();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _safeReloadUserAndUpdate() async {
    await _onAuthStateChanged(_authService.currentUser);
    _isLoading = false;
  }

  // --- CÁC HÀM XÁC THỰC  ---
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.signInWithEmailAndPassword(email: email, password: password);
      _isLoading = false;
      return true;
    } catch (e) {
      _handleAuthError(e);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      _isLoading = false;
      return true;
    } catch (e) {
      _handleAuthError(e);
      return false;
    }
  }

  // THÊM: Các hàm đăng nhập mạng xã hội và đổi mật khẩu
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.signInWithGoogle();
      // _onAuthStateChanged sẽ tự xử lý phần còn lại
      _isLoading = false;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  Future<bool> signInWithFacebook() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.signInWithFacebook();
      _isLoading = false;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfilePicture() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.updateProfilePicture();
      await _safeReloadUserAndUpdate(); // Tải lại dữ liệu mới
      return true;
    } catch (e) {
      _handleAuthError(e);
      return false;
    }
  }

  // --- CÁC HÀM KHÁC ---
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _handleAuthError(e);
      return false;
    }
  }

  // Xác minh mã reset password và đặt lại mật khẩu
  Future<bool> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.confirmPasswordReset(code: code, newPassword: newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _handleAuthError(e);
      return false;
    }
  }

  // Xác minh mã reset password
  Future<String?> verifyPasswordResetCode(String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final email = await _authService.verifyPasswordResetCode(code);
      _isLoading = false;
      notifyListeners();
      return email;
    } catch (e) {
      _handleAuthError(e);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
