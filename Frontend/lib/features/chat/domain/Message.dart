import 'package:firebase_database/firebase_database.dart';

class Message {
  final bool containsFile;
  final bool isSystemMessage;
  final String? extension;
  final String id;
  final String text;
  final String name;
  final String displayName;
  final int timestamp;

  Message({
    required this.isSystemMessage,
    required this.id,
    required this.containsFile,
    required this.text,
    required this.name,
    required this.displayName,
    required this.timestamp,
    this.extension,
  });

  Map<String, dynamic> toMap() {
    return {
      'isSystemMessage': isSystemMessage,
      'id': id,
      'containsFile': containsFile,
      'text': text,
      'name': name,
      'displayName': displayName,
      'timestamp': timestamp,
      'extension' : extension,
    };
  }

  static Message fromMap(Map<String, dynamic> map) {
    return Message(
      isSystemMessage: map['isSystemMessage'],
      id: map['id'],
      containsFile: map['containsFile'],
      text: map['text'],
      name: map['name'],
      displayName: map['displayName'],
      timestamp: map['timestamp'],
      extension: map['extension'],
    );
  }

  factory Message.fromSnapshot(DataSnapshot snapshot) {
    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    bool files = data["containsFile"] as bool;
    return files
        ? Message(
            id: snapshot.key!,
            extension: data['extension'] as String,
            text: data['message'] as String,
            name: data['name'] as String,
            displayName: data['displayName'] as String,
            timestamp: data['timestamp'] as int,
            containsFile: data['containsFile'] as bool,
            isSystemMessage: data['isSystemMessage'] as bool,
          )
        : Message(
            id: snapshot.key!,
            text: data['message'] as String,
            name: data['name'] as String,
            displayName: data['displayName'] as String,
            timestamp: data['timestamp'] as int,
            containsFile: data['containsFile'] as bool,
            isSystemMessage: data['isSystemMessage'] as bool,
          );
  }

  factory Message.fromMapKey(var key, Map<dynamic, dynamic> data) {
    bool files = data["containsFile"] as bool;
    return files
        ? Message(
            id: key,
            extension: data['extension'] as String,
            text: data['message'] as String,
            name: data['name'] as String,
            displayName: data['displayName'] as String,
            timestamp: data['timestamp'] as int,
            containsFile: data['containsFile'] as bool,
            isSystemMessage: data['isSystemMessage'] as bool,
          )
        : Message(
            id: key,
            text: data['message'] as String,
            name: data['name'] as String,
            displayName: data['displayName'] as String,
            timestamp: data['timestamp'] as int,
            containsFile: data['containsFile'] as bool,
            isSystemMessage: data['isSystemMessage'] as bool,
          );
  }
}
