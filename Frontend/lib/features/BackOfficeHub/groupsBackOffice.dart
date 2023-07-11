import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unilink2023/domain/Token.dart';

import '../../application/loadLocations.dart';
import '../../constants.dart';
import '../../data/cache_factory_provider.dart';
import '../../domain/ThemeNotifier.dart';
import '../../widgets/AutoCompleteDropdown.dart';
import '../../widgets/LineTextField.dart';
import '../chat/domain/Group.dart';
import '../navigation/main_screen_page.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class GroupPage extends StatefulWidget {
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  List<Group> groups = []; // Replace with your group list
  PlatformFile file = PlatformFile(name: "", size: 0);

  @override
  void initState() {
    super.initState();
    getGroups();
  }

  void getGroups() async {
    DatabaseReference groupsRef =
        FirebaseDatabase.instance.ref().child('groups');

    groupsRef.onChildAdded.listen((event1) {
      setState(() {
        Map<dynamic, dynamic> groupData =
        event1.snapshot.value as Map<dynamic, dynamic>;
        //print(groupData["DisplayName"]);
        DatabaseReference membersRef =
        FirebaseDatabase.instance.ref().child('members').child(
            groupData["DisplayName"]);

        membersRef.once().then((event2) {
          setState(() {
            Map<dynamic, dynamic>? membersData = event2.snapshot.value as Map<dynamic, dynamic>?;

            int numberOfMembers = membersData?.length ?? 0;

            //print(numberOfMembers);
            Group currentGroup = Group(
              id: event1.snapshot.key!,
              DisplayName: groupData["DisplayName"],
              description: groupData["description"],
              numberOfMembers: numberOfMembers,
            );
            groups.add(currentGroup);
            print(groups);
          });
          });
        });
      });
    groupsRef.onChildRemoved.listen((event) {
      String groupId = event.snapshot.key as String;

      setState(() {
        groups.removeWhere((group) => group.id == groupId);
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

  void createGroupsFromFile() async {
    final url = kBaseUrl + "rest/chat/create-multiple";
    final tokenID = await cacheFactory.get('users', 'token');
    final storedUsername = await cacheFactory.get('users', 'username');
    Token token = new Token(tokenID: tokenID, username: storedUsername);

    // Convert the file bytes to a string and parse it as JSON
    String fileContents = utf8.decode(file.bytes!);
    var fileJson = json.decode(fileContents);

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${json.encode(token.toJson())}',
      },
      body: jsonEncode(fileJson),
    );
    if (response.statusCode != 200) print("REQUEST ERROR");
  }

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      file = result.files.single;
    } else {
      print("picker canceled");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'Groups',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.group), text: "Group List"),
              Tab(icon: Icon(Icons.create), text: "Create Groups"),
            ],
          ),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: TabBarView(
          children: [
            buildGroupList(),
            Center(child: buildCreateGroup()),
          ],
        ),
      ),
    );
  }

  Widget buildCreateGroup() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,

              // button's fill color
              foregroundColor: Colors.white, // button's text color
              elevation: 2, // button's elevation in its pressed state
            ),
            icon: Icon(Icons.add),
            label: Text('Create Group'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  TextEditingController groupName = TextEditingController();
                  TextEditingController description = TextEditingController();
                  TextEditingController adminId = TextEditingController();

                  return AlertDialog(
                    title: Text('Create Group', style: TextStyle(fontSize: 30)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LineTextField(
                          controller: groupName,
                          title: 'Group Name',
                        ),
                        SizedBox(height: 10),
                        LineTextField(
                          controller: description,
                          title: 'Description',
                        ),
                        SizedBox(height: 10),
                        LineTextField(
                          controller: adminId,
                          title: 'Admin ID',
                          ),
                      ],
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        child: Text('Create'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          createGroup(context, groupName.text, description.text, adminId.text,
                              _showErrorSnackbar);
                        },
                      ),
                      ElevatedButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Theme.of(context).primaryColor, // button's fill color
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            icon: Icon(Icons.add),
            label: Text('Create Groups from a file'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Create Groups', style: TextStyle(fontSize: 30)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          child: Text('Pick a file'),
                          onPressed: () {
                            pickFile();
                          },
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        child: Text('Create'),
                        onPressed: () {
                          createGroupsFromFile();
                          Navigator.of(context).pop();
                          // Process your file here
                        },
                      ),
                      ElevatedButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildGroupList() {
    if (groups.isEmpty) {
      return Center(
        child: Text('No groups available.'),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          Group group = groups[index];
          return Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                // Handle group onTap
              },
              child: Stack(
                children: <Widget>[
                  Text(
                    '${group.DisplayName}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    color: Provider.of<ThemeNotifier>(context).currentTheme == kDarkTheme
                        ? Colors.white60
                        : Theme.of(context).primaryColor,
                    thickness: 1,
                  ),
                  Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      child: ListTile(
                        title: Text(
                          group.DisplayName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(group.description),
                            Text('Number of Members: ${group.numberOfMembers}'),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (kIsWeb)
                                      popUpDialogWeb(context, group.DisplayName);
                                    else
                                      popUpDialogMobile(context, group.DisplayName);
                                  },
                                  child: Text('Invite'),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    _showKickDialog(context, group.DisplayName);
                                  },
                                  child: Text('Kick'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 10,
                    child: Container(
                      width: 24,
                      height: 24,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.delete, color: Colors.blue),
                        onPressed: () {
                          _showDeleteConfirmation(context, group.DisplayName);
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
        },
      ),
    );
  }


  void _showDeleteConfirmation(BuildContext context, String groupId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Group', style: TextStyle(fontSize: 30)),
          content: Text('Are you sure you want to delete this group?', style: Theme.of(context).textTheme.bodyLarge),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Delete'),
              onPressed: () {
                deleteGroup(context, groupId, _showErrorSnackbar);
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  popUpDialogWeb(BuildContext context, String groupId) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AutocompleteDropdown(groupId: groupId, showError: _showErrorSnackbar);
          }));
        });
  }

  void popUpDialogMobile(BuildContext context, String groupId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Style.darkBlue,
      builder: (context) => StatefulBuilder(
        builder: ((context, setState) {
          return AutocompleteDropdown(groupId: groupId, showError: _showErrorSnackbar);
        }),
      ),
    );
  }


  void _showInviteDialog(BuildContext context, String groupId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController userId = TextEditingController();

        return AlertDialog(
          title: Text('Invite User', style: TextStyle(fontSize: 30)),
          content: LineTextField(
            controller: userId,
            title: 'User ID',
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Invite'),
              onPressed: () {
                inviteGroup(context, groupId, userId.text, _showErrorSnackbar);
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showKickDialog(BuildContext context, String groupId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController userId = TextEditingController();

        return AlertDialog(
          title: Text('Kick User', style: TextStyle(fontSize: 30)),
          content: LineTextField(
            controller: userId,
            title: 'User ID',
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Kick'),
              onPressed: () {
                kickGroup(context, groupId, userId.text, _showErrorSnackbar);
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> createGroup(
    BuildContext context,
    String groupName,
    String description,
    String adminId,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    if (groupName.isEmpty) {
      showErrorSnackbar("Please provide a name to create a group!", true);
      return;
    }

    final url = kBaseUrl + "rest/chat/create";
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
        'adminID': adminId
      }),
    );

    if (response.statusCode != 200) {
      showErrorSnackbar('Failed to create a group: ${response.body}', true);
    }

    // if (response.statusCode == 200) {
    //   showErrorSnackbar('Created a group successfully!', false);
    //   //if (!kIsWeb) _firebaseMessaging.subscribeToTopic(groupName);
    // } else {
    //   showErrorSnackbar('Failed to create a group: ${response.body}', true);
    // }
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

  Future<void> kickGroup(
    BuildContext context,
    String groupId,
    String userId,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    final url =
        kBaseUrl + "rest/chat/leave?groupId=" + groupId + "&userId=" + userId;
    final tokenID = await cacheFactory.get('users', 'token');
    final storedUsername = await cacheFactory.get('users', 'username');
    Token token = new Token(tokenID: tokenID, username: storedUsername);

    final response = await http.post(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${json.encode(token.toJson())}'
    });

    if (response.statusCode == 200) {
      showErrorSnackbar('kicked ${userId}!', false);
    } else {
      showErrorSnackbar('Error kicking from group!', true);
    }
  }

  Future<void> deleteGroup(
    BuildContext context,
    String groupId,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    final url = kBaseUrl + "rest/chat/delete/" + groupId;
    final tokenID = await cacheFactory.get('users', 'token');
    final storedUsername = await cacheFactory.get('users', 'username');
    Token token = new Token(tokenID: tokenID, username: storedUsername);

    final response = await http.delete(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${json.encode(token.toJson())}'
    });

    if (response.statusCode == 200) {
      showErrorSnackbar('Deleted ${groupId}!', false);
    } else {
      showErrorSnackbar('Error Deleting group ! : ${response.body}', true);
    }
  }
}
