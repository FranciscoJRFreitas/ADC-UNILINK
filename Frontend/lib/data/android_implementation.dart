import 'package:unilink2023/data/sqlite.dart';
import 'package:unilink2023/features/chat/domain/Group.dart';
import 'package:unilink2023/features/chat/domain/Message.dart';
import 'package:unilink2023/features/userManagement/domain/User.dart';

import '../features/news/domain/FeedItem.dart';
import 'cache_factory.dart';

class CacheFactoryImpl implements CacheFactory {
  CacheFactoryImpl._();

  // Singleton instance
  static final CacheFactoryImpl _instance = CacheFactoryImpl._();

  // Factory method to get the singleton instance
  factory CacheFactoryImpl() {
    return _instance;
  }

  @override
  void initDB() {
    SqliteService().initializeDB();
  }

  @override
  void set(String property, dynamic value) async {
    if (property == 'checkIntro')
      await SqliteService().updateCheckIntro(value);
    else if (property == 'checkLogin')
      await SqliteService().updateCheckLogin(value);
    else if (property == 'index')
      await SqliteService().updateIndex(value);
    else if (property == 'theme')
      await SqliteService().updateTheme(value);
    else if (property == 'currentPage')
      await SqliteService().updateCurrentPage(value);
    else if (property == 'currentNews')
      await SqliteService().updateCurrentNews(value);
  }

  @override
  Future<dynamic> get(String table, String value) async {
    if (value == 'db')
      return await SqliteService().getDatabase();
    else if (value == 'checkIntro')
      return await SqliteService().getCheckIntro();
    else if (value == 'checkLogin')
      return await SqliteService().getCheckLogin();
    else if (value == 'currentPage')
      return await SqliteService().getCurrentPage();
    else if (value == 'currentNews')
      return await SqliteService().getCurrentNews();
    else if (value == 'password')
      return await SqliteService().getPassword();
    else if (value == 'theme')
      return await SqliteService().getTheme();
    else if (value == 'token')
      return await SqliteService().getToken();
    else if (value == 'user')
      return await SqliteService().getUser();
    else if (value == 'lastMessage')
      return await SqliteService().getLastMessage();
    else if (table == 'news')
      return await SqliteService().getNews();
    else if (table == 'chat')
      return await SqliteService().getMessages(value);
    else if (table == 'groups')
      return await SqliteService().getGroups();
    else
      return await SqliteService().getValue(table, value);
  }

  @override
  void delete(String value) async {
    if (value.isNotEmpty)
      await SqliteService().deleteUser(value);
    else
      await SqliteService().deleteUsersCache();
  }

  @override
  void removeLoginCache() {
    SqliteService().deleteUsersCache();
    SqliteService().updateCheckLogin('false');
  }

  @override
  void printDb() async {
    var db = await SqliteService().getDatabase();
    var result = await db.query('users');
    print("\nusers: \n");
    for (var row in result) {
      print(row);
    }
    print("\nsettings: \n");
    result = await db.query('settings');
    for (var row in result) {
      print(row);
    }
    result = await db.query('chat');
    print("\nchat: \n");
    for (var row in result) {
      print(row);
    }
  }

  @override
  void setUser(User user, String token, String password) {
    SqliteService().insertUser(user, token, password);
  }

  @override
  void removeNewsCache() {
    SqliteService().deleteNewsCache();
  }

  @override
  void setNews(FeedItem feedItem) async {
    List<FeedItem> newsList = await SqliteService().getNews();
    bool isPresent = newsList.any((item) => item.title == feedItem.title);
    if (!isPresent) {
      SqliteService().insertNews(feedItem);
    }
  }

  @override
  void removeMessagesCache() {
    SqliteService().deleteMessagesInCache();
  }

  @override
  void setMessages(String groupId, Message message) async {
    List<Message> messageList = await SqliteService().getMessages(groupId);
    bool isPresent = messageList.any((item) => item.id == message.id);
    if (!isPresent) {
      SqliteService().insertMessage(groupId, message);
    }
  }

  @override
  void deleteMessage(String groupId, String id) {
    if (id == '-1') SqliteService().deleteMessage(groupId);
    SqliteService().deleteMessage(id);
  }

  @override
  void updateMessageCache(String groupId, Message message) {
    SqliteService().updateMessage(message);
  }

  @override
  Future<List<Message>> getMessages(String groupId) async {
    return await SqliteService().getMessages(groupId);
  }

  @override
  Future<List<Group>> getGroups() async {
    return await SqliteService().getGroups();
  }

  @override
  void addGroup(Group group) {
    SqliteService().addGroup(group);
  }

  @override
  void removeGroup(String groupId) {
    SqliteService().removeGroup(groupId);
  }

  @override
  void removeGroupsCache() {
    SqliteService().removeGroupsCache();
  }
}
