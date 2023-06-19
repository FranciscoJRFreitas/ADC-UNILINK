import 'package:firebase_database/firebase_database.dart';

class Message {
  final String id;
  final String text;
  final String name;
  final int timestamp;

  Message({
    required this.id,
    required this.text,
    required this.name,
    required this.timestamp,
  });

  factory Message.fromSnapshot(DataSnapshot snapshot) {
    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    return Message(
      id: snapshot.key!,
      text: data['message'] as String,
      name: data['name'] as String,
      timestamp: data['timestamp'] as int,
    );
  }
}