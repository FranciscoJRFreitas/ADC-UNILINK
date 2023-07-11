import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:unilink2023/application/loadLocations.dart';
import 'package:unilink2023/features/calendar/domain/Event.dart';
import 'package:unilink2023/features/chat/presentation/chat_member_info.dart';
import 'package:unilink2023/features/navigation/main_screen_page.dart';
import 'package:unilink2023/widgets/AutoCompleteDropdown.dart';
import 'package:unilink2023/widgets/LineComboBox.dart';
import 'package:unilink2023/widgets/LineTextField.dart';
import '../../../constants.dart';
import 'package:http/http.dart' as http;

import '../../../data/cache_factory_provider.dart';
import '../../../domain/Token.dart';
import '../../../widgets/LineDateTimeField.dart';

import 'package:provider/provider.dart';
import 'package:unilink2023/domain/ThemeNotifier.dart';

import '../../../widgets/LocationPopUp.dart';

class ChatInfoPage extends StatefulWidget {
  final String groupId;
  final String username;

  ChatInfoPage({required this.groupId, required this.username});

  @override
  State<ChatInfoPage> createState() => _ChatInfoPageState();
}

class _ChatInfoPageState extends State<ChatInfoPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();
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
  bool isLocationSelected = false;
  TabController? _tabController;
  bool isKeyboardOpen = false;

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
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance?.addObserver(this);
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
    _tabController?.dispose();
    WidgetsBinding.instance?.removeObserver(this);
  }

  @override
  void didChangeMetrics() {
    final value = MediaQuery.of(context).viewInsets.bottom;
    print(value);
    if (value < 50) {
      // adjust this value based on your needs
      if (mounted)
        setState(() {
          isKeyboardOpen = false;
        });
    } else {
      if (mounted)
        setState(() {
          isKeyboardOpen = true;
        });
    }
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
            return Icon(
              color: Theme.of(context).secondaryHeaderColor,
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
              backgroundColor: Colors.transparent,
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
        ? _buildLayout(context)
        : Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              centerTitle: true,
              elevation: 0,
              title: Text(
                "Group Information",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge!.color),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.exit_to_app_rounded),
                  tooltip: 'Leave Group',
                  onPressed: () {
                    leavePopUpDialogMobile(context);
                  },
                ),
                if (isAdmin)
                  IconButton(
                    icon: Icon(Icons.delete),
                    tooltip: 'Delete Group',
                    onPressed: () {
                      deletePopUpDialogMobile(context);
                    },
                  ),
              ],
            ),
            body: _buildLayout(context));
  }

  Widget _buildLayout(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // other parts of your code
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Row(
                children: [
                  profilePicture(context),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ' ' + widget.groupId,
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Row(
                          children: [
                            if (kIsWeb)
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: TextButton.icon(
                                  icon: Icon(
                                    Icons.exit_to_app_rounded,
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    size: 16,
                                  ),
                                  label: Text(
                                    'Leave',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor),
                                  ),
                                  onPressed: () {
                                    if (kIsWeb)
                                      leavePopUpDialogWeb(context);
                                    else
                                      leavePopUpDialogMobile(context);
                                  },
                                  style: TextButton.styleFrom(
                                    minimumSize: Size(50, 50),
                                  ),
                                ),
                              ),
                            if (kIsWeb && isAdmin)
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: TextButton.icon(
                                  icon: Icon(
                                    Icons.delete,
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    size: 16,
                                  ),
                                  label: Text(
                                    'Delete',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor),
                                  ),
                                  onPressed: () {
                                    if (kIsWeb)
                                      deletePopUpDialogWeb(context);
                                    else
                                      deletePopUpDialogMobile(context);
                                  },
                                  style: TextButton.styleFrom(
                                    minimumSize: Size(50, 50),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Divider(
                thickness: 3,
                color: Style.lightBlue,
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Text(
                    'Description: ',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontSize: 16),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection:
                          Axis.horizontal, // use this for horizontal scrolling
                      child: Text(
                        desc,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Divider(
                thickness: 3,
                color: Style.lightBlue,
              ),
              SizedBox(height: 5),
            ],
          ),
          TabBar(
            controller: _tabController,
            dividerColor: Style.lightBlue,
            indicatorColor: Style.lightBlue,
            labelStyle: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).secondaryHeaderColor),
            labelColor: Theme.of(context).secondaryHeaderColor,
            overlayColor: MaterialStatePropertyAll(Theme.of(context)
                .scaffoldBackgroundColor
                .withRed(Theme.of(context).scaffoldBackgroundColor.red - 20)
                .withBlue(Theme.of(context).scaffoldBackgroundColor.blue - 20)
                .withGreen(
                    Theme.of(context).scaffoldBackgroundColor.green - 20)),
            tabs: [
              Tab(
                  icon: Icon(Icons.event, color: Style.lightBlue),
                  text: 'Events'),
              Tab(
                  icon: Icon(Icons.group, color: Style.lightBlue),
                  text: 'Members'),
            ],
          ),

          Container(
            height: MediaQuery.of(context).size.height - 363, //VALOR A ALTERAR
            child: TabBarView(
              controller: _tabController,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${events.length} ${(events.length != 1) ? 'Events' : 'Event'}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontSize: 16),
                        ),
                        if (isAdmin) ...[
                          Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: TextButton.icon(
                              icon: Icon(
                                Icons.event,
                                color: Theme.of(context).secondaryHeaderColor,
                                size: 20,
                              ),
                              label: Text(
                                'Add event',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor),
                              ),
                              onPressed: () {
                                if (kIsWeb)
                                  _createEventPopUpDialogWeb(context);
                                else
                                  _createEventPopUpDialogMobile(context);
                              },
                              style: TextButton.styleFrom(
                                minimumSize: Size(50, 50),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SingleChildScrollView(
                      //padding: EdgeInsets.all(16),
                      child: Container(
                        padding:
                            EdgeInsets.only(top: 10), //VALOR A ALTERAR OU NAO),
                        child: SizedBox(
                          height: kIsWeb
                              ? MediaQuery.of(context).size.height - 435
                              : MediaQuery.of(context).size.height *
                                  0.4, //VALOR A ALTERAR
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
                                        Divider(
                                          color: Provider.of<ThemeNotifier>(
                                                          context)
                                                      .currentTheme ==
                                                  kDarkTheme
                                              ? Colors.white60
                                              : Theme.of(context).primaryColor,
                                          thickness: 1,
                                        ),
                                        Container(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 8),
                                            child: ListTile(
                                              title: Row(
                                                children: [
                                                  getDateIcon(event, context),
                                                  InkWell(
                                                    child: Text(
                                                      event.title,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => MainScreen(
                                                                        index:
                                                                            9,
                                                                        date: event
                                                                            .startTime)));
                                                          },
                                                          child: Tooltip(
                                                            message:
                                                                "View in Calendar",
                                                            child: Icon(
                                                                Icons
                                                                    .perm_contact_calendar,
                                                                size: 20,
                                                                color: Style
                                                                    .lightBlue),
                                                          ),
                                                        ),
                                                        if (event.location !=
                                                            "0") ...[
                                                          SizedBox(width: 10),
                                                          InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => MainScreen(
                                                                          index:
                                                                              10,
                                                                          location:
                                                                              event.location)));
                                                            },
                                                            child: Tooltip(
                                                              message:
                                                                  "View in Maps",
                                                              child: Icon(
                                                                  Icons
                                                                      .directions,
                                                                  size: 20,
                                                                  color: Style
                                                                      .lightBlue),
                                                            ),
                                                          ),
                                                        ],
                                                        if (isAdmin) ...[
                                                          SizedBox(width: 10),
                                                          InkWell(
                                                            onTap: () {
                                                              if (kIsWeb)
                                                                _removeEventPopUpDialogWeb(
                                                                    context,
                                                                    event.id!);
                                                              else
                                                                _removeEventPopUpDialogMobile(
                                                                    context,
                                                                    event.id!);
                                                            },
                                                            child: Tooltip(
                                                              message:
                                                                  "Remove Event",
                                                              child: Icon(
                                                                Icons.delete,
                                                                color: Colors
                                                                    .lightBlue,
                                                                size: 20,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.type_specimen,
                                                          size: 20,
                                                          color:
                                                              Style.lightBlue),
                                                      SizedBox(width: 5),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Type: ',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleMedium!
                                                                .copyWith(
                                                                    fontSize:
                                                                        14),
                                                          ),
                                                          Text(
                                                            _getEventTypeString(
                                                                event.type),
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.description,
                                                          size: 20,
                                                          color:
                                                              Style.lightBlue),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        'Description: ',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                fontSize: 14),
                                                      ),
                                                      Flexible(
                                                        child: Text(
                                                          event.description,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8),
                                                  if (event.location !=
                                                      '0') ...[
                                                    Row(
                                                      children: [
                                                        Icon(Icons.place,
                                                            size: 20,
                                                            color: Style
                                                                .lightBlue),
                                                        SizedBox(width: 5),
                                                        Text(
                                                          'Location: ',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleMedium!
                                                                  .copyWith(
                                                                      fontSize:
                                                                          14),
                                                        ),
                                                        FutureBuilder<String>(
                                                          future:
                                                              getPlaceInLocations(
                                                                  event
                                                                      .location!),
                                                          builder: (BuildContext
                                                                  context,
                                                              AsyncSnapshot<
                                                                      String>
                                                                  snapshot) {
                                                            if (snapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .waiting) {
                                                              return SizedBox
                                                                  .shrink();
                                                            } else {
                                                              if (snapshot
                                                                  .hasError)
                                                                return Text(
                                                                    'Error: ${snapshot.error}');
                                                              else
                                                                return snapshot
                                                                            .data ==
                                                                        ""
                                                                    ? Text(
                                                                        "Custom Location",
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyMedium,
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      )
                                                                    : Text(
                                                                        snapshot
                                                                            .data!,
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyMedium,
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      );
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                  ],
                                                  Row(
                                                    children: [
                                                      Icon(Icons.schedule,
                                                          size: 20,
                                                          color:
                                                              Style.lightBlue),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        'Start: ',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                fontSize: 14),
                                                      ),
                                                      Flexible(
                                                        child: Text(
                                                          '${DateFormat('yyyy-MM-dd HH:mm').format(event.startTime)}',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.schedule,
                                                          size: 20,
                                                          color:
                                                              Style.lightBlue),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        'End: ',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                                fontSize: 14),
                                                      ),
                                                      Flexible(
                                                        child: Text(
                                                          '${DateFormat('yyyy-MM-dd HH:mm').format(event.endTime)}',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          color: Colors.black87,
                                          thickness: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 3,
                      color: Style.lightBlue,
                    ),
                  ],
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${members.length} ${(members.length != 1) ? 'Participants' : 'Participant'}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontSize: 16),
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
                                    .copyWith(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor)),
                            onPressed: () {
                              if (kIsWeb)
                                popUpDialogWeb(context);
                              else
                                popUpDialogMobile(context);
                            },
                            style: TextButton.styleFrom(
                              minimumSize: Size(50, 50),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SingleChildScrollView(
                    //padding: EdgeInsets.all(16),
                    child: Container(
                      padding: EdgeInsets.only(top: 10),
                      child: SizedBox(
                        height: kIsWeb
                            ? MediaQuery.of(context).size.height - 435
                            : MediaQuery.of(context).size.height * 0.4,
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
                                  child: Container(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 5),
                                      child: ListTile(
                                        leading: profilePicture2(
                                            context, member.username),
                                        title: Text(
                                          '${member.dispName}${member.username == widget.username ? ' (You)' : ''}${member.isAdmin ? ' (Admin)' : ''}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.alternate_email,
                                                    size: 13),
                                                SizedBox(width: 5),
                                                Text(
                                                  'Username: ${member.username}',
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 3,
                    color: Style.lightBlue,
                  ),
                ]
                    // your members code here
                    ),
              ],
            ),
          ),

          // other parts of your code
        ],
      ),
    );
  }

  popUpDialogWeb(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AutocompleteDropdown(groupId: widget.groupId, showError: _showErrorSnackbar);
          }));
        });
  }

  void popUpDialogMobile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Style.darkBlue,
      builder: (context) => StatefulBuilder(
        builder: ((context, setState) {
          return AutocompleteDropdown(groupId: widget.groupId, showError: _showErrorSnackbar);
        }),
      ),
    );
  }

  //leave group
  deletePopUpDialogWeb(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            "Delete Group",
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.left,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Are you sure you want to delete this group?",
                  style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                deleteGroup(context, widget.groupId, widget.username,
                    _showErrorSnackbar);

                Future.delayed(Duration(milliseconds: 100), () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => MainScreen(index: 6),
                    ),
                  );
                });
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

  void deletePopUpDialogMobile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Style.darkBlue,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: ((context, setState) {
          return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            height: MediaQuery.of(context).size.height * 0.30,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context); // closes the modal
                          },
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 40),
                          // Add extra space at top for close button
                          Text(
                            "Delete Group",
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Are you sure you want to delete this group?",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              deleteGroup(context, widget.groupId,
                                  widget.username, _showErrorSnackbar);

                              Future.delayed(Duration(milliseconds: 100), () {
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => MainScreen(index: 6),
                                  ),
                                );
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                            ),
                            child: const Text("CONFIRM"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  //leave group
  leavePopUpDialogWeb(BuildContext context) {
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

                Future.delayed(Duration(milliseconds: 100), () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => MainScreen(index: 6),
                    ),
                  );
                });
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

  void leavePopUpDialogMobile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Style.darkBlue,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: ((context, setState) {
          return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            height: MediaQuery.of(context).size.height * 0.30,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context); // closes the modal
                          },
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 40),
                          // Add extra space at top for close button
                          Text(
                            "Leave Group",
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Are you sure you want to leave this group?",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              leaveGroup(context, widget.groupId,
                                  widget.username, _showErrorSnackbar);

                              Future.delayed(Duration(milliseconds: 100), () {
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => MainScreen(index: 6),
                                  ),
                                );
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                            ),
                            child: const Text("CONFIRM"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  _createEventPopUpDialogWeb(BuildContext context) {
    LatLng? _selectedLocation = null;
    String selectLocationText = "Select Location";
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
                    lableText: 'Title *',
                    controller: titleController,
                    title: "",
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  LineTextField(
                    icon: Icons.description,
                    lableText: "Description",
                    controller: descriptionController,
                    title: "",
                  ),
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
                  SizedBox(
                    height: 10,
                  ),
                  LineDateTimeField(
                    icon: Icons.schedule,
                    controller: startController,
                    hintText: "Start Time *",
                    firstDate: DateTime.now().subtract(Duration(days: 30)),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  LineDateTimeField(
                    icon: Icons.schedule,
                    controller: endController,
                    hintText: "End Time *",
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
                          _selectedLocation,
                          //add Location controller
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
                    userNameController.clear();
                    titleController.clear();
                    descriptionController.clear();
                    startController.clear();
                    endController.clear();
                    _selectedLocation = null;
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

  void _createEventPopUpDialogMobile(BuildContext context) {
    LatLng? _selectedLocation = null;
    String selectLocationText = "Select Location";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Style.darkBlue,
      builder: (context) => StatefulBuilder(
        builder: ((context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Stack(children: [
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                      titleController.clear();
                      descriptionController.clear();
                      startController.clear();
                      endController.clear();
                    },
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    // Add extra space at top for close button
                    const Text(
                      "Add an event",
                      textAlign: TextAlign.left,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LineComboBox(
                          selectedValue: _selectedEventType,
                          items: eventTypes
                              .map((e) => _getEventTypeString(e))
                              .toList(),
                          icon: Icons.type_specimen,
                          onChanged: (dynamic newValue) {
                            setState(() {
                              _selectedEventType = newValue;
                            });
                          },
                        ),
                        LineTextField(
                          icon: Icons.title,
                          lableText: 'Title *',
                          controller: titleController,
                          title: "",
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        LineTextField(
                          icon: Icons.description,
                          lableText: "Description",
                          controller: descriptionController,
                          title: "",
                        ),
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
                              LatLng? selectedLocation =
                                  await showDialog<LatLng>(
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
                        SizedBox(
                          height: 10,
                        ),
                        LineDateTimeField(
                          icon: Icons.schedule,
                          controller: startController,
                          hintText: "Start Time *",
                          firstDate:
                              DateTime.now().subtract(Duration(days: 30)),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        LineDateTimeField(
                          icon: Icons.schedule,
                          controller: endController,
                          hintText: "End Time *",
                          firstDate:
                              DateTime.now().subtract(Duration(days: 30)),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                createEvent(
                                    context,
                                    _selectedEventType,
                                    titleController.text,
                                    descriptionController.text,
                                    startController.text,
                                    endController.text,
                                    widget.groupId,
                                    _selectedLocation,
                                    _showErrorSnackbar);
                                Navigator.of(context).pop();
                                titleController.clear();
                                descriptionController.clear();
                                startController.clear();
                                endController.clear();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87),
                              child: const Text("CREATE"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ]),
            ),
          );
        }),
      ),
    ).then((value) {
      // This code will run when the modal is dismissed
      titleController.clear();
      descriptionController.clear();
      startController.clear();
      endController.clear();
    });
  }

  _removeEventPopUpDialogWeb(BuildContext context, String eventId) {
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
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        {
                          removeEvent(context, eventId, widget.groupId,
                              _showErrorSnackbar);
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor),
                      child: const Text("CONFIRM"),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor),
                      child: const Text("CANCEL"),
                    ),
                  ],
                ),
              ],
            );
          }));
        });
  }

  void _removeEventPopUpDialogMobile(BuildContext context, String eventId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Style.darkBlue,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: ((context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.3,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context); // closes the modal
                    },
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    // Add extra space at top for close button
                    const Text(
                      "Remove an event",
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                          "Are you sure you want remove this event? This action is irreversible.",
                          style: Theme.of(context).textTheme.bodyLarge!),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        removeEvent(context, eventId, widget.groupId,
                            _showErrorSnackbar);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87),
                      child: const Text("CONFIRM"),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
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

  Widget getDateIcon(Event event, BuildContext context) {
    DateTime currentDate = DateTime.now();
    DateTime startDate = event.startTime;
    DateTime endDate = event.endTime;

    int prev = currentDate.difference(startDate).inMilliseconds;
    int after = endDate.difference(currentDate).inMilliseconds;

    return prev > 0
        ? after > 0
            ? Tooltip(
                message: 'Ongoing Event',
                child: MouseRegion(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.hourglass_top,
                      color: Colors.yellow,
                    ),
                  ),
                ),
              )
            : Tooltip(
                message: 'Past Event',
                child: MouseRegion(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                  ),
                ),
              )
        : Tooltip(
            message: 'Upcoming Event',
            child: MouseRegion(
              child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.more_time, color: Colors.blueGrey)),
            ),
          );
  }

  Future<void> inviteGroup(
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
    LatLng? location,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    final url = kBaseUrl + "rest/events/add";
    final tokenID = await cacheFactory.get('users', 'token');
    final storedUsername = await cacheFactory.get('users', 'username');
    Token token = new Token(tokenID: tokenID, username: storedUsername);

    if (type.isEmpty || title.isEmpty || start.isEmpty || end.isEmpty) {
      showErrorSnackbar('Obligatory fields missing!', true);
      return;
    }

    var response;
    if (location != null) {
      response = await http.post(
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
          'location': "${location.latitude},${location.longitude}"
        }),
      );
    } else {
      response = await http.post(
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
          'location': '0'
        }),
      );
    }

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
    final url =
        kBaseUrl + "rest/events/delete?eventID=$eventId&groupID=$groupId";
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
      userNameController.clear();
      titleController.clear();
      descriptionController.clear();
      startController.clear();
      endController.clear();
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
    cacheFactory.removeGroup(groupId);
    cacheFactory.deleteMessage(
        groupId, '-1'); //Deleting group messages from cache
    final url =
        kBaseUrl + "rest/chat/leave?groupId=" + groupId + "&userId=" + userId;
    final tokenID = await cacheFactory.get('users', 'token');
    Token token = new Token(tokenID: tokenID, username: userId);

    final response = await http.post(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${json.encode(token.toJson())}'
    });

    if (response.statusCode == 200) {
      final databaseRef =
          FirebaseDatabase.instance.ref().child('groups').child(groupId);
      // Check if the group exists in the Realtime Database
      final DatabaseEvent snapshot = await databaseRef.once();
      if (snapshot.snapshot.value == null) {
        deleteFolder("GroupAttachements/${groupId}");

        final imageRef = FirebaseStorage.instance.ref('GroupPictures/$groupId');
        await imageRef.delete();
        showErrorSnackbar('Left group!', false);
      }
    } else {
      showErrorSnackbar('Error Leaving group!', true);
    }
  }

  Future<void> deleteGroup(
    BuildContext context,
    String groupId,
    String userId,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    cacheFactory.removeGroup(groupId);
    cacheFactory.deleteMessage(
        groupId, '-1'); //Deleting group messages from cache
    final url = kBaseUrl + "rest/chat/delete/${groupId}";
    final tokenID = await cacheFactory.get('users', 'token');
    Token token = new Token(tokenID: tokenID, username: userId);

    final response = await http.delete(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${json.encode(token.toJson())}'
    });

    if (response.statusCode == 200) {
      deleteFolder("GroupAttachements/${groupId}");

      final imageRef = FirebaseStorage.instance.ref('GroupPictures/$groupId');
      await imageRef.delete();

      showErrorSnackbar('deleted group!', false);
    } else {
      showErrorSnackbar('Error deleting group!', true);
    }
  }
}

Future<void> deleteFolder(String folderPath) async {
  final storage = FirebaseStorage.instance;
  final ListResult result = await storage.ref(folderPath).listAll();

  // Delete each file within the folder
  for (final Reference ref in result.items) {
    await ref.delete();
  }

  // Delete the empty folder
  await storage.ref(folderPath).delete();
}

class MembersData {
  final String username;
  final String dispName;
  bool isAdmin;

  MembersData(
      {required this.username, required this.dispName, required this.isAdmin});
}
