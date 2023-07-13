import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:unilink2023/features/calendar/application/event_utils.dart';
import 'package:unilink2023/features/calendar/domain/Event.dart';
import 'package:unilink2023/widgets/LineDateTimeField.dart';
import 'package:unilink2023/widgets/LocationPopUp.dart';
import '../../../../constants.dart';
import '../../../../widgets/LineComboBox.dart';
import '../../../../widgets/widget.dart';
import '../../../../widgets/LineTextField.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;

  EventDetailsPage({required this.event});

  @override
  _EventDetailsPage createState() => _EventDetailsPage();
}

class _EventDetailsPage extends State<EventDetailsPage> {
  late Event event;
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
    _selectedTypeController = getEventTypeString(event.type);
    _selectedLocation = null;
    selectLocationText =
        event.location == null ? "Select Location" : "1 Location Selected";
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

  Future<void> modifyAttributes(
    Event ev,
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
                    Text(
                      "Change Event Details",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Divider(
                      thickness: 2,
                      color: Style.lightBlue,
                    ),
                    SizedBox(height: 15),
                    LineComboBox(
                      selectedValue: _selectedTypeController,
                      items: EventType.values
                          .map((e) => getEventTypeString(e))
                          .toList(),
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
                      items: [
                        selectLocationText,
                        "From FCT place",
                        "From maps"
                      ],
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
                          DateFormat dateFormat =
                              DateFormat('yyyy-MM-dd HH:mm');
                          bool isNull = _selectedLocation == null;
                          Event ev = Event(
                              id: event.id,
                              creator: event.creator,
                              type: parseEventType(_selectedTypeController),
                              title: titleController.text,
                              description: descriptionController.text,
                              startTime: dateFormat.parse(startController.text),
                              endTime: dateFormat.parse(endController.text),
                              location: !isNull
                                  ? "${_selectedLocation!.latitude},${_selectedLocation!.longitude}"
                                  : '0');
                          modifyAttributes(
                            ev,
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

}
