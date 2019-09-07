
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  
  static final _databaseName = "Transaction2.db";
  static final _databaseVersion = 1;

  static final table = 'transactions';
  static final tablecontact = 'contacts';
  
  static final columnId = '_id';
  static final columnTitle = 'title';
  static final columnTime = 'time';
  static final columnDate = 'date';
  static final studentName = 'name';



  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }
  
  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    /* await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnTitle TEXT NOT NULL,
            $columnTime INTEGER NOT NULL,
            $columnDate TEXT NOT NULL,
            $studentName TEXT NOT NULL
          ),
          '''); */
     await db.execute('''
          CREATE TABLE $tablecontact (
            $columnId INTEGER PRIMARY KEY,
            $studentName TEXT NOT NULL
          )
          ''');
          await db.execute('''
          
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnTitle TEXT NOT NULL,
            $columnTime INTEGER NOT NULL,
            $columnDate TEXT NOT NULL,
            $studentName TEXT NOT NULL
          )
          ''');
  }
  
  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<int> insertContact(Map<String, dynamic> row) async {
    Database db = await instance.database;
    print("inside store:"+row.values.toList().toString());
    return await db.insert(tablecontact, row);
  }


  Future<List<Map<String, dynamic>>> queryAllRowsAllUsers() async {
    Database db = await instance.database;
    return await db.query(table);
  }
  // All of the rows are returned as a list of maps, where each map is 
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows(String studentName) async {
    Database db = await instance.database;
    //return await db.query(table);
      return await db.query(table,
      columns: ["_id", "title", "time","date","name"],
      where: 'name = ?',
      whereArgs: [studentName]);
  }

  Future<List<Map<String, dynamic>>> queryAllRowsContacts() async {
    Database db = await instance.database;
    return await db.query(tablecontact);
  }
  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future<int> queryRowCountContact() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tablecontact'));
  }

  // We are assuming here that the id column in the map is set. The other 
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> updateContact(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(tablecontact, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is 
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteContact(int id) async {
    Database db = await instance.database;
    return await db.delete(tablecontact, where: '$columnId = ?', whereArgs: [id]);
  }
}