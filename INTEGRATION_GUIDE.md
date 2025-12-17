# Integration Guide - Kết Nối UI Với Backend

## 🎯 Các Bước Tích Hợp

### 1. Login Screen - Thêm "Quên Mật Khẩu" Link

**File:** `lib/screens/auth/login_screen.dart`

**Tìm:** Phần password field

**Thêm vào:**
```dart
// Sau password TextField, thêm row này:
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ForgotPasswordScreen(),
          ),
        );
      },
      child: const Text(
        'Quên Mật Khẩu?',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 14,
        ),
      ),
    ),
  ],
)
```

**Kết quả:**
```
Email: [_______________]
Password: [_______________] [Quên Mật Khẩu?]
[Đăng Nhập]
```

---

### 2. Handle Reset Password Link từ Email

**File:** `lib/main.dart`

**Thêm import:**
```dart
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'screens/auth/reset_password_screen.dart';
```

**Thêm function:**
```dart
Future<void> initDynamicLinks(BuildContext context) async {
  try {
    // Handle initial link
    final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink, context);
    }

    // Listen for new links
    FirebaseDynamicLinks.instance.onLink.listen(
      (PendingDynamicLinkData dynamicLinkData) {
        _handleDeepLink(dynamicLinkData, context);
      },
      onError: (error) {
        print('Dynamic link error: $error');
      },
    );
  } catch (e) {
    print('Error initializing dynamic links: $e');
  }
}

void _handleDeepLink(
  PendingDynamicLinkData dynamicLinkData,
  BuildContext context,
) {
  final deepLink = dynamicLinkData.link;
  final queryParams = deepLink.queryParameters;

  // Handle reset password link
  if (deepLink.path.contains('reset-password')) {
    final code = queryParams['code'];
    if (code != null && code.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(code: code),
        ),
      );
    }
  }
}
```

**Gọi trong main():**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Khởi tạo dynamic links sau khi app ready
  runApp(const BongBiengApp());
  
  // Delayed vì context chưa ready
  WidgetsBinding.instance.addPostFrameCallback((_) {
    initDynamicLinks(navigatorKey.currentContext!);
  });
}
```

---

### 3. Profile Screen - Thêm "Đổi Mật Khẩu" Button

**File:** `lib/screens/profile/profile_screen.dart` (hoặc profile settings)

**Thêm:**
```dart
ListTile(
  leading: const Icon(Icons.lock_outline),
  title: const Text('Đổi Mật Khẩu'),
  trailing: const Icon(Icons.arrow_forward_ios),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChangePasswordScreen(),
      ),
    );
  },
)
```

---

### 4. Tạo Change Password Screen (Optional)

**File:** `lib/screens/auth/change_password_screen.dart`

```dart
// lib/screens/auth/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    FocusScope.of(context).unfocus();
    
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu xác nhận không khớp'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mật khẩu đã được đổi thành công!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Lỗi khi đổi mật khẩu'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.secondary,
              AppColors.primaryLight,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 60,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đổi Mật Khẩu',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Current password
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: _obscureCurrentPassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Mật khẩu hiện tại',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrentPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        onPressed: () {
                          setState(() =>
                              _obscureCurrentPassword = !_obscureCurrentPassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu hiện tại';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // New password
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Mật khẩu mới',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        onPressed: () {
                          setState(() =>
                              _obscureNewPassword = !_obscureNewPassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu mới';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Confirm password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Xác nhận mật khẩu mới',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        onPressed: () {
                          setState(() =>
                              _obscureConfirmPassword = !_obscureConfirmPassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng xác nhận mật khẩu';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          authProvider.isLoading ? null : _handleChangePassword,
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Đổi Mật Khẩu'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 📱 Navigation Map

```
┌─────────────────────────────────────┐
│         Login Screen                │
│  ┌──────────┐  ┌──────────────────┐ │
│  │ Register │  │ Quên Mật Khẩu?   │ │
│  └──────────┘  └────────┬─────────┘ │
└─────────────────────────┼────────────┘
                          │
                          ▼
                ┌──────────────────────┐
                │ Forgot Password      │
                │  - Nhập email        │
                │  - Gửi email        │
                └──────────────────────┘
                          │
                ┌─────────┴─────────┐
                │   Email nhận      │
                │   Reset Link      │
                └─────────┬─────────┘
                          │
                          ▼
                ┌──────────────────────┐
                │ Reset Password       │
                │  - Verify Code       │
                │  - New Password      │
                │  - Confirm           │
                └─────────┬────────────┘
                          │
                          ▼
                    Login Screen
                    (Auto-enter)

┌─────────────────────────────────────┐
│         Profile Screen              │
│  ┌──────────────────────────────┐   │
│  │ Đổi Mật Khẩu                 │   │
│  └────────────┬─────────────────┘   │
└───────────────┼────────────────────┘
                │
                ▼
        ┌──────────────────────┐
        │ Change Password      │
        │  - Current Password  │
        │  - New Password      │
        │  - Confirm           │
        └──────────────────────┘
```

---

## ✅ Checklist Tích Hợp

- [ ] Thêm "Quên Mật Khẩu?" link vào Login Screen
- [ ] Thêm Dynamic Links handler vào main.dart
- [ ] Test reset link từ email
- [ ] Tạo Change Password Screen (optional)
- [ ] Thêm "Đổi Mật Khẩu" button vào Profile (optional)
- [ ] Test toàn bộ flow trên device
- [ ] Kiểm tra error handling
- [ ] Deploy lên production

---

## 🧪 Manual Testing

### Test Case 1: Quên Mật Khẩu

```
1. Vào Login > Quên Mật Khẩu?
2. Nhập email hợp lệ
3. Bấp "Gửi"
4. Kiểm tra email
5. Copy link từ email
6. Paste vào browser / Bấp link
7. ResetPasswordScreen mở tự động
8. Nhập mật khẩu mới
9. Bấp "Đặt Lại"
10. Kiểm tra auto-login hoặc redirect to login
```

### Test Case 2: Email Không Tồn Tại

```
1. Vào Login > Quên Mật Khẩu?
2. Nhập email không tồn tại
3. Bấp "Gửi"
4. ✅ Hiển thị: "Không tìm thấy tài khoản"
```

### Test Case 3: Mã Hết Hạn

```
1. Copy link reset
2. Đợi >24h
3. Bấp link
4. ✅ Hiển thị: "Mã đã hết hạn"
```

### Test Case 4: Đổi Mật Khẩu

```
1. Profile > Đổi Mật Khẩu
2. Nhập mật khẩu hiện tại sai
3. Bấp "Đổi"
4. ✅ Error: "Mật khẩu không chính xác"
5. Nhập đúng mật khẩu
6. Nhập mật khẩu mới
7. Xác nhận
8. ✅ Success: "Mật khẩu đã được đổi"
```

---

## 🚀 Deployment

1. **Test locally** - Toàn bộ flow
2. **Build APK** - `flutter build apk --release`
3. **Test on device** - Email delivery
4. **Deploy to Play Store**
5. **Monitor Firebase** - Check reset attempts

---

**Status:** ✅ Sẵn sàng tích hợp!
