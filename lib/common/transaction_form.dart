import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/database_helper.dart';
import '../data/models.dart';
import 'helpers.dart';


class TransactionForm extends StatefulWidget {
  final TransactionModel? transaction;

  const TransactionForm({super.key, this.transaction});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  late bool isExpense;
  late DateTime selectedDate;
  late final TextEditingController amountController;
  late final TextEditingController noteController;

  List<CategoryModel> categories = [];
  CategoryModel? selectedCategory;

  bool get isEdit => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    isExpense = t == null ? true : t.type == 'expense';
    selectedDate = t == null ? DateTime.now() : parseIsoDate(t.date);
    amountController =
        TextEditingController(text: t == null ? '' : formatNumber(t.amount));
    noteController = TextEditingController(text: t?.note ?? '');
    _loadCategories(preselectId: t?.categoryId);
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories({int? preselectId}) async {
    final list = await DatabaseHelper.instance
        .getCategories(type: isExpense ? 'expense' : 'income');
    if (!mounted) return;
    setState(() {
      categories = list;
      selectedCategory = list.isEmpty
          ? null
          : list.firstWhere((c) => c.id == preselectId, orElse: () => list.first);
    });
  }

  void _setType(bool expense) {
    if (isExpense == expense) return;
    setState(() => isExpense = expense);
    _loadCategories();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  void _pickCategory() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: categories.map((cat) {
              final color = colorFromHex(cat.color);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withAlpha(40),
                  child: Icon(iconForCategory(cat.name), color: color),
                ),
                title: Text(cat.name),
                onTap: () {
                  setState(() => selectedCategory = cat);
                  Navigator.pop(sheetContext);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    final amount = double.tryParse(amountController.text.replaceAll('.', '').trim());
    if (selectedCategory == null) {
      _showMessage('Vui lòng chọn danh mục');
      return;
    }
    if (amount == null || amount <= 0) {
      _showMessage('Vui lòng nhập số tiền hợp lệ');
      return;
    }

    final transaction = TransactionModel(
      id: widget.transaction?.id,
      type: isExpense ? 'expense' : 'income',
      categoryId: selectedCategory!.id!,
      amount: amount,
      date: toIsoDate(selectedDate),
      note: noteController.text.trim(),
    );

    if (isEdit) {
      await DatabaseHelper.instance.updateTransaction(transaction);
    } else {
      await DatabaseHelper.instance.insertTransaction(transaction);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Widget _typeButton(String label, bool expenseValue, Color activeColor) {
    final selected = isExpense == expenseValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setType(expenseValue),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = selectedCategory;
    final categoryColor =
    category == null ? Colors.grey : colorFromHex(category.color);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chi tiêu / Thu nhập
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _typeButton('Chi tiêu', true, const Color(0xFFFF6B6B)),
              _typeButton('Thu nhập', false, const Color(0xFF34A853)),
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
                  backgroundColor: categoryColor.withAlpha(40),
                  child: Icon(
                    category == null ? Icons.category : iconForCategory(category.name),
                    color: categoryColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(category?.name ?? 'Chọn danh mục',
                    style: const TextStyle(fontSize: 15)),
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
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
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
                Text(toDisplayDate(toIsoDate(selectedDate)),
                    style: const TextStyle(fontSize: 15)),
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
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E56C4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text(
              'Lưu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
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
