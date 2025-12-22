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
      // Validate password strength
      final passwordError = _validatePasswordStrength(password);
      if (passwordError != null) {
        throw Exception(passwordError);
      }

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
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '94003824961-l26onrkkkdkmei9vsvufmdipmd8q37cr.apps.googleusercontent.com', // For Web
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
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
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );
      
      // Kiểm tra status đăng nhập
      if (loginResult.status == LoginStatus.cancelled) {
        throw 'Người dùng đã hủy đăng nhập Facebook';
      }
      
      if (loginResult.status == LoginStatus.failed) {
        throw 'Đăng nhập Facebook thất bại: ${loginResult.message}';
      }

      if (loginResult.status != LoginStatus.success) {
        throw 'Đăng nhập Facebook thất bại: ${loginResult.status}';
      }

      // Kiểm tra accessToken không null
      if (loginResult.accessToken == null) {
        throw 'Không thể lấy access token từ Facebook. Vui lòng thử lại.';
      }

      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);
    
      UserCredential userCredential;
      
      try {
        userCredential = await _auth.signInWithCredential(facebookAuthCredential);
      } on FirebaseAuthException catch (e) {
        // Xử lý khi email đã tồn tại với phương thức khác
        if (e.code == 'account-exists-with-different-credential') {
          // Lấy dữ liệu người dùng từ Facebook để có email
          final userData = await FacebookAuth.instance.getUserData(
            fields: "email",
          );
          
          final facebookEmail = userData['email'] as String?;
          
          if (facebookEmail == null) {
            throw 'Không thể lấy email từ Facebook. Vui lòng thử lại.';
          }

          // Tìm tài khoản hiện có và hướng dẫn user liên kết
          try {
            // Lấy tất cả provider methods của email này
            final methods = await _auth.fetchSignInMethodsForEmail(facebookEmail);
            
            if (methods.contains('password')) {
              // Email đã đăng ký bằng email/password, yêu cầu user đăng nhập trước
              throw 'Email này đã được đăng ký bằng Email/Password. Vui lòng đăng nhập bằng email & mật khẩu trước, sau đó liên kết Facebook trong cài đặt tài khoản.';
            } else if (methods.contains('google.com')) {
              // Email đã liên kết với Google
              throw 'Email này đã được liên kết với Google. Vui lòng đăng nhập bằng Google, sau đó liên kết Facebook trong cài đặt tài khoản.';
            } else {
              throw 'Email này đã được sử dụng. Vui lòng đăng nhập với phương thức khác và liên kết trong cài đặt tài khoản.';
            }
          } catch (e) {
            rethrow;
          }
        }
        
        if (e.code == 'invalid-credential') {
          throw 'Thông tin đăng nhập không hợp lệ. Vui lòng thử lại.';
        } else if (e.code == 'operation-not-allowed') {
          throw 'Đăng nhập Facebook hiện chưa được bật. Liên hệ quản trị viên.';
        }
        throw 'Lỗi Firebase: ${e.message}';
      }
      
      // Lấy dữ liệu người dùng từ Facebook
      final userData = await FacebookAuth.instance.getUserData(
        fields: "name,email,picture.width(200)",
      );

      // Tạo tài khoản mới nếu là lần đầu đăng nhập
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'name': userData['name'] ?? userCredential.user?.displayName ?? '',
          'email': userData['email'] ?? userCredential.user?.email ?? '',
          'phone': userCredential.user?.phoneNumber ?? '',
          'avatar': userData['picture']?['data']?['url'] ?? userCredential.user?.photoURL ?? '',
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
      // Validate password strength
      final passwordError = _validatePasswordStrength(newPassword);
      if (passwordError != null) {
        throw Exception(passwordError);
      }

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

  // Liên kết Google Account với tài khoản hiện tại
  Future<void> linkGoogleAccount() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw 'Vui lòng đăng nhập trước';
    }

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '94003824961-l26onrkkkdkmei9vsvufmdipmd8q37cr.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw 'Đăng nhập Google đã bị hủy';

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await currentUser.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        throw 'Tài khoản Google này đã được liên kết với tài khoản khác.';
      }
      throw 'Lỗi liên kết Google: ${e.message}';
    } catch (e) {
      throw 'Lỗi liên kết Google: $e';
    }
  }

  // Liên kết Facebook Account với tài khoản hiện tại
  Future<void> linkFacebookAccount() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw 'Vui lòng đăng nhập trước';
    }

    try {
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );

      if (loginResult.status != LoginStatus.success) {
        throw 'Đăng nhập Facebook thất bại: ${loginResult.status}';
      }

      if (loginResult.accessToken == null) {
        throw 'Không thể lấy access token từ Facebook.';
      }

      final facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);

      await currentUser.linkWithCredential(facebookAuthCredential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        throw 'Tài khoản Facebook này đã được liên kết với tài khoản khác.';
      }
      throw 'Lỗi liên kết Facebook: ${e.message}';
    } catch (e) {
      throw 'Lỗi liên kết Facebook: $e';
    }
  }

  // Lấy danh sách các phương thức đăng nhập được liên kết
  Future<List<String>> getLinkedProviders() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw 'Vui lòng đăng nhập trước';
    }

    return currentUser.providerData.map((info) => info.providerId).toList();
  }

  // Hủy liên kết một phương thức đăng nhập
  Future<void> unlinkProvider(String providerId) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw 'Vui lòng đăng nhập trước';
    }

    try {
      // Không cho phép hủy liên kết nếu chỉ còn 1 phương thức
      if (currentUser.providerData.length <= 1) {
        throw 'Không thể hủy liên kết vì đây là phương thức đăng nhập duy nhất của bạn.';
      }

      await currentUser.unlink(providerId);
    } on FirebaseAuthException catch (e) {
      throw 'Lỗi hủy liên kết: ${e.message}';
    } catch (e) {
      throw 'Lỗi hủy liên kết: $e';
    }
  }

  Future<void> signOut() async {
    // ... (Giữ nguyên)
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
    await _auth.signOut();
  }

  // Gửi email đặt lại mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      // Kiểm tra email hợp lệ
      if (email.isEmpty) {
        throw Exception('Email không được để trống');
      }

      // Firebase sẽ tự kiểm tra email có tồn tại hay không
      await _auth.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: 'https://bongbieng-app.firebaseapp.com/reset-password',
          handleCodeInApp: true,
          dynamicLinkDomain: "bongbieng-app.firebaseapp.com",
          androidInstallApp: true,
          androidMinimumVersion: "21",
          androidPackageName: "com.example.bongbieng_app",
          iOSBundleId: "com.example.bongBieng",
        ),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      rethrow;
    }
  }

  // Xác minh mã reset và đặt lại mật khẩu (nếu dùng link reset)
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      // Validate password strength
      final passwordError = _validatePasswordStrength(newPassword);
      if (passwordError != null) {
        throw passwordError;
      }
      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Xác minh email trong quá trình đặt lại mật khẩu
  Future<String> verifyPasswordResetCode(String code) async {
    try {
      return await _auth.verifyPasswordResetCode(code);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': 
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password': 
        return 'Mật khẩu không chính xác.';
      case 'email-already-in-use': 
        return 'Email này đã được sử dụng.';
      case 'invalid-email': 
        return 'Email không hợp lệ.';
      case 'weak-password': 
        return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
      case 'operation-not-allowed': 
        return 'Thao tác này không được phép.';
      case 'user-disabled': 
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case 'invalid-action-code':
        return 'Mã đặt lại mật khẩu không hợp lệ hoặc đã hết hạn.';
      case 'expired-action-code':
        return 'Mã đặt lại mật khẩu đã hết hạn. Vui lòng yêu cầu một mã mới.';
      default: 
        return 'Đã xảy ra lỗi: ${e.message}';
    }
  }

  // Validate password strength requirements
  String? _validatePasswordStrength(String password) {
    // Check minimum length
    if (password.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự.';
    }

    // Check for at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Mật khẩu phải chứa ít nhất 1 chữ hoa (A-Z).';
    }

    // Check for at least one special character
    if (!password.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{};:",./<>?\\|`~-]'))) {
      return 'Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt (!@#\$%^&* v.v.).';
    }

    // All validations passed
    return null;
  }
}
