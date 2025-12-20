import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/product_model.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
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

  // Lưu sản phẩm vào SQLite
  Future<void> insertProducts(List<ProductModel> products) async {
    final dbClient = await db;
    Batch batch = dbClient.batch();
    for (var product in products) {
      batch.insert('products', {
        'id': product.id,
        'name': product.name,
        'categoryId': product.categoryId,
        'categoryName': product.categoryName,
        'description': product.description,
        'basePrice': product.basePrice,
        'isBestSeller': product.isBestSeller ? 1 : 0, // SQLite không có bool
        'image': (product.image.isNotEmpty && product.image.startsWith('http'))
            ? product.image
            : 'https://via.placeholder.com/300x300.png?text=No+Image',

      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  // Lấy toàn bộ sản phẩm từ SQLite
  Future<List<ProductModel>> getProducts() async {
    final dbClient = await db;
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
        image: (maps[i]['image'] != null &&
            maps[i]['image'].toString().startsWith('http'))
            ? maps[i]['image']
            : 'https://via.placeholder.com/300x300.png?text=No+Image',

      );
    });
  }
}