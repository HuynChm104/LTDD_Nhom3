import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Quan trọng để check Web
import '../../models/product_model.dart';

class DBHelper {
  static Database? _db;

  // Sử dụng getter tĩnh để dễ gọi từ mọi nơi
  static Future<Database?> get db async {
    if (kIsWeb) return null; // Web không dùng SQLite
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db;
  }

  static Future<Database?> _initDb() async {
    if (kIsWeb) return null;

    String path = join(await getDatabasesPath(), 'bongbieng.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE products (
          id TEXT PRIMARY KEY,
          name TEXT,
          categoryId TEXT,
          categoryName TEXT,
          description TEXT,
          basePrice REAL,
          isBestSeller INTEGER,
          image TEXT
        )
      ''');
    });
  }

  // Lưu sản phẩm: Check Web trước khi thực hiện
  static Future<void> insertProducts(List<ProductModel> products) async {
    if (kIsWeb) return; // Nếu là Web thì thoát luôn, không làm gì cả

    final dbClient = await db;
    if (dbClient == null) return;

    Batch batch = dbClient.batch();
    for (var product in products) {
      batch.insert('products', {
        'id': product.id,
        'name': product.name,
        'categoryId': product.categoryId,
        'categoryName': product.categoryName,
        'description': product.description,
        'basePrice': product.basePrice,
        'isBestSeller': product.isBestSeller ? 1 : 0,
        'image': (product.image.isNotEmpty && product.image.startsWith('http'))
            ? product.image
            : 'https://via.placeholder.com/300x300.png?text=No+Image',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  // Lấy sản phẩm: Web trả về danh sách rỗng để Provider tự gọi Firestore
  static Future<List<ProductModel>> getProducts() async {
    if (kIsWeb) return [];

    final dbClient = await db;
    if (dbClient == null) return [];

    final List<Map<String, dynamic>> maps = await dbClient.query('products');
    return List.generate(maps.length, (i) {
      return ProductModel(
        id: maps[i]['id'],
        name: maps[i]['name'],
        categoryId: maps[i]['categoryId'],
        categoryName: maps[i]['categoryName'],
        description: maps[i]['description'],
        basePrice: maps[i]['basePrice'],
        isBestSeller: maps[i]['isBestSeller'] == 1,
        image: (maps[i]['image'] != null && maps[i]['image'].toString().startsWith('http'))
            ? maps[i]['image']
            : 'https://via.placeholder.com/300x300.png?text=No+Image',
      );
    });
  }
}