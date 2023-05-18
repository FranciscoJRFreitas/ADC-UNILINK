import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unilink2023/presentation/chat_msg_page.dart';
import '../domain/Group.dart';
import '../domain/Token.dart';
import '../widgets/my_text_field.dart';
import '../widgets/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unilink2023/domain/cacheFactory.dart' as cache;
import 'package:firebase_database/firebase_database.dart';

class ChatPage extends StatefulWidget {
  ChatPage();

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  var username;
  Stream<List<Group>>? groupsStream;

  @override
  void initState() {
    super.initState();

    getUsername();
    groupsStream = listenForGroups();
  }

  Stream<List<Group>> listenForGroups() {
    DatabaseReference chatsRef = FirebaseDatabase.instance.ref().child('chats');
    DatabaseReference membersRef =
        FirebaseDatabase.instance.ref().child('members');

    StreamController<List<Group>> streamController = StreamController();

    chatsRef.onValue.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      List<Group> groups = [];

      Map<dynamic, dynamic> chatData = snapshot.value as Map<dynamic, dynamic>;

      chatData.forEach((key, value) {
        String id = key;
        String displayName = value['DisplayName'];
        String description = value['description'];

        membersRef.child(key).onValue.listen((memberEvent) {
          DataSnapshot memberSnapshot = memberEvent.snapshot;
          Map<dynamic, dynamic>? memberData =
              memberSnapshot.value as Map<dynamic, dynamic>?;

          if (memberData != null && memberData[username] != null) {
            Group group = Group(
                id: id, DisplayName: displayName, description: description);
            groups.add(group);
          }

          streamController.add(groups);
        });
      });
    });

    return streamController.stream;
  }

  /*gettingUserData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunctions.getUserNameFromSF().then((val) {
      setState(() {
        userName = val!;
      });
    });
    // getting the list of snapshots in our stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }*/

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
    return Scaffold(
      body: Stack(
        children: <Widget>[
          StreamBuilder<List<Group>>(
            stream: groupsStream, // Replace with your stream of groups
            builder:
                (BuildContext context, AsyncSnapshot<List<Group>> snapshot) {
              if (snapshot.hasData) {
                List<Group> groups = snapshot.data!;

                if (groups.isEmpty) {
                  return noGroupWidget();
                } else {
                  return ListView(
                    padding: EdgeInsets.only(
                        top: 10, bottom: 80), // Adjust the padding as needed
                    children: groups.map((group) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => GroupMessagesPage(
                                    groupId: group.DisplayName,
                                    username: username)),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 8),
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
                }
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
          // ... existing code ...
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.all(16.0), // Adjust this as needed
              child: IconButton(
                onPressed: () {
                  nextScreen(context, const Placeholder()); //searchPageChat
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
        elevation: 0,
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
                      style: TextStyle(color: Colors.black)),
                  MyTextField(
                    small: false,
                    hintText: 'Group Description',
                    inputType: TextInputType.text,
                    controller: descriptionController,
                    style: TextStyle(color: Colors.black),
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

  /*} else {
              return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor),
              );
            }*/

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
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
    );
  }

  void getUsername() async {
    username = await cache.getValue('users', 'username');
  }

  Future<void> createGroup(
    BuildContext context,
    String groupName,
    String description,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    final url = "https://unilink23.oa.r.appspot.com/rest/chat/create";
    final tokenID = await cache.getValue('users', 'token');
    final storedUsername = await cache.getValue('users', 'username');
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
      showErrorSnackbar('Changes applied successfully!', false);
    } else {
      showErrorSnackbar('Failed to create a group: ${response.body}', true);
    }
    setState(() {
      groupNameController.clear();
      descriptionController.clear();
    });
  }
}
