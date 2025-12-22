import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bongbieng_app/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ================= MOCK FIREBASE CORE =================
void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel =
  MethodChannel('plugins.flutter.io/firebase_core');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    channel,
        (MethodCall methodCall) async {
      if (methodCall.method == 'Firebase#initializeCore') {
        return [
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': 'test',
              'appId': 'test',
              'messagingSenderId': 'test',
              'projectId': 'test',
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
  setupFirebaseMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets(
    'App khoi dong khi CHUA dang nhap thi hien WelcomeScreen',
        (WidgetTester tester) async {
      // Pump app
      await tester.pumpWidget(const BongBiengApp());

      // Cho StreamBuilder rebuild
      await tester.pumpAndSettle();

      // Verify: WelcomeScreen tồn tại
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.textContaining('Chào'), findsWidgets);
    },
  );
}
