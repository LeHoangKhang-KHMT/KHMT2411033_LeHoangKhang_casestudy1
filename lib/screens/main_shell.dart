import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'statistics_screen.dart';
import 'transaction_list_screen.dart';

// Khung chính: thanh điều hướng 4 tab dùng chung cho cả ứng dụng.
// Mỗi lần chuyển tab, màn hình được tạo lại nên dữ liệu luôn mới nhất.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  Widget _buildPage() {
    switch (_index) {
      case 1:
        return const TransactionListScreen();
      case 2:
        return const StatisticsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return DashboardScreen(onSeeAll: () => setState(() => _index = 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: const Color(0xFF2F6BFF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Giao dịch'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Thống kê'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }
}
