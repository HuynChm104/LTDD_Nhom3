import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bongbieng_app/main.dart';
import 'package:firebase_core/firebase_core.dart';

// HÀM GIẢ LẬP FIREBASE (Để tránh lỗi Crash khi chạy test)
void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Giả lập Firebase Core
  const MethodChannel channel = MethodChannel('plugins.flutter.io/firebase_core');

  // Đăng ký mock handler để trả về thành công cho mọi lệnh gọi Firebase
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
        (MethodCall methodCall) async {
      if (methodCall.method == 'Firebase#initializeCore') {
        return [
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': '123',
              'appId': '123',
              'messagingSenderId': '123',
              'projectId': '123',
            },
            'pluginConstants': {},
          }
        ];
      }
      if (methodCall.method == 'Firebase#initializeApp') {
        return {
          'name': methodCall.arguments['appName'],
          'options': methodCall.arguments['options'],
          'pluginConstants': {},
        };
      }
      return null;
    },
  );
}

void main() {
  // 1. Gọi hàm setup Mock trước khi chạy test
  setupFirebaseMocks();

  setUpAll(() async {
    // Khởi tạo Firebase giả
    await Firebase.initializeApp();
  });

  testWidgets('Test xem App co khoi dong dung man hinh startScreen khong', (WidgetTester tester) async {
    // 2. TẠO MỘT MÀN HÌNH GIẢ ĐỂ TEST
    const Widget myTestScreen = Scaffold(
      body: Center(
        child: Text('Day la man hinh Test'),
      ),
    );

    // 3. KHỞI TẠO APP VỚI MÀN HÌNH GIẢ
    await tester.pumpWidget(const BongBiengApp(startScreen: myTestScreen));
    await tester.pump();

    // 4. KIỂM TRA KẾT QUẢ (VERIFY)
    expect(find.text('Day la man hinh Test'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });
}