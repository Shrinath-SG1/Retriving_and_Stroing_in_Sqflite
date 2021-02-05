// import 'dart:html';
import 'dart:io';
import 'package:network_sqflite/model/user_model2.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static Database _database;
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'employee_manager.db');
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE EMPLOYEE('
          'id INTEGER PRIMARY KEY,'
          'email TEXT,'
          'username TEXT,'
          'name TEXT,'
          'phone TEXT,'
          ')');
      await db.execute('CREATE TABLE ADDRESS('
          'id INTEGER,'
          'street TEXT,'
          'suite TEXT,'
          'city TEXT,'
          'zipcode TEXT,'
          ' FOREIGN KEY (id) REFERENCES Employee (id),'
          ')');
    });
  }

  createEmployee(Employee newEmployee) async {
    await deleteAllEmployees();
    final db = await database;
    final res = await db.insert('Employee', newEmployee.toJson());

    return res;
  }

  Future<int> deleteAllEmployees() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM Employee');

    return res;
  }

  Future<List<Employee>> getAllEmployees() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM EMPLOYEE AS E AND ADDRESS AS A WHERE E.id=A.id");

    List<Employee> list =
        res.isNotEmpty ? res.map((c) => Employee.fromJson(c)).toList() : [];

    return list;
  }
}
