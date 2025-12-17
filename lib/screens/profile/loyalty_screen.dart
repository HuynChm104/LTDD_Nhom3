import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bongbieng_app/utils/constants.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  // Hàm tính toán Hạng dựa trên điểm
  Map<String, dynamic> _calculateRank(int points) {
    if (points < 1000) {
      return {
        'rankName': 'Thành viên Mới',
        'nextRankPoints': 1000,
        'nextRankName': 'Hạng Bạc',
        'progress': points / 1000,
        'colors': [const Color(0xFF1E3C72), const Color(0xFF2A5298)], // Xanh
      };
    } else if (points < 3000) {
      return {
        'rankName': 'Hạng Bạc',
        'nextRankPoints': 3000,
        'nextRankName': 'Hạng Vàng',
        'progress': (points - 1000) / (3000 - 1000),
        'colors': [const Color(0xFF757F9A), const Color(0xFFD7DDE8)], // Bạc
      };
    } else {
      return {
        'rankName': 'Hạng Vàng',
        'nextRankPoints': 10000, // Max
        'nextRankName': 'Max Level',
        'progress': 1.0,
        'colors': [const Color(0xFFFFD700), const Color(0xFFFDB931)], // Vàng
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userIdDisplay = user?.uid.substring(0, 8).toUpperCase() ?? "UNKNOWN"; // Lấy 8 ký tự đầu của UID làm mã

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Hạng thành viên", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Dùng StreamBuilder để lấy dữ liệu điểm Realtime từ Firestore
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Lấy điểm từ Firebase. Nếu chưa có trường 'loyaltyPoints' thì mặc định là 0
          int currentPoints = 0;
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            currentPoints = (data?['loyaltyPoints'] ?? 0) as int;
          }

          // Tính toán hạng
          final rankInfo = _calculateRank(currentPoints);
          final int nextRankPoints = rankInfo['nextRankPoints'];
          final double progress = (rankInfo['progress'] as double).clamp(0.0, 1.0);

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // 1. THẺ THÀNH VIÊN
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: rankInfo['colors'],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Icon(Icons.workspace_premium, size: 150, color: Colors.white.withOpacity(0.15)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("BÔNG BIÊNG MEMBER", style: TextStyle(color: Colors.white70, letterSpacing: 1.5, fontSize: 12)),
                                Icon(Icons.stars, color: Colors.white),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Hạng hiện tại", style: TextStyle(color: Colors.white70, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(
                                    rankInfo['rankName'].toString().toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("$currentPoints điểm", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                Text("ID: $userIdDisplay", style: const TextStyle(color: Colors.white70)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 2. THANH TIẾN ĐỘ
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tiến độ lên ${rankInfo['nextRankName']}", style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold)),
                          Text("${nextRankPoints - currentPoints} điểm nữa", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 3. QUYỀN LỢI (Giữ nguyên, chỉ highlight dựa theo điểm)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Đặc quyền hạng thành viên", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      _buildBenefitItem("Thành viên Mới", Colors.grey, ["Tích điểm 5%", "Mã sinh nhật"], currentPoints < 1000),
                      _buildBenefitItem("Hạng Bạc (Silver)", const Color(0xFF607D8B), ["Tích điểm 8%", "Freeship 2 đơn"], currentPoints >= 1000 && currentPoints < 3000),
                      _buildBenefitItem("Hạng Vàng (Gold)", Colors.amber, ["Tích điểm 10%", "Quà đặc biệt"], currentPoints >= 3000),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBenefitItem(String rank, Color color, List<String> benefits, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey[50],
        border: Border.all(color: isActive ? color : Colors.grey[200]!, width: isActive ? 2 : 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isActive ? [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10)] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium, color: color),
              const SizedBox(width: 10),
              Text(rank, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
              if (isActive) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text("Hiện tại", style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
                )
              ]
            ],
          ),
          const Divider(height: 20),
          ...benefits.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, size: 16, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(b, style: TextStyle(fontSize: 13, color: Colors.grey[800])),
              ],
            ),
          )),
        ],
      ),
    );
  }
}