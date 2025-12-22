import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ZaloPayService {
  // Thông tin tài khoản Sandbox Public mặc định từ tài liệu
  static const String appId = "553";
  static const String key1 = "9phuAOYhan4urywHTh0ndEXiV3pKHr5Q";

  // Endpoint chuẩn Sandbox theo tài liệu bạn cung cấp
  static const String endpoint = "https://sandbox.zalopay.com.vn/v001/tpe/createorder";

  static Future<Map<String, dynamic>?> createOrder(int amount) async {
    final DateTime now = DateTime.now();
    final int appTime = now.millisecondsSinceEpoch; // Unix timestamp in miliseconds

    // apptransid: yymmdd_xxxx. Mã giao dịch phải bắt đầu theo format yymmdd
    final String dateStr = DateFormat('yyMMdd').format(now);
    final String appTransId = "${dateStr}_${appTime}";

    const String appUser = "BongBieng_User";

    // embeddata và item phải là JSON string theo đặc tả
    final String embedData = jsonEncode({"merchantinfo": "embeddata123"});
    final String item = jsonEncode([]);

    // CÔNG THỨC TẠO MAC CHUẨN:
    // appid + "|" + apptransid + "|" + appuser + "|" + amount + "|" + apptime + "|" + embeddata + "|" + item
    final String rawData = "$appId|$appTransId|$appUser|$amount|$appTime|$embedData|$item";

    // Tính toán mã băm HMAC-SHA256 với Key1
    final hmac256 = Hmac(sha256, utf8.encode(key1));
    final hashMac = hmac256.convert(utf8.encode(rawData)).toString();

    print("--- DEBUG THEO TÀI LIỆU ZALOPAY ---");
    print("Raw Data MAC: $rawData");
    print("MAC Result: $hashMac");

    try {
      // Gửi request POST với Content-Type: application/x-www-form-urlencoded
      final response = await http.post(
        Uri.parse(endpoint),
        body: {
          "appid": appId,
          "appuser": appUser,
          "apptransid": appTransId,
          "apptime": appTime.toString(),
          "amount": amount.toString(),
          "item": item,
          "embeddata": embedData,
          "description": "Thanh toan don hang Bong Bieng #$appTransId",
          "bankcode": "zalopayapp", // Bắt buộc cho mô hình Mobile Web to App
          "mac": hashMac,           // Thông tin chứng thực
        },
      );


    print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("ZaloPay Error: $e");
    }
    return null;
  }
}