import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../domain/User.dart';

class SqliteService {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();

    return openDatabase(
      join(path, 'database.db'),
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE users(username TEXT PRIMARY KEY, displayName TEXT NOT NULL, email TEXT NOT NULL,'
          'role TEXT, educationLevel TEXT, birthDate TEXT, profileVisibility TEXT, state TEXT, landlinePhone TEXT,'
          'mobilePhone TEXT, occupation TEXT, workplace TEXT, address TEXT, additionalAddress TEXT, locality TEXT,'
          'postalCode TEXT, nif TEXT, photoUrl TEXT, token TEXT); CREATE TABLE settings(checkIntro INTEGER, checkLogin INTEGER,'
          'theme TEXT NOT NULL);',
        );
      },
      version: 1,
    );
  }

  Future<void> insertUser(User user, String token, String password) async {
    // Get a reference to the database.
    Database db = await getDatabase();

    await db.insert(
      'Users',
      user.toMap(token, password),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCheckIntro(int value) async {
    Database db = await getDatabase();

    await getCheckIntro() == null
        ? await db.rawInsert('INSERT INTO Settings(checkIntro) VALUES($value)')
        : await db.rawUpdate('UPDATE Settings SET checkIntro = $value');
  }

  Future<void> updateCheckLogin(int value) async {
    Database db = await getDatabase();

    await getCheckLogin() == null
        ? await db.rawInsert('INSERT INTO Settings(checkLogin) VALUES($value)')
        : await db.rawUpdate('UPDATE Settings SET checkLogin = $value');
  }

  Future<void> updateTheme(String value) async {
    Database db = await getDatabase();

    await getCheckLogin() == null
        ? await db.rawInsert('INSERT INTO Settings(theme) VALUES($value)')
        : await db.rawUpdate('UPDATE Settings SET theme = $value');
  }

  Future<bool?> getCheckIntro() async {
    Database db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('settings');

    if (maps.isNotEmpty && maps[0].containsKey('checkIntro')) {
      return maps[0]['checkIntro'] == 1 ? true : false;
    } else {
      return null;
    }
  }

  Future<bool?> getCheckLogin() async {
    Database db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('settings');

    if (maps.isNotEmpty && maps[0].containsKey('checkLogin')) {
      return maps[0]['checkLogin'] == 1 ? true : false;
    } else {
      return null;
    }
  }

  Future<String?> getLightTheme() async {
    Database db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('settings');

    if (maps.isNotEmpty && maps[0].containsKey('theme')) {
      return maps[0]['theme'];
    } else {
      return null;
    }
  }

  Future<User> getUser() async {
    // Get a reference to the database.
    final db = await getDatabase();

    // Query the table for all The Users.
    final List<Map<String, dynamic>> maps = await db.query('users');

    // Convert the List<Map<String, dynamic> into a List<User>.
    return User(
      displayName: maps[0]['displayName'],
      email: maps[0]['email'],
      username: maps[0]['username'],
      role: maps[0]['role'],
      educationLevel: maps[0]['educationalLevel'],
      birthDate: maps[0]['birthDate'],
      profileVisibility: maps[0]['profileVisibility'],
      state: maps[0]['state'],
      landlinePhone: maps[0]['landlinePhone'],
      mobilePhone: maps[0]['mobilePhone'],
      occupation: maps[0]['occupation'],
      workplace: maps[0]['workplace'],
      address: maps[0]['address'],
      additionalAddress: maps[0]['additionalAddress'],
      locality: maps[0]['locality'],
      postalCode: maps[0]['postalCode'],
      nif: maps[0]['nif'],
      photoUrl: maps[0]['photoUrl'],
    );
  }

  Future<String> getValue(String table, String value) async {
    Database db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query(table);

    return maps[0][value];
  }

  Future<String> getToken() async {
    Database db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('users');

    return maps[0]['token'];
  }

  Future<String> getPassword() async {
    Database db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('users');

    return maps[0]['password'];
  }

  Future<void> updateUser(User user, String token, String password) async {
    // Get a reference to the database.
    final db = await initializeDB();

    // Update the given Dog.
    await db.update(
      'users',
      user.toMap(token, password),
      // Ensure that the user has a matching id.
      where: 'username = ?',
      // Pass the user's id as a whereArg to prevent SQL injection.
      whereArgs: [user.username],
    );
  }

  Future<void> deleteUser(String username) async {
    // Get a reference to the database.
    final db = await initializeDB();

    // Remove the User from the database.
    await db.delete(
      'users',
      // Use a `where` clause to delete a specific user.
      where: 'username = ?',
      // Pass the user's id as a whereArg to prevent SQL injection.
      whereArgs: [username],
    );
  }

  Future<void> deleteUsersCache() async {
    // Get a reference to the database
    Database db = await getDatabase();

    // Replace 'your_table_name' with the name of the table where you store the cache
    String tableName = 'users';

    // Execute the query to delete all data from the table
    await db.rawDelete('DELETE FROM $tableName');
  }

  Future<Database> getDatabase() async {
    // Replace 'your_database_name.db' with your actual SQLite database name
    String path = await getDatabasesPath() + 'database.db';
    return openDatabase(path);
  }
}
