import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_crud/local/models.dart';

class SQLLocalHelper {
  static Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'database.db'),
      onCreate: (database, version) async {
        await database.execute("CREATE TABLE Items(id INTEGER PRIMARY KEY AUTOINCREMENT, title VACHAR(255) NOT NULL, description TEXT NOT NULL)");
      },
      version: 1,
    );
  }

  static Future<int> createItem(Item item) async {
    final Database db = await initializeDB();
    return await db.insert(
      'Items',
      item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateItem(Item item) async {
    final Database db = await initializeDB();
    return await db.update(
      'Items',
      {'title': item.title, 'description': item.description},
      where: "id = ?",
      whereArgs: [item.id],
    );
  }

  static Future<List<Item>> getItems() async {
    final db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('Items');
    return queryResult.map((e) => Item.fromMap(e)).toList();
  }

  static Future<void> deleteItem(int id) async {
    final db = await initializeDB();
    try {
      await db.delete("Items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      Logger().i("Something went wrong when deleting an item: $err");
    }
  }
}
