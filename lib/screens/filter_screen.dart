import 'package:flutter/material.dart';
import '../common/helpers.dart';
import '../data/database_helper.dart';
import '../data/models.dart';

// Điều kiện lọc giao dịch.
class TransactionFilter {
  final bool income;
  final bool expense;
  final Set<int> categoryIds; // rỗng = tất cả danh mục
  final DateTime? from;
  final DateTime? to;
  final int? period; // 0 = Hôm nay, 1 = 7 ngày qua, 2 = Tháng này, 3 = Tùy chỉnh, null = không lọc

  const TransactionFilter({
    this.income = true,
    this.expense = true,
    this.categoryIds = const {},
    this.from,
    this.to,
    this.period,
  });

  bool get isActive =>
      !(income && expense) || categoryIds.isNotEmpty || from != null || to != null;
}

class FilterScreen extends StatefulWidget {
  final TransactionFilter initial;
  const FilterScreen({super.key, required this.initial});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late bool income;
  late bool expense;
  late Set<int> categoryIds;
  DateTime? from;
  DateTime? to;
  int? period;
  List<CategoryModel> categories = [];

  @override
  void initState() {
    super.initState();
    income = widget.initial.income;
    expense = widget.initial.expense;
    categoryIds = {...widget.initial.categoryIds};
    from = widget.initial.from;
    to = widget.initial.to;
    period = widget.initial.period;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final list = await DatabaseHelper.instance.getCategories();
    if (!mounted) return;
    setState(() => categories = list);
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? from : to) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        from = picked;
      } else {
        to = picked;
      }
    });
  }

  void _reset() {
    setState(() {
      income = true;
      expense = true;
      categoryIds.clear();
      from = null;
      to = null;
      period = null;
    });
  }

  // Chọn một mốc thời gian có sẵn
  void _selectPeriod(int p) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    setState(() {
      period = p;
      if (p == 0) {
        from = today;
        to = today;
      } else if (p == 1) {
        from = today.subtract(const Duration(days: 6));
        to = today;
      } else if (p == 2) {
        from = DateTime(now.year, now.month, 1);
        to = DateTime(now.year, now.month + 1, 0);
      } else {
        from = null;
        to = null;
      }
    });
  }

  void _apply() {
    // Bỏ chọn cả hai loại thì hiểu là lấy tất cả
    final both = !income && !expense;
    Navigator.pop(
      context,
      TransactionFilter(
        income: both ? true : income,
        expense: both ? true : expense,
        categoryIds: categoryIds,
        from: from,
        to: to,
        period: period,
      ),
    );
  }

  Widget _check(String label, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: const Color(0xFF2F6BFF),
    );
  }

  Widget _radio(String label, int value) {
    final selected = period == value;
    return InkWell(
      onTap: () => _selectPeriod(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? const Color(0xFF2F6BFF) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _dateBox(String hint, DateTime? value, bool isFrom) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _pickDate(isFrom),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value == null ? hint : toDisplayDate(toIsoDate(value)),
                  style: TextStyle(color: value == null ? Colors.grey : Colors.black87),
                ),
              ),
              const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const label = TextStyle(fontSize: 15, fontWeight: FontWeight.bold);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bộ lọc',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          TextButton(onPressed: _reset, child: const Text('Đặt lại')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Loại giao dịch', style: label),
          _check('Tất cả', income && expense, (v) {
            setState(() {
              income = v ?? false;
              expense = v ?? false;
            });
          }),
          _check('Thu nhập', income, (v) => setState(() => income = v ?? false)),
          _check('Chi tiêu', expense, (v) => setState(() => expense = v ?? false)),
          const SizedBox(height: 16),
          const Text('Danh mục', style: label),
          const SizedBox(height: 8),
          DropdownButtonFormField<int?>(
            value: categoryIds.isEmpty ? null : categoryIds.first,
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('Tất cả danh mục')),
              ...categories.map(
                    (c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.name)),
              ),
            ],
            onChanged: (v) => setState(() {
              categoryIds = v == null ? <int>{} : {v};
            }),
          ),
          const SizedBox(height: 16),
          const Text('Khoảng thời gian', style: label),
          _radio('Hôm nay', 0),
          _radio('7 ngày qua', 1),
          _radio('Tháng này', 2),
          _radio('Tùy chỉnh', 3),
          if (period == 3) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                _dateBox('Từ ngày', from, true),
                const SizedBox(width: 12),
                _dateBox('Đến ngày', to, false),
              ],
            ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E56C4),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Áp dụng', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
