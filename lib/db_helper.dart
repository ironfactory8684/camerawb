import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String tableTodo = 'todo';
final String columnId = '_id';
final String columnTitle = 'title';
final String columnDone = 'done';

class DBHelper {
  // 데이터베이스를 시작한다.
  Database? db;

  Future _openDb() async {
    final databasePath = await getDatabasesPath();
    String path = join(databasePath, 'wb_database.db');

    final db = await openDatabase(
      path,
      version: 1,
      onConfigure: (Database db) => {},
      onCreate: _onCreate,
      onUpgrade: (Database db, int oldVersion, int newVersion) => {},
    );
    return db;
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS wbFiles (
      id INTEGER PRIMARY KEY,
      path TEXT NOT NULL,
      created_at DATETIME NOT NULL
    )
  ''');
  }

  // 새로운 데이터를 추가한다.
  Future add(path) async {
    final db = await _openDb();
    await db.execute('''
    INSERT INTO wbFiles (path,created_at) VALUES('$path',DateTime('now'))''');
  }

  Future select() async {
    final db =await _openDb();
    List<Map> maps = await db.query('wbFiles',
        where: "date(created_at) = DATE('now')",
        // whereArgs: [id]
    );
    return maps;
  }

  // 변경된 데이터를 업데이트한다.
  Future update(item) async {
    final db = await _openDb();
    await db.update(
      'posts',  // table name
      {
        'title': 'changed post title ...',
        'content': 'changed post content ...',
      },  // update post row data
      where: 'id = ?',
      whereArgs: [item.id],
    );
    return item;
  }

  // 데이터를 삭제한다.
  Future<int> remove(int id) async {
    final db = await _openDb();
    await db.delete(
      'posts', // table name
      where: 'id = ?',
      whereArgs: [id],
    );
    return id;
  }
}
