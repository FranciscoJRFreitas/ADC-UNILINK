import 'package:unilink2023/features/calendar/domain/Event.dart';

EventType parseEventType(String? eventTypeString) {
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

String getEventTypeString(EventType eventType) {
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
