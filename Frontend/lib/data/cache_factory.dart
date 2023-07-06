import 'package:unilink2023/features/chat/domain/Message.dart';

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
  void updateMessageCache(Message message);
  void deleteMessage(String id);
  void setMessages(Message message);
}
