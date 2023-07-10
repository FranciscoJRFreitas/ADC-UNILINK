import 'package:firebase_database/firebase_database.dart';

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
      type: _parseEventType(data['type'] as String),
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
      type: _parseEventType(data['type'] as String),
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
      id:data['id'] as String,
      creator: data['creator'] as String,
      type: _parseEventType(data['type'] as String),
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
      'type': _getEventTypeString(type),
      'title': title,
      'description': description,
      'startTime': startTime.toString(),
      'endTime': endTime.toString(),
      'location': location,
    };
  }

  static EventType _parseEventType(String? eventTypeString) {
    if (eventTypeString != null) {
      eventTypeString = eventTypeString.toLowerCase();

      switch (eventTypeString) {
        case 'academic':
          return EventType.academic;
        case 'entertainment':
          return EventType.entertainment;
        case 'faire':
          return EventType.faire;
        case 'athletics':
          return EventType.athletics;
        case 'competition':
          return EventType.competition;
        case 'party':
          return EventType.party;
        case 'ceremony':
          return EventType.ceremony;
        case 'conference':
          return EventType.conference;
        case 'lecture':
          return EventType.lecture;
        case 'meeting':
          return EventType.meeting;
        case 'workshop':
          return EventType.workshop;
        case 'exhibit':
          return EventType.exhibit;
      }
    }

    return EventType.academic;
  }


  static String _getEventTypeString(EventType eventType) {
    switch (eventType) {
      case EventType.academic:
        return 'Academic';
      case EventType.entertainment:
        return 'Entertainment';
      case EventType.faire:
        return 'Faire';
      case EventType.athletics:
        return 'Athletics';
      case EventType.competition:
        return 'Competition';
      case EventType.party:
        return 'Party';
      case EventType.ceremony:
        return 'Ceremony';
      case EventType.conference:
        return 'Conference';
      case EventType.lecture:
        return 'Lecture';
      case EventType.meeting:
        return 'Meeting';
      case EventType.workshop:
        return 'Workshop';
      case EventType.exhibit:
        return 'Exhibit';
    }
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
