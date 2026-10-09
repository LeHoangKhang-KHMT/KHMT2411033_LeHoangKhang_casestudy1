import 'package:flutter/material.dart';

// Định dạng số có dấu chấm ngăn cách hàng nghìn: 5000000 -> "5.000.000"
String formatNumber(num value) {
  final digits = value.abs().round().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

// 5000000 -> "5.000.000 đ", -50000 -> "-50.000 đ"
String formatCurrency(num value) {
  return '${value < 0 ? '-' : ''}${formatNumber(value)} đ';
}

// Ngày lưu trong database dạng yyyy-MM-dd
String toIsoDate(DateTime d) {
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

DateTime parseIsoDate(String iso) {
  return DateTime.tryParse(iso) ?? DateTime.now();
}

// "2024-09-03" -> "03/09/2024"
String toDisplayDate(String iso) {
  final parts = iso.split('-');
  if (parts.length != 3) return iso;
  return '${parts[2]}/${parts[1]}/${parts[0]}';
}

// "#FF6B6B" -> Color
Color colorFromHex(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

// Icon theo tên danh mục
IconData iconForCategory(String name) {
  switch (name) {
    case 'Ăn uống':
      return Icons.restaurant;
    case 'Di chuyển':
      return Icons.directions_car;
    case 'Mua sắm':
      return Icons.shopping_cart;
    case 'Hóa đơn':
      return Icons.receipt_long;
    case 'Giáo dục':
      return Icons.school;
    case 'Lương':
      return Icons.attach_money;
    case 'Thu nhập khác':
      return Icons.monetization_on;
    default:
      return Icons.category;
  }
}
