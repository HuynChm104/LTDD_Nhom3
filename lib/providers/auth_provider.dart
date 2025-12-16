// lib/providers/auth_provider.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isAuthChecking = true; // Trạng thái đang kiểm tra đăng nhập lúc mở app
  bool get isAuthChecking => _isAuthChecking;

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
      notifyListeners();
      return;
    }

    try {
      DocumentSnapshot? doc;

      final isNewUser = firebaseUser.metadata.creationTime != null &&
          firebaseUser.metadata.lastSignInTime != null &&
          (firebaseUser.metadata.creationTime!.difference(firebaseUser.metadata.lastSignInTime!).inSeconds.abs() < 10);

      if (isNewUser) {
        int retries = 3;
        while (retries > 0) {
          final tempDoc = await _firestore.collection('users').doc(firebaseUser.uid).get(
            const GetOptions(source: Source.server),
          );

          if (tempDoc.exists) {
            doc = tempDoc;
            break; // Đã tìm thấy, thoát vòng lặp
          }
          await Future.delayed(const Duration(seconds: 1)); // Đợi 1s rồi thử lại
          retries--;
        }
      }

      // 3. Nếu không phải user mới hoặc đã hết số lần thử mà chưa có doc
      doc ??= await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
      } else {
        // 4. FALLBACK: Nếu Firestore vẫn chưa có, load từ Auth
        // QUAN TRỌNG: Reload để đảm bảo lấy được displayName mới nhất từ Register
        await firebaseUser.reload();
        final updatedUser = FirebaseAuth.instance.currentUser;

        _currentUser = UserModel(
          id: updatedUser?.uid ?? '',
          // Ưu tiên lấy tên từ Auth nếu Firestore chưa có
          name: updatedUser?.displayName ?? '',
          email: updatedUser?.email ?? '',
          phone: updatedUser?.phoneNumber ?? '',
          avatar: updatedUser?.photoURL ?? '',
          address: '',
          vouchers: [],
          favoriteBranch: '',
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Lỗi tải user: $e');
      _currentUser = null;
    }
    _isAuthChecking = false;
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


  // --- CÁC HÀM KHÁC ---
  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();

    await _authService.signOut();
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

  Future<bool> uploadImage() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final oldAvatar = _currentUser?.avatar;

      await _authService.uploadAvatar();

      if (oldAvatar != null && oldAvatar.isNotEmpty) {
        await CachedNetworkImage.evictFromCache(oldAvatar);
      }

      await _onAuthStateChanged(_authService.currentUser);

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


  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
