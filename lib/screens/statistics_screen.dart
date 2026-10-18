import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../common/helpers.dart';
import '../data/database_helper.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  static const _blue = Color(0xFF2F6BFF);

  int _tab = 0; // 0 = Tháng này, 1 = Tháng trước, 2 = Năm nay
  List<Map<String, dynamic>> _rows = [];
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Trả về [từ ngày, đến ngày] theo tab đang chọn
  List<DateTime> _range() {
    final now = DateTime.now();
    switch (_tab) {
      case 1:
        return [DateTime(now.year, now.month - 1, 1), DateTime(now.year, now.month, 0)];
      case 2:
        return [DateTime(now.year, 1, 1), DateTime(now.year, 12, 31)];
      default:
        return [DateTime(now.year, now.month, 1), DateTime(now.year, now.month + 1, 0)];
    }
  }

  Future<void> _load() async {
    final r = _range();
    final rows = await DatabaseHelper.instance
        .getExpenseByCategory(toIsoDate(r[0]), toIsoDate(r[1]));
    final total = rows.fold<double>(0, (s, e) => s + (e['total'] as num).toDouble());
    if (!mounted) return;
    setState(() {
      _rows = rows;
      _total = total;
    });
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
    final values = _rows.map((e) => (e['total'] as num).toDouble()).toList();
    final colors = _rows.map((e) => colorFromHex(e['color'] as String)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Thống kê',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _tabButton('Tháng này', 0),
              _tabButton('Tháng trước', 1),
              _tabButton('Năm nay', 2),
            ],
          ),
          const SizedBox(height: 24),
          if (_rows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Text('Chưa có chi tiêu trong khoảng thời gian này.',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else ...[
            Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: CustomPaint(
                  painter: _DonutPainter(values, colors),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatCurrency(_total),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        const Text('Tổng chi tiêu',
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ..._rows.map((e) {
              final value = (e['total'] as num).toDouble();
              final percent = _total == 0 ? 0 : value / _total * 100;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colorFromHex(e['color'] as String),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(e['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Text(formatCurrency(value),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 48,
                      child: Text(
                        '${percent.toStringAsFixed(1)}%',
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

// Vẽ biểu đồ tròn (dạng vòng) bằng CustomPaint, không cần thêm package.
class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  _DonutPainter(this.values, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 32.0;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final total = values.fold<double>(0, (s, v) => s + v);
    if (total <= 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    double start = -math.pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 2 * math.pi;
      paint.color = colors[i];
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.values != values || old.colors != colors;
}
