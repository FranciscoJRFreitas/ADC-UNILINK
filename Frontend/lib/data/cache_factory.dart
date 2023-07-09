import 'package:unilink2023/features/chat/domain/Message.dart';

import '../features/chat/domain/Group.dart';
import '../features/news/domain/FeedItem.dart';
import '../features/userManagement/domain/User.dart';

abstract class CacheFactory {
  void set(String property, dynamic value);
  Future<dynamic>? get(String table, String value);
  void delete(String value);
  void removeLoginCache();
  void initDB();
  void setUser(User user, String token, String password);
  void removeNewsCache();
  void printDb();
  void setNews(FeedItem feedItem);
  void removeMessagesCache();
  void updateMessageCache(String groupId, Message message);
  void deleteMessage(String groupId, String id);
  void setMessages(String groupId, Message message);
  Future<List<Message>> getMessages(String groupId);
  Future<List<Group>> getGroups();
  void addGroup(Group group);
  void removeGroup(String groupId);
  void removeGroupsCache();
}
