import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:unilink2023/features/calendar/domain/Event.dart';
import 'package:unilink2023/widgets/LineDateTimeField.dart';
import 'package:unilink2023/widgets/LocationPopUp.dart';
import '../../../../constants.dart';
import '../../../../data/cache_factory_provider.dart';
import '../../../../domain/UserNotifier.dart';
import '../../../../domain/Token.dart';
import '../../../../widgets/LineComboBox.dart';
import '../../../../widgets/LineDateField.dart';
import '../../../../widgets/ToggleButton.dart';
import '../../../../widgets/widget.dart';
import '../../../../widgets/LineTextField.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventDetailsPage extends StatefulWidget {
  final Event event;

  EventDetailsPage({required this.event});

  @override
  _EventDetailsPage createState() => _EventDetailsPage();
}

class _EventDetailsPage extends State<EventDetailsPage> {
  late Event event;

  //final TextEditingController passwordController = TextEditingController();
  late TextEditingController titleController;
  late String _selectedTypeController;
  late TextEditingController descriptionController;
  late TextEditingController startController = TextEditingController();
  late TextEditingController endController = TextEditingController();
  late LatLng? _selectedLocation;
  late String selectLocationText;

  @override
  void initState() {
    super.initState();
    event = widget.event;
    initialize();
  }

  void initialize() {
    titleController = TextEditingController(text: event.title);
    descriptionController = TextEditingController(text: event.description);
    startController = TextEditingController(text: event.startTime.toString());
    endController = TextEditingController(text: event.endTime.toString());
    _selectedTypeController = _getEventTypeString(event.type);
    _selectedLocation = null;
    selectLocationText = event.location == null ? "Select Location" : "1 Location Selected";
  }

  // Function to display the snackbar
  void _showErrorSnackbar(String message, bool Error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Error ? Colors.red : Colors.blue.shade900,
      ),
    );
  }

  Future<void> modifyAttributes(Event ev,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    DatabaseReference eventsRef = FirebaseDatabase.instance
        .ref()
        .child('schedule')
        .child(event.creator!)
        .child(ev.id!);


    // Add the event to the database
    eventsRef.set(ev.toJson()).then((_) {
      titleController.clear();
      descriptionController.clear();
      startController.clear();
      endController.clear();
      _selectedLocation = null;
      _showErrorSnackbar('Personal event added successfully!', false);
    }).catchError((error) {
      _showErrorSnackbar(
          'There was an error while adding this personal event!', true);
    });
  }

  @override
  Widget build(BuildContext context) {
    double offset = MediaQuery.of(context).size.width * 0.08;
    return Dialog(
      insetPadding: EdgeInsets.fromLTRB(offset, 80, offset, 50),
      backgroundColor: Theme.of(context).canvasColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 750, // Set the maximum width for the Dialog
              ),
              child: Padding(
                padding: EdgeInsets.only(
                    top: 20), // Provide space for the image at the top
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    Divider(
                      thickness: 2,
                      color: Style.lightBlue,
                    ),
                    SizedBox(height: 15),
                    LineComboBox(
                      selectedValue: _selectedTypeController,
                      items:
                      EventType.values.map((e) => _getEventTypeString(e)).toList(),
                      icon: Icons.type_specimen,
                      onChanged: (dynamic newValue) {
                        setState(() {
                          _selectedTypeController = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LineTextField(
                        icon: Icons.title,
                        lableText: 'Title *',
                        controller: titleController,
                        title: "",
                      ),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LineTextField(
                        icon: Icons.description,
                        lableText: "Description",
                        controller: descriptionController,
                        title: "",
                      ),
                    ),
                    SizedBox(height: 5),
                    LineComboBox(
                      deleteIcon: Icons.clear,
                      onPressed: () {
                        setState(() {
                          selectLocationText = "Select Location";
                          _selectedLocation = null;
                        });
                      },
                      selectedValue: selectLocationText,
                      items: [selectLocationText, "From FCT place", "From maps"],
                      icon: Icons.place,
                      onChanged: (newValue) async {
                        if (newValue == "From FCT place" ||
                            newValue == "From maps") {
                          LatLng? selectedLocation = await showDialog<LatLng>(
                            context: context,
                            builder: (context) => EventLocationPopUp(
                              context: context,
                              isMapSelected: newValue == "From maps",
                              location: _selectedLocation,
                            ),
                          );
                          if (selectedLocation != null) {
                            setState(() {
                              selectLocationText = "1 Location Selected";
                              _selectedLocation = selectedLocation;
                            });
                          }
                        }
                      },
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LineDateTimeField(
                        icon: Icons.schedule,
                        controller: startController,
                        hintText: "Start Time *",
                        firstDate: DateTime.now().subtract(Duration(days: 30)),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LineDateTimeField(
                        icon: Icons.schedule,
                        controller: endController,
                        hintText: "End Time *",
                        firstDate: DateTime.now().subtract(Duration(days: 30)),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.fromLTRB(offset, 20, offset, 0),
                      child: MyTextButton(
                        alignment: Alignment.center,
                        buttonName: 'Save Changes',
                        onTap: () async {
                          DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
                          bool isNull = _selectedLocation == null;
                          Event ev = Event(
                              id: event.id,
                              creator: event.creator,
                              type: _parseEventType(_selectedTypeController),
                              title: titleController.text,
                              description: descriptionController.text,
                              startTime: dateFormat.parse(startController.text),
                              endTime: dateFormat.parse(endController.text),
                              location: !isNull
                                  ? "${_selectedLocation!.latitude},${_selectedLocation!.longitude}"
                                  : '0');
                          modifyAttributes(ev,
                            _showErrorSnackbar,
                          );
                          Navigator.of(context).pop();
                        },
                        bgColor: Theme.of(context).dividerColor,
                        textColor: Colors.white,
                        height: 45,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 1,
            right: 1,
            child: IconButton(
              hoverColor:
                  Theme.of(context).secondaryHeaderColor.withOpacity(0.6),
              splashRadius: 20.0,
              icon: Container(
                height: 25,
                width: 25,
                child: Icon(
                  Icons.close,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  EventType _parseEventType(String? eventTypeString) {
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
