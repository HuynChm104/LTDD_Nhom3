# Quick Reference - Chức Năng Quên Mật Khẩu

## 📦 Files Được Tạo/Sửa

### Backend Services

1. **`lib/services/auth_service.dart`** ✅
   - `resetPassword(email)` - Gửi email reset
   - `confirmPasswordReset(code, newPassword)` - Đặt lại mật khẩu
   - `verifyPasswordResetCode(code)` - Xác minh mã
   - Enhanced `_handleAuthException()` - Xử lý lỗi

2. **`lib/providers/auth_provider.dart`** ✅
   - `resetPassword(email)` - Wrapper cho service
   - `confirmPasswordReset(code, newPassword)` - Wrapper
   - `verifyPasswordResetCode(code)` - Wrapper

### UI Screens

3. **`lib/screens/auth/forgot_password_screen.dart`** (Đã có)
   - Màn hình nhập email
   - Gửi email reset

4. **`lib/screens/auth/reset_password_screen.dart`** ✅ (Mới)
   - Xác minh mã từ email
   - Nhập mật khẩu mới
   - Xác nhận & đặt lại

### Documentation

5. **`FORGOT_PASSWORD_BACKEND.md`** ✅
   - Tài liệu chi tiết
   - Flow diagrams
   - Testing guide

---

## 🔄 User Flow

```
1️⃣ Login Screen
   ↓
   Nhấp "Quên Mật Khẩu?"
   ↓
2️⃣ ForgotPasswordScreen
   ├─ Nhập email
   ├─ Validate
   └─ Gửi email (AuthProvider.resetPassword)
   ↓
3️⃣ Email nhận được
   └─ Chứa link reset (có code)
   ↓
4️⃣ ResetPasswordScreen (mở từ email link)
   ├─ Xác minh code (AuthProvider.verifyPasswordResetCode)
   ├─ Hiển thị email đã xác minh
   ├─ Nhập mật khẩu mới
   ├─ Xác nhận mật khẩu
   └─ Bấm "Đặt Lại Mật Khẩu"
   ↓
5️⃣ Confirmpassword (AuthProvider.confirmPasswordReset)
   ├─ ✅ Success → Auto login → Home
   └─ ❌ Error → Hiển thị lỗi
```

---

## 🚀 Integration Steps

### Step 1: Update Login Screen (Nếu chưa có)

```dart
// lib/screens/auth/login_screen.dart

// Thêm import
import 'forgot_password_screen.dart';

// Thêm button sau password field
TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ForgotPasswordScreen(),
      ),
    );
  },
  child: const Text('Quên Mật Khẩu?'),
)
```

### Step 2: Setup Dynamic Links (Optional nhưng Khuyến Khích)

```dart
// lib/main.dart - Thêm vào main()

void initDynamicLinks() {
  FirebaseDynamicLinks.instance.onLink.listen(
    (PendingDynamicLinkData dynamicLinkData) {
      final deepLink = dynamicLinkData.link;
      
      if (deepLink.path.contains('/reset-password')) {
        final code = deepLink.queryParameters['code'];
        if (code != null) {
          // Mở ResetPasswordScreen với code
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(code: code),
            ),
          );
        }
      }
    },
  );
}
```

### Step 3: Test on Device

```bash
# Clean & rebuild
flutter clean
flutter pub get
flutter run

# Test steps:
# 1. Nhấp "Quên Mật Khẩu?" từ Login
# 2. Nhập email tồn tại
# 3. Kiểm tra email nhận được
# 4. Bấp link trong email
# 5. Nhập mật khẩu mới & xác nhận
# 6. Bấp "Đặt Lại Mật Khẩu"
# 7. Tự động đăng nhập
```

---

## 🛠️ API Reference

### AuthService Methods

#### `resetPassword(email: String)`
```dart
// Request
await authService.resetPassword("user@example.com");

// Response: void (throw exception if error)

// Errors
- "Không tìm thấy tài khoản với email này."
- "Email không hợp lệ."
- "Đã xảy ra lỗi: ..."
```

#### `verifyPasswordResetCode(code: String)`
```dart
// Request
final email = await authService.verifyPasswordResetCode("ABC123");

// Response: String (email address)

// Errors
- "Mã không hợp lệ hoặc đã hết hạn."
```

#### `confirmPasswordReset(code, newPassword)`
```dart
// Request
await authService.confirmPasswordReset(
  code: "ABC123",
  newPassword: "newPassword123",
);

// Response: void (throw exception if error)

// Errors
- "Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn."
- "Mã đặt lại mật khẩu đã hết hạn. Vui lòng yêu cầu một mã mới."
```

### AuthProvider Methods

#### `resetPassword(email: String) -> Future<bool>`
```dart
// Usage
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final success = await authProvider.resetPassword("user@example.com");

if (success) {
  // Email sent
} else {
  // Check authProvider.errorMessage
  print(authProvider.errorMessage);
}
```

#### `confirmPasswordReset(code, newPassword) -> Future<bool>`
```dart
// Usage
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final success = await authProvider.confirmPasswordReset(
  code: "ABC123",
  newPassword: "newPassword123",
);

if (success) {
  // Password updated & auto login
} else {
  // Check authProvider.errorMessage
}
```

#### `verifyPasswordResetCode(code) -> Future<String?>`
```dart
// Usage
final email = await authProvider.verifyPasswordResetCode("ABC123");

if (email != null) {
  // Code valid, show email
} else {
  // Code invalid/expired
  print(authProvider.errorMessage);
}
```

---

## 🔐 Security Features

✅ **Implemented:**
- Email verification
- 24-hour code expiry
- One-time use codes
- Minimum 6-char passwords
- Detailed error messages (Vietnamese)
- Rate limiting ready (can implement)

✅ **Firebase Security:**
- Code never exposed in logs
- Email encrypted in transit
- Password hashed in storage
- Automatic logout required

---

## ⚠️ Important Notes

1. **Code Duration:** 24 hours (Firebase default)
2. **Email Domain:** `noreply@{project-id}.firebaseapp.com`
3. **No Password Strength:** Firebase handles complexity validation
4. **Auto Login:** User is NOT auto-logged in after reset (security)
5. **Session:** Must re-login with new password

---

## 🐛 Troubleshooting

### Email Not Received

```
❌ Kiểm tra:
1. Spam folder
2. Email address correct
3. Firebase Auth enabled
4. Email not blocked
```

### "Code Invalid" Error

```
❌ Khi bấp reset link:
1. Link có thể hết hạn (24h)
2. Code có thể used rồi
3. Yêu cầu mã mới từ forgot password screen
```

### "Weak Password" on Reset

```
❌ Firebase requires:
- Not empty
- Not same as email
- No simple patterns (123456, qwerty, etc.)
- Better: Mix uppercase, lowercase, numbers, symbols
```

---

## 📊 Status

| Feature | Status | File |
|---------|--------|------|
| Send Reset Email | ✅ Complete | auth_service.dart |
| Verify Code | ✅ Complete | auth_service.dart |
| Reset Password | ✅ Complete | auth_service.dart |
| Error Handling | ✅ Complete | auth_service.dart |
| Provider Wrapper | ✅ Complete | auth_provider.dart |
| Forgot Screen UI | ✅ Complete | forgot_password_screen.dart |
| Reset Screen UI | ✅ Complete | reset_password_screen.dart |
| Dynamic Links | ⏳ Optional | main.dart |
| Rate Limiting | ⏳ Optional | auth_provider.dart |
| Logging | ⏳ Optional | services |

---

## 📚 Documentation Files

- `FORGOT_PASSWORD_BACKEND.md` - Full technical documentation
- This file - Quick reference

---

**Ready to Deploy! 🚀**

Tất cả backend code đã hoàn chỉnh và sẵn sàng sử dụng.
