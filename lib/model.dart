import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as pathd;
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class AllData with ChangeNotifier {
  TextEditingController controller = TextEditingController();
  Database db;
  String dbPath;
  var items = List<String>();
  var indx = 0;
  var edt = false;
  var txtDList = List<TextDecoration>();
  var txtDDone = List<String>();
  var itemIds = List<int>();

  static AllData instance = AllData._();
  AllData._();

  Future createAndOpenDBAndGetData() async {
    Directory path = await getApplicationDocumentsDirectory();
    dbPath = pathd.join(path.path, "db2.db");
    print("db path = $dbPath");
    db = await openDatabase(dbPath, version: 1, onCreate: this.createTable);
    getData();
    notifyListeners();
  }

  Future createTable(Database db, int version) async {
    await db.execute(
        """CREATE TABLE IF NOT EXISTS todoItem (id INTEGER PRIMARY KEY,item TEXT NOT NULL,done TEXT NOT NULL)""");
    await db.close();
  }

  Future getData() async {
    db = await openDatabase(dbPath);
    var count = Sqflite.firstIntValue(
        await db.rawQuery('select count(*) from todoItem'));
    if (count != 0) {
      try {
        List<Map> list = await db.rawQuery('SELECT * FROM todoItem');
        await db.close();
        items.clear();
        txtDDone.clear();
        txtDList.clear();
        itemIds.clear();
        for (int i = 0; i < list.length; i++) {
          items.add(list[i]["item"]);
          txtDDone.add(list[i]["done"]);
          itemIds.add(list[i]["id"]);
        }
        for (int i = 0; i < txtDDone.length; i++) {
          if (txtDDone[i] == 'true') {
            txtDList.insert(i, TextDecoration.lineThrough);
          } else {
            txtDList.insert(i, TextDecoration.none);
          }
        }
      } catch (e) {}
    }
  }

  changeListView() async {
    if (edt) {
      items[indx] = controller.text;
      try {
        db = await openDatabase(dbPath);
        await db.rawQuery('update todoItem set item = ? where id = ?',
            [controller.text, itemIds[indx]]);
        await db.close();
      } catch (e) {
        print("error in update: $e");
      }
    } else {
      if (items == null) {
        items = List<String>();
        txtDDone = List<String>();
      }
      try {
        items.add(controller.text);
        txtDDone.add("false");
        txtDList.add(TextDecoration.none);
      } catch (e) {
        print("error in adding: $e");
      }
      try {
        db = await openDatabase(dbPath);
        await db.rawQuery(
            'insert into todoItem(item,done) values("${controller.text}","false")');
        await db.close();
      } catch (e) {
        print("error in insert: $e");
      }
    }
    notifyListeners();
  }

  deleteValue() async {
    items.removeAt(indx);
    txtDDone.removeAt(indx);
    txtDList.removeAt(indx);

    try {
      db = await openDatabase(dbPath);
      await db.rawQuery('delete from todoItem where id = ?', [itemIds[indx]]);
      await db.close();
    } catch (e) {
      print("error in delete: $e");
    }
    notifyListeners();
  }

  handleAccept(int data, int index) async {
    String itemToMove = items[data];
    items.removeAt(data);
    items.insert(index, itemToMove);

    itemToMove = txtDDone[data];
    txtDDone.removeAt(data);
    txtDDone.insert(index, itemToMove);

    txtDList.clear();

    for (int i = 0; i < txtDDone.length; i++) {
      if (txtDDone[i] == "true") {
        txtDList.insert(i, TextDecoration.lineThrough);
      } else {
        txtDList.insert(i, TextDecoration.none);
      }
    }

    try {
      db = await openDatabase(dbPath);
      await db.rawQuery('delete from todoItem');
      await db.close();
    } catch (e) {
      print("error in deleting: $e");
    }

    for (int i = 0; i < items.length; i++) {
      try {
        db = await openDatabase(dbPath);
        await db.rawQuery(
            'insert into todoItem(item,done) values("${items[i]}","${txtDDone[i]}")');
        await db.close();
      } catch (e) {
        print("error in update: $e");
      }
    }
    notifyListeners();
  }

  makeStrikeThoroughText() async {
    if (txtDDone[indx] == "true") {
      txtDDone[indx] = "false";
      txtDList[indx] = TextDecoration.none;
    } else {
      txtDDone[indx] = "true";
      txtDList[indx] = TextDecoration.lineThrough;
    }
    try {
      db = await openDatabase(dbPath);
      await db.rawQuery('update todoItem set done = ? where id = ?',
          ["${txtDDone[indx]}", itemIds[indx]]);
      await db.close();
    } catch (e) {
      print("error in update: $e");
    }
    notifyListeners();
  }

  FutureOr<dynamic> StartingDataFetch(dynamic t){
    notifyListeners();
  }
}
