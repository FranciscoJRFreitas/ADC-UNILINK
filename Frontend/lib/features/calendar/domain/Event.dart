import 'package:firebase_database/firebase_database.dart';
import 'package:unilink2023/features/calendar/application/event_utils.dart';

class Event {
  final String? id;
  final String? groupId;
  final EventType type;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String? creator;
  final String? location;

  Event({
    this.id,
    this.creator,
    this.groupId,
    required this.type,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.location,
  });

  // If you are storing your events as JSON, these may be useful
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      creator: json['creator'] ?? '',
      type: json['type'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      location: json['location'] ?? '',
    );
  }

  factory Event.fromSnapshotId(String id, DataSnapshot snapshot) {
    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    return Event(
      id: id,
      creator: data['creator'] as String,
      type: parseEventType(data['type'] as String),
      title: data['title'] as String,
      description: data['description'] as String,
      startTime: DateTime.parse(data['startTime']),
      endTime: DateTime.parse(data['endTime']),
      location: data['location'] as String,
    );
  }

  factory Event.fromSnapshotGroupId(String id, DataSnapshot snapshot) {
    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    return Event(
      groupId: id,
      creator: data['creator'] as String,
      type: parseEventType(data['type'] as String),
      title: data['title'] as String,
      description: data['description'] as String,
      startTime: DateTime.parse(data['startTime']),
      endTime: DateTime.parse(data['endTime']),
      location: data['location'] as String,
    );
  }

  factory Event.fromSnapshot(DataSnapshot snapshot) {
    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    return Event(
      id: data['id'] as String,
      creator: data['creator'] as String,
      type: parseEventType(data['type'] as String),
      title: data['title'] as String,
      description: data['description'] as String,
      startTime: DateTime.parse(data['startTime']),
      endTime: DateTime.parse(data['endTime']),
      location: data['location'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator': creator,
      'type': getEventTypeString(type),
      'title': title,
      'description': description,
      'startTime': startTime.toString(),
      'endTime': endTime.toString(),
      'location': location,
    };
  }
}

enum EventType {
  academic,
  entertainment,
  faire,
  athletics,
  competition,
  party,
  ceremony,
  conference,
  lecture,
  meeting,
  workshop,
  exhibit
}
