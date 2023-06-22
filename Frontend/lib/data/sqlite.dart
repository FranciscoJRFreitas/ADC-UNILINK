import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../domain/User.dart';

class SqliteService {
  static final SqliteService _singleton = SqliteService._internal();

  factory SqliteService() {
    return _singleton;
  }

  SqliteService._internal();

  void initializeDB() async {
    String path = await getDatabasesPath();
    String dbPath = join(path, 'database.db');

    // Delete the database
    //await deleteDatabase(dbPath);

    await openDatabase(
      dbPath,
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE users(username TEXT PRIMARY KEY, displayName TEXT NOT NULL, email TEXT NOT NULL,'
            'role TEXT, educationLevel TEXT, birthDate TEXT, profileVisibility TEXT, state TEXT,'
            'mobilePhone TEXT, occupation TEXT,token TEXT, password TEXT)');
        await database.execute(
            'CREATE TABLE settings(checkIntro TEXT, checkLogin TEXT,'
            'theme TEXT, pageIndex TEXT)');
        await database.insert('settings', {'checkIntro': null, 'checkLogin': null, 'theme': null, 'pageIndex': null});
      },
      version: 1,
    );
  }

  Future<Database> getDatabase() async {
    String path = join(await getDatabasesPath(), 'database.db');
    return openDatabase(path);
  }

  Future<void> insertUser(User user, String token, String password) async {
    // Get a reference to the database.
    Database db = await getDatabase();

    await db.insert(
      'users',
      user.toMap(token, password),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCheckIntro(String value) async {
    Database db = await getDatabase();

    //await getCheckIntro() == null
      //  ? await db.rawInsert('INSERT INTO settings(checkIntro) VALUES($value)')
      //  : await db.rawUpdate('UPDATE settings SET checkIntro = $value');
    await db.rawUpdate('UPDATE settings SET checkIntro = $value');
  }

  Future<void> updateCheckLogin(String value) async {
    Database db = await getDatabase();

    //await getCheckLogin() == null
        //? await db.rawInsert('INSERT INTO settings(checkLogin) VALUES($value)')
        //: await db.rawUpdate('UPDATE settings SET checkLogin = $value');
    await db.rawUpdate('UPDATE settings SET checkLogin = $value');
  }

  Future<void> updateTheme(String value) async {
    Database db = await getDatabase();

    //await getTheme() == null
      //  ? await db.rawInsert("INSERT INTO settings(theme) VALUES('$value')")
       // : await db.rawUpdate("UPDATE settings SET theme = '$value'");
    await db.rawUpdate("UPDATE settings SET theme = '$value'");
  }

  Future<void> updateIndex(String value) async {
    Database db = await getDatabase();

    await getCheckLogin() == null
        ? await db.rawInsert('INSERT INTO settings(pageIndex) VALUES($value)')
        : await db.rawUpdate('UPDATE settings SET pageIndex = $value');
  }

  Future<String?> getCheckIntro() async {
    Database db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('settings');

    if (maps.isNotEmpty && maps[0].containsKey('checkIntro')) {
      return maps[0]['checkIntro'];
    } else {
      return null;
    }
  }

  Future<String?> getCheckLogin() async {
    Database db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('settings');

    if (maps.isNotEmpty && maps[0].containsKey('checkLogin')) {
      return maps[0]['checkLogin'];
    } else {
      return null;
    }
  }

  Future<String?> getTheme() async {
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
      mobilePhone: maps[0]['mobilePhone'],
      occupation: maps[0]['occupation'],
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
    final db = await getDatabase();

    // Update the given user.
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
    final db = await getDatabase();

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

    await db.rawDelete('DELETE FROM users');
  }
}
