class CategoryModel {
  final int? id;
  final String name;
  final int icon;
  final String color;
  final String type;

  const CategoryModel({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as int,
      color: map['color'] as String,
      type: map['type'] as String,
    );
  }
}

class TransactionModel {
  final int? id;
  final String type;
  final int categoryId;
  final double amount;
  final String date;
  final String note;

  const TransactionModel({
    this.id,
    required this.type,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'categoryId': categoryId,
      'amount': amount,
      'date': date,
      'note': note,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      type: map['type'] as String,
      categoryId: map['categoryId'] as int,
      amount: (map['amount'] as num).toDouble(),
      date: map['date'] as String,
      note: map['note'] as String? ?? '',
    );
  }
}
