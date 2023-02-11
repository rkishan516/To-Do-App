import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart' as pathd;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

part 'todo_list_repository.g.dart';

@riverpod
class TodoListRepositoryNotifier extends _$TodoListRepositoryNotifier {
  late Database db;
  @override
  FutureOr<void> build() async {
    ref.keepAlive();
    ref.onDispose(() async {
      await db.close();
    });
    Directory path = await getApplicationDocumentsDirectory();
    final dbPath = pathd.join(path.path, "db2.db");
    db = await openDatabase(dbPath, version: 1, onCreate: createTable);
  }

  Future createTable(Database db, int version) async {
    await db.execute(
        """CREATE TABLE IF NOT EXISTS todoItem (id INTEGER PRIMARY KEY,item TEXT NOT NULL,done TEXT NOT NULL)""");
  }

  Future<void> insertTodo(String item) async {
    try {
      await db
          .rawQuery('insert into todoItem(item,done) values("$item","false")');
    } catch (e) {
      print("error in insert: $e");
    }
  }

  Future<void> updateTodoItem(String item, String id) async {
    try {
      await db.rawQuery(
        'update todoItem set item = ? where id = ?',
        [item, id.toString()],
      );
    } catch (e) {
      print("error in update: $e");
    }
  }

  deleteValue(String id) async {
    try {
      await db.rawQuery('delete from todoItem where id = ?', [id]);
    } catch (e) {
      print("error in delete: $e");
    }
  }

  Future<void> updateDoneState(bool done, String id) async {
    try {
      await db
          .rawQuery('update todoItem set done = ? where id = ?', ["$done", id]);
    } catch (e) {
      print("error in update: $e");
    }
  }

  Future<List<Map<String, Object?>>> getItems() async {
    return await db.rawQuery('SELECT * FROM todoItem');
  }
}
