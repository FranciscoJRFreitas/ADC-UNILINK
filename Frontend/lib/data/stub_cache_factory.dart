import 'package:unilink2023/features/chat/domain/Message.dart';
import 'package:unilink2023/features/news/domain/FeedItem.dart';
import 'package:unilink2023/features/userManagement/domain/User.dart';

import 'cache_factory.dart';

class CacheFactoryImpl extends CacheFactory{
  @override
  void delete(String value) {
  }

  @override
  Future? get(String table, String value) {
    throw UnimplementedError();
  }

  @override
  void printDb() {
  }

  @override
  void removeLoginCache() {
  }

  @override
  void set(String property, value) {
  }

  @override
  void initDB() async {
  }

  @override
  void setUser(User user, String token, String password) {
  }
  
  @override
  void removeNewsCache() {
  }
  
  @override
  void setNews(FeedItem feedItem) {
  }

  @override
  void removeMessagesCache() {
  }

  @override
  void setMessages(Message message) {
    // TODO: implement setMessages
  }

  @override
  void deleteMessage(String id) {
    // TODO: implement deleteMessage
  }

  @override
  void updateMessageCache(Message message) {
    // TODO: implement updateMessageCache
  }

}