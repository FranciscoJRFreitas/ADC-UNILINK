import 'package:firebase_database/firebase_database.dart';

class Message {
  final bool containsFile;
  final String? extension;
  final String id;
  final String text;
  final String name;
  final int timestamp;

  Message({
    required this.id,
    required this.containsFile,
    required this.text,
    required this.name,
    required this.timestamp,
    this.extension,
  });

  factory Message.fromSnapshot(DataSnapshot snapshot) {
    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    bool files = data["containsFile"] as bool;
    return files
        ? Message(
            id: snapshot.key!,
            extension: data['extension'] as String,
            text: data['message'] as String,
            name: data['name'] as String,
            timestamp: data['timestamp'] as int,
            containsFile: data['containsFile'] as bool,
          )
        : Message(
            id: snapshot.key!,
            text: data['message'] as String,
            name: data['name'] as String,
            timestamp: data['timestamp'] as int,
            containsFile: data['containsFile'] as bool,
          );
  }
}
