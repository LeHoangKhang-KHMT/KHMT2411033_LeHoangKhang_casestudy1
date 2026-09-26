import 'package:flutter/material.dart';

class EditTransactionScreen extends StatefulWidget {
  const EditTransactionScreen({super.key});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  // Dữ liệu mẫu ban đầu — trong thực tế sẽ được truyền vào từ danh sách giao dịch
  bool isExpense = true; // true = Chi tiêu, false = Thu nhập
  String selectedCategory = 'Ăn uống';
  DateTime selectedDate = DateTime(2025, 4, 12);

  late final TextEditingController amountController =
      TextEditingController(text: '100.000');
  late final TextEditingController noteController =
      TextEditingController(text: 'Ăn trưa');

  final List<Map<String, dynamic>> categories = [
    {'name': 'Ăn uống', 'icon': Icons.restaurant, 'color': const Color(0xFFFF6B6B)},
    {'name': 'Di chuyển', 'icon': Icons.directions_car, 'color': const Color(0xFF4D96FF)},
    {'name': 'Mua sắm', 'icon': Icons.shopping_bag, 'color': const Color(0xFFFFB84C)},
    {'name': 'Hóa đơn', 'icon': Icons.receipt_long, 'color': const Color(0xFF6BCB77)},
    {'name': 'Khác', 'icon': Icons.category, 'color': const Color(0xFF9B59B6)},
  ];

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _pickCategory() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: categories.map((cat) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: (cat['color'] as Color).withOpacity(0.15),
                  child: Icon(cat['icon'] as IconData, color: cat['color'] as Color),
                ),
                title: Text(cat['name'] as String),
                onTap: () {
                  setState(() => selectedCategory = cat['name'] as String);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Map<String, dynamic> get _currentCategory =>
      categories.firstWhere((c) => c['name'] == selectedCategory, orElse: () => categories.first);

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Sửa giao dịch',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle Chi tiêu / Thu nhập
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isExpense = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isExpense ? const Color(0xFFFF6B6B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Chi tiêu',
                          style: TextStyle(
                            color: isExpense ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isExpense = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isExpense ? const Color(0xFFFF6B6B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Thu nhập',
                          style: TextStyle(
                            color: !isExpense ? Colors.white : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Danh mục
            const Text('Danh mục', style: _labelStyle),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickCategory,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: _fieldDecoration,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: (_currentCategory['color'] as Color).withOpacity(0.15),
                      child: Icon(
                        _currentCategory['icon'] as IconData,
                        color: _currentCategory['color'] as Color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(selectedCategory, style: const TextStyle(fontSize: 15)),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Số tiền
            const Text('Số tiền', style: _labelStyle),
            const SizedBox(height: 8),
            Container(
              decoration: _fieldDecoration,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Nhập số tiền',
                  border: InputBorder.none,
                  suffixText: 'đ',
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Ngày giao dịch
            const Text('Ngày giao dịch', style: _labelStyle),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: _fieldDecoration,
                child: Row(
                  children: [
                    Text(_formatDate(selectedDate), style: const TextStyle(fontSize: 15)),
                    const Spacer(),
                    const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Ghi chú
            const Text('Ghi chú', style: _labelStyle),
            const SizedBox(height: 8),
            Container(
              decoration: _fieldDecoration,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Nhập ghi chú (tùy chọn)',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã cập nhật giao dịch')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E56C4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Lưu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const TextStyle _labelStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: Colors.black87,
);

final BoxDecoration _fieldDecoration = BoxDecoration(
  border: Border.all(color: const Color(0xFFE0E0E0)),
  borderRadius: BorderRadius.circular(12),
);
