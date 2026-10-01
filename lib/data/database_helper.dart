import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon INTEGER NOT NULL,
        color TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    // Dữ liệu danh mục mặc định
    final defaultCategories = [
      {'name': 'Ăn uống', 'icon': 0xe56c, 'color': '#FF6B6B', 'type': 'expense'},
      {'name': 'Di chuyển', 'icon': 0xe1d7, 'color': '#4D96FF', 'type': 'expense'},
      {'name': 'Mua sắm', 'icon': 0xe59c, 'color': '#9B59B6', 'type': 'expense'},
      {'name': 'Hóa đơn', 'icon': 0xe8b0, 'color': '#6BCB77', 'type': 'expense'},
      {'name': 'Giáo dục', 'icon': 0xe80c, 'color': '#16A085', 'type': 'expense'},
      {'name': 'Khác', 'icon': 0xe574, 'color': '#95A5A6', 'type': 'expense'},
      {'name': 'Lương', 'icon': 0xe2bc, 'color': '#34A853', 'type': 'income'},
      {'name': 'Thu nhập khác', 'icon': 0xe263, 'color': '#2F6BFF', 'type': 'income'},
    ];

    for (final cat in defaultCategories) {
      await db.insert('categories', cat);
    }
  }

  // ---------------- CATEGORY CRUD ----------------

  Future<int> insertCategory(CategoryModel category) async {
    final db = await database;
    return await db.insert('categories', category.toMap()..remove('id'));
  }

  Future<List<CategoryModel>> getCategories({String? type}) async {
    final db = await database;
    final maps = type == null
        ? await db.query('categories')
        : await db.query('categories', where: 'type = ?', whereArgs: [type]);
    return maps.map((m) => CategoryModel.fromMap(m)).toList();
  }

  // ---------------- TRANSACTION CRUD ----------------

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap()..remove('id'));
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC, id DESC');
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  // Lấy giao dịch kèm thông tin danh mục (join), dùng cho màn hình Dashboard
  Future<List<Map<String, dynamic>>> getTransactionsWithCategory() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT t.id, t.type, t.amount, t.date, t.note,
             c.id as categoryId, c.name as categoryName, c.icon as categoryIcon, c.color as categoryColor
      FROM transactions t
      INNER JOIN categories c ON t.categoryId = c.id
      ORDER BY t.date DESC, t.id DESC
    ''');
  }

  // Tổng thu nhập
  Future<double> getTotalIncome() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = 'income'",
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  // Tổng chi tiêu
  Future<double> getTotalExpense() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = 'expense'",
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  // Số dư hiện tại = thu nhập - chi tiêu
  Future<double> getBalance() async {
    final income = await getTotalIncome();
    final expense = await getTotalExpense();
    return income - expense;
  }
}
