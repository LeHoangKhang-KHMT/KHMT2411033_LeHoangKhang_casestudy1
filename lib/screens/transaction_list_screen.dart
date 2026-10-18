import 'package:flutter/material.dart';
import '../common/helpers.dart';
import '../data/database_helper.dart';
import '../data/models.dart';
import 'edit_transaction_screen.dart';
import 'filter_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  static const _blue = Color(0xFF2F6BFF);

  int _tab = 0; // 0 = Tất cả, 1 = Thu nhập, 2 = Chi tiêu
  TransactionFilter _filter = const TransactionFilter();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _rows = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    List<String>? types;
    if (_tab == 1) {
      types = ['income'];
    } else if (_tab == 2) {
      types = ['expense'];
    } else if (!(_filter.income && _filter.expense)) {
      types = [if (_filter.income) 'income', if (_filter.expense) 'expense'];
    }

    final rows = await DatabaseHelper.instance.searchTransactions(
      keyword: _searchController.text.trim(),
      types: types,
      categoryIds: _filter.categoryIds.toList(),
      fromDate: _filter.from == null ? null : toIsoDate(_filter.from!),
      toDate: _filter.to == null ? null : toIsoDate(_filter.to!),
    );
    if (!mounted) return;
    setState(() => _rows = rows);
  }

  Future<void> _openFilter() async {
    final result = await Navigator.push<TransactionFilter>(
      context,
      MaterialPageRoute(builder: (_) => FilterScreen(initial: _filter)),
    );
    if (result != null) {
      _filter = result;
      _load();
    }
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
      MaterialPageRoute(builder: (_) => EditTransactionScreen(transaction: transaction)),
    );
    if (changed == true) _load();
  }

  // Nhấn giữ một giao dịch để xóa
  Future<void> _confirmDelete(Map<String, dynamic> row) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa giao dịch'),
        content: const Text('Bạn có chắc muốn xóa giao dịch này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseHelper.instance.deleteTransaction(row['id'] as int);
      _load();
    }
  }

  Widget _tabButton(String text, int index) {
    final selected = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _tab = index);
          _load();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _blue : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: selected ? _blue : const Color(0xFFE0E0E0)),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Giao dịch',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _load(),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm giao dịch...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.filter_alt_outlined,
                    color: _filter.isActive ? _blue : Colors.grey,
                  ),
                  onPressed: _openFilter,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                _tabButton('Tất cả', 0),
                _tabButton('Thu nhập', 1),
                _tabButton('Chi tiêu', 2),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _rows.isEmpty
                ? const Center(
              child: Text('Không có giao dịch nào.', style: TextStyle(color: Colors.grey)),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _rows.length,
              itemBuilder: (context, i) => _tile(_rows[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(Map<String, dynamic> row) {
    final isIncome = row['type'] == 'income';
    final name = row['categoryName'] as String;
    final color = colorFromHex(row['categoryColor'] as String);
    final amount = (row['amount'] as num).toDouble();
    final note = (row['note'] as String?) ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: () => _openEdit(row),
        onLongPress: () => _confirmDelete(row),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(iconForCategory(name), color: color),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          note.isEmpty
              ? toDisplayDate(row['date'] as String)
              : '${toDisplayDate(row['date'] as String)} • $note',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isIncome ? '+' : '-'}${formatCurrency(amount)}',
              style: TextStyle(
                color: isIncome ? const Color(0xFF34A853) : const Color(0xFFE53935),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
