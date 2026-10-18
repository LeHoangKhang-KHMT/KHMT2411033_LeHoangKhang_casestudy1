import 'package:flutter/material.dart';

// Màn hình Cá nhân: dữ liệu tĩnh theo thiết kế, không dùng SQLite.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _soon(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chức năng "$name" sẽ được bổ sung sau')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String)>[
      (Icons.person_outline, 'Thông tin cá nhân'),
      (Icons.account_balance_wallet_outlined, 'Cài đặt ngân sách'),
      (Icons.category_outlined, 'Danh mục chi tiêu'),
      (Icons.backup_outlined, 'Sao lưu dữ liệu'),
      (Icons.lock_outline, 'Đổi mật khẩu'),
      (Icons.logout, 'Đăng xuất'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Cá nhân',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Color(0xFFE3ECFF),
                  child: Icon(Icons.person, size: 36, color: Color(0xFF2F6BFF)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Nguyễn Văn A',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('nguyenvana@example.com', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  ListTile(
                    leading: Icon(
                      items[i].$1,
                      color: i == items.length - 1 ? Colors.red : const Color(0xFF2F6BFF),
                    ),
                    title: Text(
                      items[i].$2,
                      style: TextStyle(color: i == items.length - 1 ? Colors.red : null),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () => _soon(context, items[i].$2),
                  ),
                  if (i < items.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
