import 'package:sqflite/sqflite.dart';

class MemoModel {
  static const String tableMemos = 'memos';
  static const String columnId = 'id';
  static const String columnContent = 'content';
  static const String columitem = 'item';

  late Database _database;

  Future<void> init() async {
    _database = await openDatabase(
      'memo.db',
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $tableMemos (
            $columnId TEXT PRIMARY KEY,
            $columnContent TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<Map<String, dynamic>>> getMemos() async {
    return _database.query(tableMemos);
  }

  Future<void> addMemo(String id, String content) async {
    await _database.insert(
      tableMemos,
      {
        columnId: id,
        columnContent: content,
      },
    );
  }

  Future<void> updateMemo(String id, String content) async {
    await _database.update(
      tableMemos,
      {
        columnContent: content,
      },
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteMemo(String id) async {
    await _database.delete(
      tableMemos,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}