import 'package:flutter/material.dart';
import '../common/helpers.dart';
import '../data/database_helper.dart';
import '../data/models.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;

  double balance = 0;
  double totalIncome = 0;
  double totalExpense = 0;
  List<Map<String, dynamic>> recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Đọc dữ liệu thật từ SQLite
  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;
    final income = await db.getTotalIncome();
    final expense = await db.getTotalExpense();
    final rows = await db.getTransactionsWithCategory();
    if (!mounted) return;
    setState(() {
      totalIncome = income;
      totalExpense = expense;
      balance = income - expense;
      recentTransactions = rows.take(5).toList();
    });
  }

  Future<void> _openAdd() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    if (changed == true) _loadData();
  }

  Future<void> _openEdit(Map<String, dynamic> row) async {
    final transaction = TransactionModel(
      id: row['id'] as int,
      type: row['type'] as String,
      categoryId: row['categoryId'] as int,
      amount: (row['amount'] as num).toDouble(),
      date: row['date'] as String,
      note: (row['note'] as String?) ?? '',
    );
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(transaction: transaction),
      ),
    );
    if (changed == true) _loadData();
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
                          Icon(Icons.remove_red_eye_outlined,
                              color: Colors.white70, size: 16),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        formatCurrency(balance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.account_balance_wallet,
                    color: Colors.white, size: 56),
              ],
            ),
          ),
          const SizedBox(height: 10),
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
                  amount: formatCurrency(totalIncome),
                  icon: Icons.arrow_downward,
                  color: const Color(0xFF34A853),
                  backgroundColor: const Color(0xFFE8F7EC),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'TỔNG CHI TIÊU',
                  amount: formatCurrency(totalExpense),
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

          if (recentTransactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'Chưa có giao dịch nào.\nNhấn nút + để thêm giao dịch đầu tiên.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...recentTransactions.map(
                  (row) => _TransactionTile(row: row, onTap: () => _openEdit(row)),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2F6BFF),
        onPressed: _openAdd,
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
                backgroundColor: color.withAlpha(50),
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
  final Map<String, dynamic> row;
  final VoidCallback onTap;

  const _TransactionTile({required this.row, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isExpense = row['type'] == 'expense';
    final amount = (row['amount'] as num).toDouble();
    final categoryName = row['categoryName'] as String;
    final note = (row['note'] as String?) ?? '';
    final color = colorFromHex(row['categoryColor'] as String);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color,
              child: Icon(iconForCategory(categoryName), color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.isEmpty ? categoryName : note,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$categoryName   ${toDisplayDate(row['date'] as String)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Text(
              '${isExpense ? '-' : '+'}${formatCurrency(amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isExpense ? const Color(0xFFE64545) : const Color(0xFF34A853),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
