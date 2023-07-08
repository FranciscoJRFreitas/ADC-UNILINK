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
import 'package:unilink2023/widgets/LineButton.dart';
import 'package:unilink2023/widgets/LineComboBox.dart';
import 'package:unilink2023/widgets/LineTextField.dart';
import 'package:unilink2023/widgets/my_date_event_field.dart';
import 'package:unilink2023/widgets/my_text_button.dart';
import 'package:unilink2023/widgets/my_text_field.dart';
import '../../../constants.dart';
import 'package:http/http.dart' as http;

import '../../../data/cache_factory_provider.dart';
import '../../../domain/Token.dart';
import '../../../widgets/LineDateTimeField.dart';

import 'package:provider/provider.dart';
import 'package:unilink2023/domain/ThemeNotifier.dart';

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
  bool _isHovering = false;
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
      setState(() {
        isKeyboardOpen = false;
      });
    } else {
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
        ? _buildWeb()
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
              ],
            ),
            body: _buildMobile());
  }

  Widget _buildWeb() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // other parts of your code
          Column(
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
                  if (kIsWeb)
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: TextButton.icon(
                        icon: Icon(
                          Icons.exit_to_app_rounded,
                          color: Theme.of(context).secondaryHeaderColor,
                          size: 16,
                        ),
                        label: Text('Leave',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: Colors.white)),
                        onPressed: () {
                          leavePopUpDialogWeb(context);
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size(50, 50),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20),
              Divider(
                thickness: 3,
                color: Style.lightBlue,
              ),
              SizedBox(height: 10),
              Row(children: [
                Text('Description: ',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontSize: 16)),
                Text(
                  desc,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ]),
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
                                  .bodyMedium! /*.copyWith(color: Colors.white)*/),
                          onPressed: () {
                            _createEventPopUpDialogWeb(context);
                          },
                          style: TextButton.styleFrom(
                            minimumSize: Size(50, 50),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        //padding: EdgeInsets.all(16),
                        child: Container(
                          padding: EdgeInsets.only(
                              top: 10), //VALOR A ALTERAR OU NAO),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height -
                                433, //VALOR A ALTERAR
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
                                                : Theme.of(context)
                                                    .primaryColor,
                                            thickness: 1,
                                          ),
                                          Container(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 8),
                                              child: ListTile(
                                                title: Text(
                                                  event.title +
                                                      " (${_getEventTypeString(event.type)} Event)",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.description,
                                                            size: 20),
                                                        SizedBox(width: 5),
                                                        Text(event.description),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    if (event.location !=
                                                        null) ...[
                                                      Row(
                                                        children: [
                                                          Icon(Icons.place,
                                                              size: 20),
                                                          SizedBox(width: 5),
                                                          Text('Location: ' +
                                                              event.location!),
                                                        ],
                                                      ),
                                                      SizedBox(height: 8),
                                                    ],
                                                    Row(
                                                      children: [
                                                        Icon(Icons.schedule,
                                                            size: 20),
                                                        SizedBox(width: 5),
                                                        Text(
                                                            "Start: ${DateFormat('yyyy-MM-dd HH:mm').format(event.startTime)}"),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.schedule,
                                                            size: 20),
                                                        SizedBox(width: 5),
                                                        Text(
                                                            "End: ${DateFormat('yyyy-MM-dd HH:mm').format(event.endTime)}"),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5),
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
                                              child: MouseRegion(
                                                onHover: (event) => setState(
                                                    () => _isHovering = true),
                                                onExit: (event) => setState(
                                                    () => _isHovering = false),
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: _isHovering
                                                        ? Colors.red
                                                        : Colors.blue,
                                                  ),
                                                  onPressed: () {
                                                    _removeEventPopUpDialogWeb(
                                                        context, event.id!);
                                                  },
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
                  ],
                ),
                // your events code here

                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${members.length} Participants',
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
                                    .copyWith(color: Colors.white)),
                            onPressed: () {
                              popUpDialogWeb(context);
                            },
                            style: TextButton.styleFrom(
                              minimumSize: Size(50, 50),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 10),
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      padding: EdgeInsets.only(top: 10),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 553,
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

  Widget _buildMobile() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // other parts of your code
          Column(
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
                  if (kIsWeb)
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: TextButton.icon(
                        icon: Icon(
                          Icons.exit_to_app_rounded,
                          color: Theme.of(context).secondaryHeaderColor,
                          size: 16,
                        ),
                        label: Text('Leave',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: Colors.white)),
                        onPressed: () {
                          leavePopUpDialogMobile(context);
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size(50, 50),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20),
              Divider(
                thickness: 3,
                color: Style.lightBlue,
              ),
              SizedBox(height: 10),
              Row(children: [
                Text('Description: ',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontSize: 16)),
                Text(
                  desc,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ]),
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
            height: MediaQuery.of(context).size.height - 375, //VALOR A ALTERAR
            child: TabBarView(
              controller: _tabController,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                  .bodyMedium! /*.copyWith(color: Colors.white)*/),
                          onPressed: () {
                            _createEventPopUpDialogMobile(context);
                          },
                          style: TextButton.styleFrom(
                            minimumSize: Size(50, 50),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        //padding: EdgeInsets.all(16),
                        child: Container(
                          padding: EdgeInsets.only(
                              top: 10), //VALOR A ALTERAR OU NAO),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height -
                                451, //VALOR A ALTERAR
                            child: ListView.builder(
                                itemCount: events.length,
                                itemBuilder: (context, index) {
                                  Event event = events[index];
                                  return Material(
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
                                                : Theme.of(context)
                                                    .primaryColor,
                                            thickness: 1,
                                          ),
                                          Container(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 8),
                                              child: ListTile(
                                                title: Text(
                                                  event.title +
                                                      " (${_getEventTypeString(event.type)} Event)",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.description,
                                                            size: 20),
                                                        SizedBox(width: 5),
                                                        Text(event.description),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    if (event.location !=
                                                        null) ...[
                                                      Row(
                                                        children: [
                                                          Icon(Icons.place,
                                                              size: 20),
                                                          SizedBox(width: 5),
                                                          Text('Location: ' +
                                                              event.location!),
                                                        ],
                                                      ),
                                                      SizedBox(height: 8),
                                                    ],
                                                    Row(
                                                      children: [
                                                        Icon(Icons.schedule,
                                                            size: 20),
                                                        SizedBox(width: 5),
                                                        Text(
                                                            "Start: ${DateFormat('yyyy-MM-dd HH:mm').format(event.startTime)}"),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.schedule,
                                                            size: 20),
                                                        SizedBox(width: 5),
                                                        Text(
                                                            "End: ${DateFormat('yyyy-MM-dd HH:mm').format(event.endTime)}"),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5),
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
                                              child: MouseRegion(
                                                onHover: (event) => setState(
                                                    () => _isHovering = true),
                                                onExit: (event) => setState(
                                                    () => _isHovering = false),
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: _isHovering
                                                        ? Colors.red
                                                        : Colors.blue,
                                                  ),
                                                  onPressed: () {
                                                    _removeEventPopUpDialogMobile(
                                                        context, event.id!);
                                                  },
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
                  ],
                ),
                // your events code here

                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${members.length} Participants',
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
                                    .copyWith(color: Colors.white)),
                            onPressed: () {
                              popUpDialogMobile(context);
                            },
                            style: TextButton.styleFrom(
                              minimumSize: Size(50, 50),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 10),
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      padding: EdgeInsets.only(top: 10),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 500,
                        child: ListView.builder(
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              MembersData member = members[index];
                              return Material(
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

  void popUpDialogMobile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Style.darkBlue,
      builder: (context) => StatefulBuilder(
        builder: ((context, setState) {
          return SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
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
                  // padding to account for button
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.only(bottom: 8.0, right: 8.0, left: 8.0),
                        child: Column(
                          children: [
                            Text(
                              "Send an Invite",
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.left,
                            ),
                            TextField(
                              style: Theme.of(context).textTheme.bodyLarge,
                              controller: userNameController,
                              decoration: InputDecoration(
                                hintText: "Enter a valid username",
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(color: Colors.grey),
                                contentPadding:
                                    EdgeInsets.fromLTRB(0, 10, 20, 10),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(92, 161, 161, 161))),
                                errorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.red, width: 2.0)),
                                focusedErrorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.red, width: 2.0)),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    inviteGroup(
                                      context,
                                      widget.groupId,
                                      userNameController.text,
                                      _showErrorSnackbar,
                                    );
                                    userNameController.clear();
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black87,
                                  ),
                                  child: const Text("INVITE"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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

                if (!kIsWeb) {
                  /*await FirebaseMessaging.instance
                      .unsubscribeFromTopic(widget.groupId);*/
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
                          SizedBox(
                              height:
                                  40), // Add extra space at top for close button
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

                              if (!kIsWeb) {
                                /*await FirebaseMessaging.instance
                .unsubscribeFromTopic(widget.groupId);*/
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              } else {
                                Future.delayed(Duration(milliseconds: 100), () {
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) =>
                                          MainScreen(index: 6),
                                    ),
                                  );
                                });
                              }
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
                          _selectedLocation, //add Location controller
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
          return SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: MediaQuery.of(context).size.height * 0.98,
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
                      SizedBox(
                          height:
                              40), // Add extra space at top for close button
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
                ],
              ),
            ),
          );
        }),
      ),
    );
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
                    SizedBox(
                        height: 40), // Add extra space at top for close button
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
}

class EventLocationPopUp extends StatefulWidget {
  final BuildContext context;
  final LatLng? location;
  final bool isMapSelected;

  EventLocationPopUp({
    required this.context,
    required this.location,
    required this.isMapSelected,
  });

  @override
  _EventLocationPopUpState createState() => _EventLocationPopUpState();
}

class _EventLocationPopUpState extends State<EventLocationPopUp> {
  String? selectedPlace;
  LatLng? selectedLocation;
  late Set<Marker> edMarkers = Set();
  late Set<Marker> restMarkers = Set();
  late Set<Marker> parkMarkers = Set();
  late Set<Marker> portMarkers = Set();
  late Set<Marker> servMarkers = Set();

  @override
  void initState() {
    super.initState();
    loadMarkers();
    if (widget.isMapSelected) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showMapDialog());
    } else {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _showFCTPlaceDialog());
    }
  }

  loadMarkers() async {
    edMarkers = await loadEdLocationsFromJson();
    restMarkers = await loadRestLocationsFromJson();
    parkMarkers = await loadParkLocationsFromJson();
    portMarkers = await loadPortLocationsFromJson();
    servMarkers = await loadServLocationsFromJson();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  void _showFCTPlaceDialog() {
    showDialog<LatLng>(
      context: widget.context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).canvasColor,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (selectedPlace != null) ...[
                    IconButton(
                      hoverColor: Theme.of(context).hoverColor.withOpacity(0.1),
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          selectedPlace = null;
                        });
                      },
                    ),
                    SizedBox(
                      width: 10,
                    )
                  ],
                  Text(
                    "Select a FCT Location",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontSize: 30),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: selectedPlace == null
                      ? [
                          ListTile(
                            title: Text(
                              'Building',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontSize: 20),
                            ),
                            onTap: () => setState(() {
                              selectedPlace = 'Building';
                            }),
                          ),
                          ListTile(
                            title: Text(
                              'Restaurant',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontSize: 20),
                            ),
                            onTap: () => setState(() {
                              selectedPlace = 'Restaurant';
                            }),
                          ),
                          ListTile(
                            title: Text(
                              'Park',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontSize: 20),
                            ),
                            onTap: () => setState(() {
                              selectedPlace = 'Park';
                            }),
                          ),
                          ListTile(
                            title: Text(
                              'Port',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontSize: 20),
                            ),
                            onTap: () => setState(() {
                              selectedPlace = 'Port';
                            }),
                          ),
                          ListTile(
                            title: Text(
                              'Service',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontSize: 20),
                            ),
                            onTap: () => setState(() {
                              selectedPlace = 'Service';
                            }),
                          ),
                        ]
                      : getMarkersForPlace(selectedPlace!)
                          .map((marker) => ListTile(
                              title: Text(
                                marker.infoWindow.title!,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(fontSize: 20),
                              ),
                              onTap: () => {
                                    setState(() {
                                      selectedLocation = marker.position;
                                    }),
                                    Navigator.of(context).pop(selectedLocation),
                                    Navigator.of(context).pop(selectedLocation),
                                  }))
                          .toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).secondaryHeaderColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Set<Marker> getMarkersForPlace(String place) {
    switch (place) {
      case 'Building':
        return edMarkers;
      case 'Restaurant':
        return restMarkers;
      case 'Park':
        return parkMarkers;
      case 'Port':
        return portMarkers;
      case 'Service':
        return servMarkers;
      default:
        return {};
    }
  }

  void _showMapDialog() {
    LatLng? preLocation;
    Set<Marker> _markers = {};
    showDialog(
      context: widget.context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: GoogleMap(
                      onMapCreated: (GoogleMapController controller) {},
                      initialCameraPosition: CameraPosition(
                        target: LatLng(38.660999, -9.205094),
                        zoom: 17,
                      ),
                      onTap: (LatLng location) {
                        setState(() {
                          preLocation = location;
                          _markers.clear();
                          _markers.add(Marker(
                            markerId: MarkerId(preLocation.toString()),
                            position: preLocation!,
                          ));
                        });
                      },
                      markers: _markers,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (preLocation != null)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedLocation = preLocation;
                            });
                            Navigator.of(context).pop(selectedLocation);
                            Navigator.of(context).pop(selectedLocation);
                          },
                          child: Text('Select Location'),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          selectedLocation = null;
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
      },
    );
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
