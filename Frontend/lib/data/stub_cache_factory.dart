import 'package:unilink2023/features/chat/domain/Group.dart';
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
  void setMessages(String groupId, Message message) {
  }

  @override
  void deleteMessage(String groupId, String id) {
  }

  @override
  void updateMessageCache(String groupId, Message message) {
  }
  
  @override
  Future<List<Message>> getMessages(String groupId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Group>> getGroups() {
    throw UnimplementedError();
  }

  @override
  void addGroup(Group group) {
  }

  @override
  void removeGroup(String groupId) {
  }

  @override
  void removeGroupsCache() {
  }

}