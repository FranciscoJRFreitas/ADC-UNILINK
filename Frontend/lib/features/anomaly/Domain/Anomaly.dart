import 'package:firebase_database/firebase_database.dart';

class Anomaly {
  final String anomalyId;
  final String sender;
  final String title;
  final String description;
  final String coordinates;
  String status;
  final int timestamp;

  Anomaly({
    required this.anomalyId,
    required this.sender,
    required this.title,
    required this.description,
    required this.coordinates,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'anomalyId': anomalyId,
      'sender': sender,
      'title': title,
      'description': description,
      'location': coordinates,
      'status': status,
      'timestamp': timestamp,
    };
  }

  static Anomaly fromMap(Map<String, dynamic> map) {
    return Anomaly(
      anomalyId: map['anomalyId'],
      sender: map['sender'],
      title: map['title'],
      description: map['description'],
      coordinates: map['location'],
      status: map['status'],
      timestamp: map['timestamp'],
    );
  }

  factory Anomaly.fromSnapshot(DataSnapshot snapshot) {
    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    return Anomaly(
      anomalyId: snapshot.key!,
      timestamp: data['timestamp'] as int,
      sender: data['sender'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      coordinates: data['location'] as String,
      status: data['status'] as String,
    );
  }

  factory Anomaly.fromMapKey(var key, Map<dynamic, dynamic> data) {
    return Anomaly(
      anomalyId: key,
      timestamp: data['timestamp'] as int,
      sender: data['sender'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      coordinates: data['location'] as String,
      status: data['status'] as String,
    );
  }
}
