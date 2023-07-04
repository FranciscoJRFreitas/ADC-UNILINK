import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:unilink2023/features/calendar/domain/Event.dart';
import 'package:unilink2023/features/chat/presentation/chat_member_info.dart';
import 'package:unilink2023/features/navigation/main_screen_page.dart';
import 'package:unilink2023/widgets/LineComboBox.dart';
import 'package:unilink2023/widgets/LineDateField.dart';
import 'package:unilink2023/widgets/LineTextField.dart';
import 'package:unilink2023/widgets/my_date_event_field.dart';
import 'package:unilink2023/widgets/my_text_field.dart';
import '../../../constants.dart';
import 'package:http/http.dart' as http;

import '../../../data/cache_factory_provider.dart';
import '../../../domain/Token.dart';
import '../../../widgets/LineDateTimeField.dart';

class ChatInfoPage extends StatefulWidget {
  final String groupId;
  final String username;

  ChatInfoPage({required this.groupId, required this.username});

  @override
  State<ChatInfoPage> createState() => _ChatInfoPageState();
}

class _ChatInfoPageState extends State<ChatInfoPage> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  late Future<Uint8List?> groupPic;
  late List<MembersData> members = [];
  late List<Event> events = [];
  late DatabaseReference membersRef;
  late DatabaseReference chatsRef;
  late String desc = "";
  late bool isAdmin = false;
  late MembersData? memberData;
  List<EventType> eventTypes = EventType.values;
  String _selectedEventType = 'Academic';

  @override
  void initState() {
    super.initState();
    groupPic = downloadGroupPictureData();
    membersRef =
        FirebaseDatabase.instance.ref().child('members').child(widget.groupId);
    membersRef.onChildAdded.listen((event) async {
      String memberId = event.snapshot.key as String;

      if (memberId == widget.username && event.snapshot.value as bool) {
        setState(() {
          isAdmin = true;
        });
      }
      DatabaseReference chatRef =
          FirebaseDatabase.instance.ref().child('chat').child(memberId);

      chatRef.once().then((userDataSnapshot) {
        if (userDataSnapshot.snapshot.value != null) {
          dynamic userData = userDataSnapshot.snapshot.value;
          String? dispName = userData['DisplayName'] as String?;

          setState(() {
            if (dispName != null) {
              members.add(MembersData(
                  username: memberId,
                  dispName: dispName,
                  isAdmin: event.snapshot.value as bool));
            }
          });
        }
      });
    });
    membersRef.onChildRemoved.listen((event) {
      String memberId = event.snapshot.key as String;

      setState(() {
        members.removeWhere((member) => member.username == memberId);
      });
    });

// Listen for child changed events
    membersRef.onChildChanged.listen((event) {
      String memberId = event.snapshot.key as String;

      setState(() {
        // Find the member in the list and update its isAdmin value
        int index = members.indexWhere((member) => member.username == memberId);
        if (index != -1) {
          members[index].isAdmin = event.snapshot.value as bool;
        }
      });
    });

    chatsRef =
        FirebaseDatabase.instance.ref().child('groups').child(widget.groupId);
    chatsRef.once().then((chatSnapshot) {
      Map<dynamic, dynamic> chatsData =
          chatSnapshot.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        desc = chatsData["description"];
      });
    });

    DatabaseReference eventsRef =
        FirebaseDatabase.instance.ref().child('events').child(widget.groupId);
    eventsRef.onChildAdded.listen((event) {
      setState(() {
        String? id = event.snapshot.key; // Here is how you get the key
        Event currentEvent = id != null
            ? Event.fromSnapshotId(id, event.snapshot)
            : Event.fromSnapshot(event.snapshot);
        events.add(currentEvent);
      });
    });

    eventsRef.onChildRemoved.listen((event) {
      String eventId = event.snapshot.key as String;

      setState(() {
        events.removeWhere((event) => event.id == eventId);
      });
    });
  }

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

  void dispose() {
    super.dispose();
  }

  Future<Uint8List?> downloadGroupPictureData() async {
    return FirebaseStorage.instance
        .ref('GroupPictures/' + widget.groupId)
        .getData()
        .onError((error, stackTrace) => null);
  }

  Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();

    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    final fileBytes = await pickedFile!.readAsBytes();

    Reference storageReference =
        FirebaseStorage.instance.ref().child('GroupPictures/' + widget.groupId);

    await storageReference.putData(fileBytes);
    setState(() {});
  }

  Widget groupPicture(BuildContext context) {
    return FutureBuilder<Uint8List?>(
        future: groupPic,
        builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
          if (snapshot.hasData) {
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    // Here
                    return Dialog(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          PhotoView(
                            imageProvider: MemoryImage(snapshot.data!),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  // use circle if the icon is circular
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 15.0,
                                      spreadRadius: 2.0,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ), // Choose your icon and color
                              onPressed: () {
                                Navigator.of(dialogContext)
                                    .pop(); // Use dialogContext here
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                width: 100.0, // Set your desired width
                height: 100.0, // and height
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: MemoryImage(snapshot.data!),
                  ),
                ),
              ),
            );
          } else {
            return const Icon(
              Icons.group,
              size: 80,
            );
          }
        });
  }

  Widget profilePicture(BuildContext context) {
    return InkWell(
      onTap: () {
        //edit image link click as per your need.
      },
      child: Stack(
        children: <Widget>[
          Container(
            width: 80,
            height: 80,
            child: CircleAvatar(
              backgroundColor: Colors.white70,
              radius: 20,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(200),
                  child: groupPicture(context)),
            ),
          ),
          if (isAdmin)
            Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  height: 27.5,
                  width: 27.5,
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: InkWell(
                    onTap: () async {
                      await getImage(true);
                      groupPic = downloadGroupPictureData();
                      setState(() {});
                    },
                    child: Icon(
                      Icons.add_a_photo,
                      size: 22.765165125,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? Scaffold(
            body: _showXButton(),
          )
        : Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: kWhiteBackgroundColor,
              ),
              centerTitle: true,
              elevation: 0,
              title: Text(
                "Group Information",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              backgroundColor: Theme.of(context).primaryColor,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.exit_to_app_rounded),
                  tooltip: 'Leave Group',
                  onPressed: () {
                    leavePopUpDialog(context);
                  },
                ),
              ],
            ),
            body: _showXButton());
  }

  Widget _showXButton() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Row(
            children: [
              profilePicture(context),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.groupId,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Divider(
            thickness: 1,
            color: Style.lightBlue,
          ),
          SizedBox(height: 10),
          Text(
            desc,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 5),
          Divider(
            thickness: 1,
            color: Style.lightBlue,
          ),
          SizedBox(height: 5),
          if (isAdmin) ...[
            Padding(
              padding: EdgeInsets.only(left: 15.0),
              child: TextButton.icon(
                icon: Icon(
                  Icons.event,
                  color: Theme.of(context).secondaryHeaderColor,
                  size: 20,
                ),
                label: Text('Add event',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.white)),
                onPressed: () {
                  _createEventPopUpDialog(context);
                },
                style: TextButton.styleFrom(
                  minimumSize: Size(50, 50),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 80),
              child: SizedBox(
                height: 250,
                child: ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      Event event = events[index];
                      return Material(
                        color: Colors.transparent,
                        child: GestureDetector(
                          onTap: () {
                            // if (widget.username != member.username) {
                            //   Navigator.of(context).push(
                            //     MaterialPageRoute(
                            //       builder: (context) => ChatMemberInfo(
                            //         isAdmin: isAdmin,
                            //         sessionUsername: widget.username,
                            //         groupId: widget.groupId,
                            //         member: member,
                            //       ),
                            //     ),
                            //   );
                            // }
                          },
                          child: Stack(
                            children: <Widget>[
                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 5,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 8),
                                  child: ListTile(
                                    title: Text(
                                      event.title +
                                          " (${_getEventTypeString(event.type)} Event)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.description, size: 20),
                                            SizedBox(width: 5),
                                            Text(event.description),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        if (event.location != null) ...[
                                          Row(
                                            children: [
                                              Icon(Icons.place, size: 20),
                                              SizedBox(width: 5),
                                              Text('Location: ' +
                                                  event.location!),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                        ],
                                        Row(
                                          children: [
                                            Icon(Icons.schedule, size: 20),
                                            SizedBox(width: 5),
                                            Text(
                                                "Start: ${DateFormat('yyyy-MM-dd HH:mm').format(event.startTime)}"),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.schedule, size: 20),
                                            SizedBox(width: 5),
                                            Text(
                                                "End: ${DateFormat('yyyy-MM-dd HH:mm').format(event.endTime)}"),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (isAdmin)
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  right: 20,
                                  child: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _removeEventPopUpDialog(
                                          context, event.id!);
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ),
            SizedBox(height: 5),
            Divider(
              thickness: 1,
              color: Style.lightBlue,
            ),
          ],
          SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${members.length} Participants',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (isAdmin)
                Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: TextButton.icon(
                    icon: Icon(
                      Icons.add_box_rounded,
                      color: Theme.of(context).secondaryHeaderColor,
                      size: 20,
                    ),
                    label: Text('Add more',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.white)),
                    onPressed: () {
                      popUpDialog(context);
                    },
                    style: TextButton.styleFrom(
                      minimumSize: Size(50, 50),
                    ),
                  ),
                ),
              if (kIsWeb)
                Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: TextButton.icon(
                    icon: Icon(
                      Icons.exit_to_app_rounded,
                      color: Theme.of(context).secondaryHeaderColor,
                      size: 20,
                    ),
                    label: Text('Leave group',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.white)),
                    onPressed: () {
                      leavePopUpDialog(context);
                    },
                    style: TextButton.styleFrom(
                      minimumSize: Size(50, 50),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 80),
            child: SizedBox(
              height: 1000,
              child: ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    MembersData member = members[index];
                    return Material(
                      color: Colors.transparent,
                      child: GestureDetector(
                        onTap: () {
                          if (widget.username != member.username) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ChatMemberInfo(
                                  isAdmin: isAdmin,
                                  sessionUsername: widget.username,
                                  groupId: widget.groupId,
                                  member: member,
                                ),
                              ),
                            );
                          }
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 8),
                            child: ListTile(
                              leading:
                                  profilePicture2(context, member.username),
                              title: Text(
                                '${member.dispName}${member.username == widget.username ? ' (You)' : ''}${member.isAdmin ? ' (Admin)' : ''}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.alternate_email, size: 20),
                                      SizedBox(width: 5),
                                      Text('Username: ${member.username}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          )
        ],
      ),
    );
  }

  popUpDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                "Send an Invite",
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    style: Theme.of(context).textTheme.bodyLarge,
                    controller: userNameController,
                    decoration: InputDecoration(
                      hintText: "Enter a valid username",
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Colors.grey),
                      contentPadding: EdgeInsets.fromLTRB(0, 10, 20, 10),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(92, 161, 161, 161))),
                      errorBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.red, width: 2.0)),
                      focusedErrorBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.red, width: 2.0)),
                    ), // Set initial value
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    {
                      inviteGroup(context, widget.groupId,
                          userNameController.text, _showErrorSnackbar);
                      userNameController.clear();
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: const Text("INVITE"),
                ),
                ElevatedButton(
                  onPressed: () {
                    userNameController.clear();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: const Text("CANCEL"),
                ),
              ],
            );
          }));
        });
  }

  //leave group
  leavePopUpDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            "Leave Group",
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.left,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Are you sure you want to leave this group?",
                  style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                leaveGroup(context, widget.groupId, widget.username,
                    _showErrorSnackbar);

                if (!kIsWeb) {
                  await FirebaseMessaging.instance
                      .unsubscribeFromTopic(widget.groupId);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else {
                  Future.delayed(Duration(milliseconds: 100), () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => MainScreen(index: 6),
                      ),
                    );
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              child: const Text("CONFIRM"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              child: const Text("CANCEL"),
            ),
          ],
        );
      },
    );
  }

  _createEventPopUpDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).canvasColor,
              title: const Text(
                "Add an event",
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LineComboBox(
                    selectedValue: _selectedEventType,
                    items:
                        eventTypes.map((e) => _getEventTypeString(e)).toList(),
                    icon: Icons.type_specimen,
                    onChanged: (dynamic newValue) {
                      setState(() {
                        _selectedEventType = newValue;
                      });
                    },
                  ),
                  LineTextField(
                    icon: Icons.title,
                    lableText: 'Title',
                    controller: titleController,
                    title: "",
                  ),
                  LineTextField(
                    icon: Icons.description,
                    lableText: "Description",
                    controller: descriptionController,
                    title: "",
                  ),
                  LineTextField(
                    //Text for now (add Dropdown for Buildings)
                    icon: Icons.place,
                    lableText: "Location",
                    controller: locationController,
                    title: "",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  LineDateTimeField(
                    icon: Icons.schedule,
                    controller: startController,
                    hintText: "Start Time",
                    firstDate: DateTime.now().subtract(Duration(days: 30)),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  LineDateTimeField(
                    icon: Icons.schedule,
                    controller: endController,
                    hintText: "End Time",
                    firstDate: DateTime.now().subtract(Duration(days: 30)),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    {
                      createEvent(
                          context,
                          _selectedEventType,
                          titleController.text,
                          descriptionController.text,
                          startController.text,
                          endController.text,
                          widget.groupId,
                          locationController.text, //add Location controller
                          _showErrorSnackbar);
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: const Text("CREATE"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: const Text("CANCEL"),
                ),
              ],
            );
          }));
        });
  }

  _removeEventPopUpDialog(BuildContext context, String eventId) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: const Text(
                "Remove an event",
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Are you sure you want remove this event? This action is irreversible.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    {
                      removeEvent(
                          context,
                          eventId, //Need a way to get eventId
                          widget.groupId,
                          _showErrorSnackbar);
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: const Text("CONFIRM"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: const Text("CANCEL"),
                ),
              ],
            );
          }));
        });
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

  Future<Uint8List?> downloadData(String username) async {
    return FirebaseStorage.instance
        .ref('ProfilePictures/' + username)
        .getData()
        .onError((error, stackTrace) => null);
  }

  Widget picture(BuildContext context, String username) {
    return FutureBuilder<Uint8List?>(
        future: downloadData(username),
        builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
          if (snapshot.hasData) {
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    // Here
                    return Dialog(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          PhotoView(
                            imageProvider: MemoryImage(snapshot.data!),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  // use circle if the icon is circular
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 15.0,
                                      spreadRadius: 2.0,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(dialogContext)
                                    .pop(); // Use dialogContext here
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                width: 50.0, // Set your desired width
                height: 50.0, // and height
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: MemoryImage(snapshot.data!),
                  ),
                ),
              ),
            );
          } else {
            return const Icon(
              Icons.account_circle,
              size: 47,
            );
          }
        });
  }

  Widget profilePicture2(BuildContext context, String username) {
    return InkWell(
      onTap: () {
        //edit image link click as per your need.
      },
      child: Stack(
        children: <Widget>[
          Container(
            width: 80,
            height: 80,
            child: CircleAvatar(
              backgroundColor: Colors.white70,
              radius: 20,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(200),
                  child: picture(context, username)),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> inviteGroup(
  BuildContext context,
  String groupId,
  String userId,
  void Function(String, bool) showErrorSnackbar,
) async {
  final url =
      kBaseUrl + "rest/chat/invite?groupId=" + groupId + "&userId=" + userId;
  final tokenID = await cacheFactory.get('users', 'token');
  final storedUsername = await cacheFactory.get('users', 'username');
  Token token = new Token(tokenID: tokenID, username: storedUsername);

  final response = await http.post(Uri.parse(url), headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${json.encode(token.toJson())}'
  });

  if (response.statusCode == 200) {
    showErrorSnackbar('Invite sent!', false);
  } else {
    showErrorSnackbar('Error sending the invite!', true);
  }
}

Future<void> createEvent(
  BuildContext context,
  String type,
  String title,
  String description,
  String start,
  String end,
  String groupID,
  String location,
  void Function(String, bool) showErrorSnackbar,
) async {
  final url = kBaseUrl + "rest/events/add";
  final tokenID = await cacheFactory.get('users', 'token');
  final storedUsername = await cacheFactory.get('users', 'username');
  Token token = new Token(tokenID: tokenID, username: storedUsername);

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${json.encode(token.toJson())}'
    },
    body: jsonEncode({
      'title': title,
      'type': type,
      'description': description,
      'startTime': start,
      'endTime': end,
      'creator': storedUsername,
      'groupID': groupID,
      'location': location
    }),
  );

  if (response.statusCode == 200) {
    showErrorSnackbar('Created an event successfully!', false);
  } else {
    showErrorSnackbar('Failed to create an event: ${response.body}', true);
  }
}

Future<void> removeEvent(
  BuildContext context,
  String eventId,
  String groupId,
  void Function(String, bool) showErrorSnackbar,
) async {
  final url = kBaseUrl + "rest/events/delete?eventID=$eventId&groupID=$groupId";
  final tokenID = await cacheFactory.get('users', 'token');
  final storedUsername = await cacheFactory.get('users', 'username');
  Token token = new Token(tokenID: tokenID, username: storedUsername);

  final response = await http.delete(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${json.encode(token.toJson())}'
    },
  );

  if (response.statusCode == 200) {
    showErrorSnackbar('Removed successfully!', false);
  } else {
    showErrorSnackbar('Failed to remove the event: ${response.body}', true);
  }
}

Future<void> leaveGroup(
  BuildContext context,
  String groupId,
  String userId,
  void Function(String, bool) showErrorSnackbar,
) async {
  final url =
      kBaseUrl + "rest/chat/leave?groupId=" + groupId + "&userId=" + userId;
  final tokenID = await cacheFactory.get('users', 'token');
  Token token = new Token(tokenID: tokenID, username: userId);

  final response = await http.post(Uri.parse(url), headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${json.encode(token.toJson())}'
  });

  if (response.statusCode == 200) {
    showErrorSnackbar('Left group!', false);
  } else {
    showErrorSnackbar('Error Leaving group!', true);
  }
}

class MembersData {
  final String username;
  final String dispName;
  bool isAdmin;

  MembersData(
      {required this.username, required this.dispName, required this.isAdmin});
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _tabBar;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

const _tabs = [
  Tab(icon: Icon(Icons.home_rounded), text: "Home"),
  Tab(icon: Icon(Icons.shopping_bag_rounded), text: "Cart"),
  Tab(icon: Icon(Icons.person), text: "Profile"),
];
