// lib/services/auth_service.dart
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CloudinaryPublic cloudinary = CloudinaryPublic(
    'dp4qtd5uz',
    'BongBieng_App',
    cache: false,
  );

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // ... (Giữ nguyên)
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    // ... (Giữ nguyên)
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(fullName);
      await _firestore.collection('users').doc(credential.user?.uid).set({
        'name': fullName,
        'email': email,
        'phone': phoneNumber ?? '',
        'address': '',
        'vouchers': [],
        'favoriteBranch': '',
        'avatar': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    // ... (Giữ nguyên)
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw 'Đăng nhập Google đã bị hủy';

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'name': userCredential.user?.displayName ?? '',
          'email': userCredential.user?.email ?? '',
          'phone': userCredential.user?.phoneNumber ?? '',
          'avatar': userCredential.user?.photoURL ?? '',
          'address': '',
          'vouchers': [],
          'favoriteBranch': '',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return userCredential;
    } catch (e) {
      throw 'Lỗi đăng nhập Google: $e';
    }
  }

  Future<UserCredential?> signInWithFacebook() async {
    // ... (Giữ nguyên)
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );
      if (loginResult.status != LoginStatus.success) throw 'Đăng nhập Facebook thất bại';

      final OAuthCredential facebookAuthCredential =
      FacebookAuthProvider.credential(loginResult.accessToken!.token);
      final userCredential = await _auth.signInWithCredential(facebookAuthCredential);
      final userData = await FacebookAuth.instance.getUserData(fields: "name,email,picture.width(200)");

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'name': userData['name'] ?? '',
          'email': userData['email'] ?? userCredential.user?.email ?? '',
          'phone': '',
          'avatar': userData['picture']?['data']?['url'] ?? '',
          'address': '',
          'vouchers': [],
          'favoriteBranch': '',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return userCredential;
    } catch (e) {
      throw 'Lỗi đăng nhập Facebook: $e';
    }
  }

  // SỬA: Hàm updateUserProfile để nhận thêm `address`
  Future<void> updateUserProfile({
    required String displayName,
    String? phoneNumber,
    String? address, // Thêm tham số
  }) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("Không có người dùng nào đang đăng nhập để cập nhật.");
    }

    try {
      if (displayName != currentUser.displayName) {
        await currentUser.updateDisplayName(displayName);
      }
      await _firestore.collection('users').doc(currentUser.uid).update({
        'name': displayName,
        'phone': phoneNumber ?? '',
        'address': address ?? '', // Thêm address vào update
      });
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật hồ sơ: ${e.toString()}');
    }
  }

  // THÊM: Hàm đổi mật khẩu
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('Không thể đổi mật khẩu cho tài khoản này.');
    }

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw 'Mật khẩu hiện tại không chính xác.';
      }
      throw 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }

  Future<String> updateProfilePicture() async {
    // ... (Giữ nguyên)
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("Vui lòng đăng nhập để thực hiện chức năng này.");
    }

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
    );

    if (image == null) {
      throw Exception("Bạn chưa chọn ảnh nào.");
    }

    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'bongbieng_avatars',
          publicId: currentUser.uid,
        ),
      );

      final String secureUrl = response.secureUrl;

      await currentUser.updatePhotoURL(secureUrl);
      await _firestore.collection('users').doc(currentUser.uid).update({
        'avatar': secureUrl,
      });

      return secureUrl;
    } catch (e) {
      print('LỖI CLOUDINARY: ${e.toString()}');
      throw Exception("Tải ảnh lên thất bại. Vui lòng kiểm tra lại Cloud Name và Upload Preset.");
    }
  }

  Future<void> signOut() async {
    // ... (Giữ nguyên)
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    // ... (Giữ nguyên)
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    // ... (Giữ nguyên)
    switch (e.code) {
      case 'user-not-found': return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password': return 'Mật khẩu không chính xác.';
      case 'email-already-in-use': return 'Email này đã được sử dụng.';
      case 'invalid-email': return 'Email không hợp lệ.';
      case 'weak-password': return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
      case 'operation-not-allowed': return 'Thao tác này không được phép.';
      case 'user-disabled': return 'Tài khoản này đã bị vô hiệu hóa.';
      default: return 'Đã xảy ra lỗi: ${e.message}';
    }
  }
}
