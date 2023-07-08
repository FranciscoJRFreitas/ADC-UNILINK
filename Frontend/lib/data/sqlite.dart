import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:unilink2023/features/chat/domain/Message.dart';

import '../features/news/domain/FeedItem.dart';
import '../features/userManagement/domain/User.dart';

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
            'mobilePhone TEXT, occupation TEXT,token TEXT, password TEXT, creationTime TEXT)');
        await database.execute(
            'CREATE TABLE settings(checkIntro TEXT, checkLogin TEXT,'
            'theme TEXT, `index` TEXT, currentPage TEXT, currentNews TEXT)');
        await database.execute(
            'CREATE TABLE news(pageUrl TEXT, tags TEXT, content TEXT, title TEXT, date TEXT, imageUrl TEXT)');
        await database.execute(
            'CREATE TABLE chat(id TEXT PRIMARY KEY, groupId TEXT, isSystemMessage TEXT, containsFile TEXT, text TEXT,'
            ' name TEXT, displayName TEXT, timestamp INTEGER, extension TEXT)');
        await database.insert('settings', {
          'checkIntro': null,
          'checkLogin': null,
          'theme': null,
          'index': "News",
          'currentPage': "0",
          'currentNews': "0",
        });

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
    await db.transaction((txn) async {
      await txn.insert(
        'users',
        user.toMap(token, password),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> updateCheckIntro(String value) async {
    Database db = await getDatabase();
    await db.transaction((txn) async {
      await txn.rawUpdate('UPDATE settings SET checkIntro = $value');
    });
  }

  Future<void> updateCheckLogin(String value) async {
    Database db = await getDatabase();
    await db.transaction((txn) async {
      await txn.rawUpdate('UPDATE settings SET checkLogin = $value');
    });
  }

  Future<void> updateTheme(String value) async {
    Database db = await getDatabase();
    await db.transaction((txn) async {
      await txn.rawUpdate("UPDATE settings SET theme = '$value'");
    });
  }

  Future<void> updateIndex(String value) async {
    Database db = await getDatabase();
    await db.transaction((txn) async {
      await txn.rawUpdate('UPDATE settings SET `index` = \'$value\'');
    });
  }

  Future<void> updateCurrentPage(String value) async {
    Database db = await getDatabase();
    await db.transaction((txn) async {
      await txn.rawUpdate('UPDATE settings SET currentPage = \'$value\'');
    });
  }

  Future<void> updateCurrentNews(String value) async {
    Database db = await getDatabase();
    await db.transaction((txn) async {
      await txn.rawUpdate('UPDATE settings SET currentNews = \'$value\'');
    });
  }

  Future<String?> getCheckIntro() async {
    Database db = await getDatabase();
    return await db.transaction((txn) async {
      final List<Map<String, dynamic>> maps = await txn.query('settings');

      if (maps.isNotEmpty && maps[0].containsKey('checkIntro')) {
        return maps[0]['checkIntro'];
      } else {
        return null;
      }
    });
  }

  Future<String?> getCheckLogin() async {
    Database db = await getDatabase();
    return await db.transaction((txn) async {
      final List<Map<String, dynamic>> maps = await txn.query('settings');

      if (maps.isNotEmpty && maps[0].containsKey('checkLogin')) {
        return maps[0]['checkLogin'];
      } else {
        return null;
      }
    });
  }

  Future<String?> getTheme() async {
    Database db = await getDatabase();
    return await db.transaction((txn) async {
      final List<Map<String, dynamic>> maps = await txn.query('settings');

      if (maps.isNotEmpty && maps[0].containsKey('theme')) {
        return maps[0]['theme'];
      } else {
        return null;
      }
    });
  }

  Future<String?> getCurrentPage() async {
    Database db = await getDatabase();
    return await db.transaction((txn) async {
      final List<Map<String, dynamic>> maps = await txn.query('settings');

      if (maps.isNotEmpty && maps[0].containsKey('currentPage')) {
        return maps[0]['currentPage'];
      } else {
        return null;
      }
    });
  }

  Future<String?> getCurrentNews() async {
    Database db = await getDatabase();
    return await db.transaction((txn) async {
      final List<Map<String, dynamic>> maps = await txn.query('settings');

      if (maps.isNotEmpty && maps[0].containsKey('currentNews')) {
        return maps[0]['currentNews'];
      } else {
        return null;
      }
    });
  }

  Future<String?> getLastMessage() async {
    Database db = await getDatabase();
    return await db.transaction((txn) async {
      final List<Map<String, dynamic>> maps = await txn.query('settings');

      if (maps.isNotEmpty && maps[0].containsKey('lastMessage')) {
        return maps[0]['lastMessage'];
      } else {
        return null;
      }
    });
  }

  Future<User> getUser() async {
    final db = await getDatabase();
    return await db.transaction((txn) async {
      final List<Map<String, dynamic>> maps = await txn.query('users');
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
        creationTime: maps[0]['creationTime'],
      );
    });
  }

  Future<String> getValue(String table, String value) async {
    Database db = await getDatabase();
    return await db.transaction((txn) async {
      final List<Map<String, dynamic>> maps = await txn.query(table);
      return maps[0][value];
    });
  }

  Future<String> getToken() async {
    Database db = await getDatabase();
    return await db.transaction((txn) async {
      final List<Map<String, dynamic>> maps = await txn.query('users');
      return maps[0]['token'];
    });
  }

  Future<String> getPassword() async {
    Database db = await getDatabase();
    return await db.transaction((txn) async {
      final List<Map<String, dynamic>> maps = await txn.query('users');
      return maps[0]['password'];
    });
  }

  Future<void> updateUser(User user, String token, String password) async {
    final db = await getDatabase();

    await db.transaction((txn) async {
      await txn.update(
        'users',
        user.toMap(token, password),
        where: 'username = ?',
        whereArgs: [user.username],
      );
    });
  }

  Future<void> deleteUser(String username) async {
    // Get a reference to the database.
    final db = await getDatabase();

    await db.transaction((txn) async {
      await txn.delete(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
    });
  }

  Future<void> deleteUsersCache() async {
    // Get a reference to the database
    Database db = await getDatabase();
    await db.transaction((txn) async {
      await txn.rawDelete('DELETE FROM users');
    });
  }

  Future<void> insertNews(FeedItem feedItem) async {
    // Get a reference to the database.
    Database db = await getDatabase();

    await db.transaction((txn) async {
      await txn.insert(
        'news',
        feedItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<List<FeedItem>> getNews() async {
    final db = await getDatabase();

    return await db.transaction((txn) async {
      final List<Map<String, dynamic>> maps = await txn.query('news');

      return List.generate(maps.length, (i) {
        return FeedItem(
          pageUrl: maps[i]['pageUrl'],
          tags: maps[i]['tags'] != null
              ? Set<String>.from(maps[i]['tags'].split(','))
              : null,
          content: maps[i]['content'],
          title: maps[i]['title'],
          date: maps[i]['date'],
          imageUrl: maps[i]['imageUrl'],
        );
      });
    });
  }

  Future<void> deleteNewsCache() async {
    Database db = await getDatabase();
    await db.transaction((txn) async {
      await txn.rawDelete('DELETE currentPage FROM settings');
      await txn.rawDelete('DELETE currentNews FROM settings');
      await txn.rawDelete('DELETE FROM news');
    });
  }

  Future<List<Message>> getMessages(String groupId) async {
    final db = await getDatabase();

    return await db.transaction((txn) async {
      final List<Map<String, dynamic>> maps = await txn.query('chat');

      List<Map<String, dynamic>> filteredMaps =
          maps.where((element) => element['groupId'] == groupId).toList();

      return filteredMaps.map((map) {
        return Message(
          isSystemMessage: map['isSystemMessage'] == '1' ? true : false,
          containsFile: map['containsFile'] == '1' ? true : false,
          id: map['id'],
          text: map['text'],
          name: map['name'],
          displayName: map['displayName'],
          timestamp: map['timestamp'],
          extension: map['extension'],
        );
      }).toList();
    });
  }

  Future<void> insertMessage(String groupId, Message message) async {
    // Get a reference to the database.
    Database db = await getDatabase();
    Map<String, dynamic> msg = message.toMap();

    msg.addAll({'groupId': groupId});
    await db.transaction((txn) async {
      await txn.insert(
        'chat',
        msg,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> updateMessage(Message message) async {
    // Get a reference to the database.
    final db = await getDatabase();

    // Update the given Message.
    await db.update(
      'chat',
      message.toMap(),
      // Ensure that the Message has a matching id.
      where: "id = ?",
      whereArgs: [message.id],
    );
  }

  Future<void> deleteMessage(String id) async {
    // Get a reference to the database.
    final db = await getDatabase();

    // Remove the Message from the Database.
    await db.delete(
      'chat',
      // Use a where clause to delete a specific message.
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteMessagesInCache() async {
    Database db = await getDatabase();
    await db.transaction((txn) async {
      await txn.rawDelete('DELETE FROM chat');
    });
  }
}
