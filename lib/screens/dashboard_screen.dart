import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _TransactionItem {
  final String title;
  final String category;
  final String date;
  final double amount; // dương = thu nhập, âm = chi tiêu
  final IconData icon;
  final Color color;

  const _TransactionItem({
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.icon,
    required this.color,
  });
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;

  final double balance = 5000000;
  final double totalIncome = 8000000;
  final double totalExpense = 3000000;

  final List<_TransactionItem> transactions = const [
    _TransactionItem(
      title: 'Ăn trưa',
      category: 'Ăn uống',
      date: '03/09/2024',
      amount: -50000,
      icon: Icons.restaurant,
      color: Color(0xFFFF7A45),
    ),
    _TransactionItem(
      title: 'Xăng xe',
      category: 'Di chuyển',
      date: '03/09/2024',
      amount: -100000,
      icon: Icons.directions_car,
      color: Color(0xFF4D96FF),
    ),
    _TransactionItem(
      title: 'Lương tháng 9',
      category: 'Thu nhập',
      date: '01/09/2024',
      amount: 8000000,
      icon: Icons.savings,
      color: Color(0xFF34A853),
    ),
    _TransactionItem(
      title: 'Mua sắm',
      category: 'Mua sắm',
      date: '31/08/2024',
      amount: -300000,
      icon: Icons.shopping_cart,
      color: Color(0xFF9B59B6),
    ),
    _TransactionItem(
      title: 'Học phí',
      category: 'Giáo dục',
      date: '30/08/2024',
      amount: -500000,
      icon: Icons.school,
      color: Color(0xFF16A085),
    ),
  ];

  String _formatCurrency(num value) {
    final isNegative = value < 0;
    final absValue = value.abs().toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < absValue.length; i++) {
      if (i > 0 && (absValue.length - i) % 3 == 0) buffer.write('.');
      buffer.write(absValue[i]);
    }
    return '${isNegative ? '-' : ''}${buffer.toString()} đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        title: const Text(
          'Quản lý thu chi',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black87),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: const Text(
                    '3',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Thẻ số dư hiện tại
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2F6BFF), Color(0xFF1E4FD9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text(
                            'SỐ DƯ HIỆN TẠI',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.remove_red_eye_outlined, color: Colors.white70, size: 16),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _formatCurrency(balance).replaceAll('-', ''),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.account_balance_wallet, color: Colors.white, size: 56),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Dot indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == 0 ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == 0 ? const Color(0xFF2F6BFF) : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Tổng thu nhập / Tổng chi tiêu
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'TỔNG THU NHẬP',
                  amount: _formatCurrency(totalIncome),
                  icon: Icons.arrow_downward,
                  color: const Color(0xFF34A853),
                  backgroundColor: const Color(0xFFE8F7EC),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'TỔNG CHI TIÊU',
                  amount: _formatCurrency(totalExpense),
                  icon: Icons.arrow_upward,
                  color: const Color(0xFFE64545),
                  backgroundColor: const Color(0xFFFDEBEB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Giao dịch gần đây
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Giao dịch gần đây',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 4),

          ...transactions.map((t) => _TransactionTile(item: t, formatCurrency: _formatCurrency)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2F6BFF),
        onPressed: () {},
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (i) => setState(() => _currentNavIndex = i),
        selectedItemColor: const Color(0xFF2F6BFF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Giao dịch'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Thống kê'),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final _TransactionItem item;
  final String Function(num) formatCurrency;

  const _TransactionTile({required this.item, required this.formatCurrency});

  @override
  Widget build(BuildContext context) {
    final isExpense = item.amount < 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: item.color,
            child: Icon(item.icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '${item.category}   ${item.date}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '${isExpense ? '-' : '+'}${formatCurrency(item.amount.abs()).replaceFirst('-', '')}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isExpense ? const Color(0xFFE64545) : const Color(0xFF34A853),
            ),
          ),
        ],
      ),
    );
  }
}
