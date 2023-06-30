import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unilink2023/features/chat/presentation/chat_msg_page.dart';
import '../../../domain/Group.dart';
import '../../../domain/Token.dart';
import '../../../domain/User.dart';
import '../../../widgets/my_text_field.dart';
import '../../../widgets/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../data/cache_factory_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChatPage extends StatefulWidget {
  final User user;

  ChatPage({required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  late Stream<List<Group>> groupsStream;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  Group? selectedGroup;

  @override
  void initState() {
    super.initState();

    groupsStream = listenForGroups();
  }

  Stream<List<Group>> listenForGroups() {
    DatabaseReference chatRef = FirebaseDatabase.instance
        .ref()
        .child('chat')
        .child(widget.user.username)
        .child('Groups');
    DatabaseReference groupsRef =
        FirebaseDatabase.instance.ref().child('groups');
    DatabaseReference membersRef =
        FirebaseDatabase.instance.ref().child('members');

    StreamController<List<Group>> streamController = StreamController();
    List<Group> groups = [];

    // Listen for initial data and subsequent child additions
    chatRef.onChildAdded.listen((event) async {
      String groupId = event.snapshot.key as String;

      // Fetch group details from groupsRef
      DatabaseEvent groupSnapshot = await groupsRef.child(groupId).once();
      Map<dynamic, dynamic> groupData =
          groupSnapshot.snapshot.value as Map<dynamic, dynamic>;

      // Fetch members details from membersRef
      DatabaseEvent memberSnapshot = await membersRef.child(groupId).once();
      Map<dynamic, dynamic> memberData =
          memberSnapshot.snapshot.value as Map<dynamic, dynamic>;

      String displayName = groupData['DisplayName'];
      String description = groupData['description'];
      int numberOfMembers = memberData.length; // get the number of members
      Group group = Group(
        id: groupId,
        DisplayName: displayName,
        description: description,
        numberOfMembers: numberOfMembers, // this is your new field
      );
      groups.add(group);

      streamController.add(groups); // Add groups to the stream
    });

    // Listen for child removal using onChildRemoved
    chatRef.onChildRemoved.listen((event) {
      String groupId = event.snapshot.key as String;

      setState(() {
        groups.removeWhere((group) => group.id == groupId);
      });
    });

    return streamController.stream;
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

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildWebLayout(context, selectedGroup);
    } else {
      return _buildMobileLayout(context);
    }
  }

  Widget _buildWebLayout(BuildContext context, Group? selectedGroup) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: _buildLeftWidget(context),
          ),
          if (selectedGroup != null)
            Expanded(
              flex: 2,
              child: GroupMessagesPage(
                key: ValueKey(selectedGroup.id),
                groupId: selectedGroup.id,
                user: widget.user,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeftWidget(BuildContext context) {
    // Your existing widget code, with modifications to onTap:
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        title: Text("Grupos"),
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
      ),
      body: Stack(
        children: <Widget>[
          StreamBuilder<List<Group>>(
            stream: groupsStream,
            builder:
                (BuildContext context, AsyncSnapshot<List<Group>> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                List<Group> groups = snapshot.data!;
                return ListView(
                  padding: EdgeInsets.only(top: 10, bottom: 80),
                  children: groups.map((group) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGroup = group;
                        });
                      },
                      child: Card(
                        color: selectedGroup == group
                            ? Theme.of(context).primaryColorDark
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          child: ListTile(
                            title: Text(
                              '${group.DisplayName}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.person, size: 20),
                                    SizedBox(width: 5),
                                    Text('Description: ${group.description}'),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.people, size: 20),
                                    SizedBox(width: 5),
                                    Text('${group.numberOfMembers} members'),
                                  ],
                                ),
                                // ... Add other information rows with icons here
                                // Make sure to add some spacing (SizedBox) between rows for better readability
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              } else {
                return noGroupWidget();
              }
            },
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: FloatingActionButton(
                  onPressed: () {
                    popUpDialog(context);
                  },
                  elevation: 6,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          StreamBuilder<List<Group>>(
            stream: groupsStream, // Replace with your stream of groups
            builder:
                (BuildContext context, AsyncSnapshot<List<Group>> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                List<Group> groups = snapshot.data!;

                return ListView(
                  padding: EdgeInsets.only(top: 10, bottom: 80),
                  children: groups.map((group) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GroupMessagesPage(
                              key: ValueKey(group.id),
                              groupId: group.id,
                              user: widget.user,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          child: ListTile(
                            title: Text(
                              '${group.DisplayName}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.person, size: 20),
                                    SizedBox(width: 5),
                                    Text('Description: ${group.description}'),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.people, size: 20),
                                    SizedBox(width: 5),
                                    Text('${group.numberOfMembers} members'),
                                  ],
                                ),
                                // ... Add other information rows with icons here
                                // Make sure to add some spacing (SizedBox) between rows for better readability
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              } else {
                return noGroupWidget();
              }
            },
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: IconButton(
                onPressed: () {
                  // nextScreen(context, const Placeholder()); //searchPageChat
                  // Replace the above line with your desired logic
                },
                icon: const Icon(Icons.search),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        elevation: 50,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
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
              title: const Text(
                "Create a group",
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyTextField(
                    small: false,
                    hintText: 'Group name',
                    inputType: TextInputType.text,
                    controller: groupNameController,
                  ),
                  MyTextField(
                    small: false,
                    hintText: 'Group Description',
                    inputType: TextInputType.text,
                    controller: descriptionController,
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: const Text("CANCEL"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    {
                      createGroup(context, groupNameController.text,
                          descriptionController.text, _showErrorSnackbar);
                      Navigator.of(context).pop();
                      showSnackbar(
                          context, Colors.green, "Group created successfully.");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: const Text("CREATE"),
                )
              ],
            );
          }));
        });
  }

  noGroupWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  popUpDialog(context);
                },
                child: Icon(
                  Icons.add_circle,
                  color: Colors.grey[700],
                  size: 75,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "You've not joined any groups, tap on the add icon to create a group or also search from top search button.",
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  Future<void> createGroup(
    BuildContext context,
    String groupName,
    String description,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    final url = "https://unilink23.oa.r.appspot.com/rest/chat/create";
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
        'DisplayName': groupName,
        'description': description,
        'adminID': storedUsername
      }),
    );

    if (response.statusCode == 200) {
      showErrorSnackbar('Created a group successfully!', false);
      if (!kIsWeb) _firebaseMessaging.subscribeToTopic(groupName);
    } else {
      showErrorSnackbar('Failed to create a group: ${response.body}', true);
    }
    groupNameController.clear();
    descriptionController.clear();
  }
}
