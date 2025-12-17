# Hướng Dẫn Khắc Phục Lỗi Đăng Nhập Facebook

## 📋 Tóm Tắt Vấn Đề & Giải Pháp

Lỗi đăng nhập Facebook được gây ra bởi thiếu cấu hình Facebook SDK trong Android. Các file sau đã được cập nhật:

1. ✅ **AndroidManifest.xml** - Thêm Facebook metadata và activities
2. ✅ **auth_service.dart** - Cải thiện error handling
3. ✅ **main.dart** - Thêm Facebook SDK initialization
4. ✅ **Cấu hình bổ sung cần thiết**

---

## 🔧 Các Thay Đổi Đã Thực Hiện

### 1. Android Manifest Configuration (`android/app/src/main/AndroidManifest.xml`)

**Thêm vào:**
- Facebook SDK metadata với Application ID
- Facebook Login Activity
- Facebook CustomTabActivity cho OAuth flow
- Internet và Network permissions
- Facebook app queries

### 2. Auth Service Improvements (`lib/services/auth_service.dart`)

**Cải thiện:**
- Thêm `FacebookAuth.instance.logOut()` trước login để reset state
- Xử lý tất cả login status (success, cancelled, failed)
- Chi tiết hóa error messages
- Xử lý Firebase Auth exceptions cụ thể

### 3. Facebook SDK Initialization (`lib/main.dart`)

**Thêm:**
```dart
await FacebookAuth.instance.webAndDesktopInitialize(
  appId: "YOUR_FACEBOOK_APP_ID", // Cần thay thế
  cookie: true,
  xfbml: true,
  version: "v17.0",
);
```

---

## ⚙️ Cấu Hình Bắt Buộc

### A. Facebook App ID trong Strings Resource

**Tạo file:** `android/app/src/main/res/values/strings.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">bongbieng_app</string>
    <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
</resources>
```

**Lưu ý:** Nếu file này đã tồn tại, chỉ cần thêm dòng `facebook_app_id`

### B. Lấy Facebook App ID

1. Vào [Facebook Developers](https://developers.facebook.com/)
2. Tạo hoặc chọn App của bạn
3. Vào **Settings > Basic**
4. Copy **App ID** (dạng: `1234567890`)

### C. Hash Key cho Android

**Bước 1: Lấy App Hash Key**

Chạy lệnh này (thay `com.example.bongbieng_app` bằng package name của bạn):

```bash
# macOS/Linux
keytool -exportcert -alias androiddebugkey -keystore ~/.android/keystore.jks | openssl dgst -sha1 -binary | openssl enc -base64

# Windows
keytool -exportcert -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore | openssl dgst -sha1 -binary | openssl enc -base64
```

Nếu yêu cầu password, hãy nhập: `android`

**Bước 2: Thêm Hash Key vào Facebook**

1. Facebook Developers > Settings > Basic
2. Tìm mục **Android**
3. Nhấp **Add Platform > Android**
4. Paste **Key Hashes** (có thể thêm nhiều hash keys)
5. Nhập **Package Name:** `com.example.bongbieng_app`
6. Save changes

### D. Cập Nhật main.dart với Facebook App ID

**File:** `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Thay YOUR_FACEBOOK_APP_ID bằng App ID thực
  await FacebookAuth.instance.webAndDesktopInitialize(
    appId: "1234567890", // ← Thay số này
    cookie: true,
    xfbml: true,
    version: "v17.0",
  );
  
  runApp(const BongBiengApp());
}
```

---

## 🧪 Kiểm Tra & Test

### 1. Clean & Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

### 2. Kiểm Tra Dependencies
```bash
flutter pub get
```

### 3. Build APK (Test Release Mode)
```bash
flutter build apk --release
```

### 4. Kiểm Tra Logcat
```bash
adb logcat | grep -i facebook
```

---

## ❌ Khắc Phục Lỗi Phổ Biến

### Lỗi: "Đăng nhập Facebook thất bại"

**Nguyên nhân:** 
- Facebook App ID không chính xác
- Hash Key không được đăng ký

**Giải pháp:**
1. Kiểm tra App ID trong `strings.xml` và `main.dart`
2. Kiểm tra Hash Key được thêm vào Facebook Settings
3. Đảm bảo Package Name khớp: `com.example.bongbieng_app`

### Lỗi: "Không thể lấy access token"

**Nguyên nhân:**
- Người dùng hủy bỏ
- Permissions không được cấp

**Giải pháp:**
- Kiểm tra xem người dùng có cho phép email permission không
- Thử lại với accounts khác

### Lỗi: "Email đã được sử dụng với phương thức khác"

**Nguyên nhân:**
- Email đã đăng ký bằng cách khác (Email/Password hoặc Google)

**Giải pháp:**
- Yêu cầu người dùng sử dụng phương thức đăng nhập ban đầu
- Hoặc liên kết tài khoản (nếu có feature này)

### Lỗi: "App Settings > Android không hiển thị"

**Giải pháp:**
1. Vào Facebook App
2. Settings > Basic
3. Scroll xuống, nhấp "Add Platform"
4. Chọn "Android"
5. Nhập Package Name và Hash Keys

---

## 📱 Permission Gửi & AndroidX

### Permissions đã thêm:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### Facebook Queries (Package Visibility):
```xml
<queries>
    <package android:name="com.facebook.katana" />
    <package android:name="com.facebook.lite" />
</queries>
```

---

## 📚 Tài Liệu Thêm

- [Facebook Flutter Auth Docs](https://pub.dev/packages/flutter_facebook_auth)
- [Firebase Auth for Flutter](https://firebase.google.com/docs/auth/flutter/start)
- [Facebook Developers Console](https://developers.facebook.com)

---

## ✅ Checklist Hoàn Thành

- [ ] Thêm Facebook App ID vào `strings.xml`
- [ ] Cập nhật App ID trong `main.dart`
- [ ] Lấy và đăng ký Hash Key trên Facebook
- [ ] Chạy `flutter clean && flutter pub get`
- [ ] Build và test app
- [ ] Kiểm tra logcat cho errors
- [ ] Test đăng nhập Facebook thành công

---

## 📞 Nếu Vẫn Gặp Lỗi

1. **Check Android Studio Logcat:**
   ```
   adb logcat | grep -i "facebook\|auth\|error"
   ```

2. **Verify Firebase Setup:**
   - Kiểm tra `google-services.json` đúng path
   - Firebase console có app được tạo không

3. **Test OAuth Flow:**
   - Mở Facebook app trên device
   - Đăng nhập Facebook
   - Cấp quyền cho app

4. **Clear Data & Cache:**
   ```
   adb shell pm clear com.example.bongbieng_app
   adb shell pm clear com.facebook.katana
   ```

---

**Ngày cập nhật:** 15/12/2025
**Phiên bản:** v1.0
