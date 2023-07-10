import 'dart:async';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:unilink2023/constants.dart';
import 'package:unilink2023/data/cache_factory_provider.dart';
import 'package:unilink2023/features/chat/domain/Group.dart';
import 'package:unilink2023/domain/Token.dart';
import 'package:unilink2023/features/userManagement/domain/User.dart';
import 'package:unilink2023/features/chat/presentation/chat_msg_page.dart';
import 'package:unilink2023/widgets/LineTextField.dart';

import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:unilink2023/features/navigation/not_logged_in_page.dart';

import 'package:provider/provider.dart';
import 'package:unilink2023/domain/ThemeNotifier.dart';
import '../domain/Group.dart';
import '../domain/Message.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class ChatPage extends StatefulWidget {
  final User user;
  String? selectedGroup;

  ChatPage({required this.user, this.selectedGroup});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late Group? _selectedGroup = null;
  final TextEditingController searchController = TextEditingController();
  List<Group> allGroups = [];
  List<Group> filteredGroups = [];
  Map<String, Message> firstMessageOfGroups = {};
  bool isKeyboardOpen = false;

  @override
  void initState() {
    super.initState();
    if (mounted) listenForGroups();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    setState(() {
      isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom == 0.0;
    });
  }

  void dispose() {
    if (mounted) super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
  }

  String formatDateInMillis(int? timeInMillis) {
    var date = DateTime.fromMillisecondsSinceEpoch(timeInMillis!);
    var formatter = DateFormat('d/M/y');
    return formatter.format(date);
  }

  String formatTimeInMillis(int timeInMillis) {
    var date = DateTime.fromMillisecondsSinceEpoch(timeInMillis);
    var formatter = DateFormat('HH:mm');
    return formatter.format(date);
  }

  void listenForGroups() async {
    List<Group> groups = await cacheFactory.getGroups();

    groups.forEach((element) {
      setState(() {
        allGroups.add(element);
        filteredGroups.add(element);
      });
    });

    DatabaseReference chatRef = FirebaseDatabase.instance
        .ref()
        .child('chat')
        .child(widget.user.username)
        .child('Groups');
    DatabaseReference groupsRef =
        FirebaseDatabase.instance.ref().child('groups');
    DatabaseReference membersRef =
        FirebaseDatabase.instance.ref().child('members');
    DatabaseReference messagesRef =
        FirebaseDatabase.instance.ref().child('messages');

    // Listen for initial data and subsequent child additions
    chatRef.onChildAdded.listen((event) async {
      String groupId = event.snapshot.key as String;

      messagesRef
          .child(groupId)
          .orderByKey()
          .limitToLast(1)
          .onChildAdded
          .listen((event) async {
        if (mounted)
          setState(() {
            firstMessageOfGroups[groupId] =
                Message.fromSnapshot(event.snapshot);
          });
      });

      // Fetch group details from groupsRef
      DatabaseEvent groupSnapshot = await groupsRef.child(groupId).once();
      Map<dynamic, dynamic>? groupData =
          await groupSnapshot.snapshot.value as Map<dynamic, dynamic>?;

      DatabaseEvent memberSnapshot = await membersRef.child(groupId).once();
      Map<dynamic, dynamic>? memberData =
          await memberSnapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (groupData != null && memberData != null) {
        String displayName = groupData['DisplayName'];
        String description = groupData['description'];
        int numberOfMembers = memberData.length;
        Group group = Group(
          id: groupId,
          DisplayName: displayName,
          description: description,
          numberOfMembers: numberOfMembers,
        );

        bool exists = groups.any((element) => element.id == group.id);
        if (!exists) {
          groups.add(group);
          cacheFactory.addGroup(group);
          setState(() {
            allGroups.add(group);
            filteredGroups.add(group);
          });
        }

        setState(() {});
      }

      if (widget.selectedGroup != null && widget.selectedGroup != "")
        setState(() {
          print("SELECTED GROUP: " + widget.selectedGroup!);
          var matchingGroup =
              allGroups.where((e) => e.id == widget.selectedGroup);
          if (matchingGroup.isNotEmpty) {
            _selectedGroup = matchingGroup.first;
          }
        });
    });

    // Listen for child removal using onChildRemoved
    chatRef.onChildRemoved.listen((event) {
      String groupId = event.snapshot.key as String;

      setState(() {
        groups.removeWhere((group) => group.id == groupId);
      });
    });

    setState(() {});
  }

  Future<Uint8List?> downloadGroupPictureData(String groupId) async {
    return FirebaseStorage.instance
        .ref('GroupPictures/' + groupId)
        .getData()
        .onError((error, stackTrace) => null);
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

  void filterGroups(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredGroups = allGroups; // Reset to all groups if query is empty
      } else {
        filteredGroups = allGroups.where((group) {
          final displayName = group.DisplayName.toLowerCase();
          final description = group.description.toLowerCase();
          final searchLower = query.toLowerCase();

          return query.isNotEmpty &&
              (isMatch(displayName, searchLower) ||
                  isMatch(description, searchLower) ||
                  displayName.contains(searchLower) ||
                  description.contains(searchLower));
        }).toList();
      }
    });
  }

  /*Levenshtein algorithm*/
  bool isMatch(String text, String query) {
    if (text == query) {
      return true; // Exact match
    }

    if ((text.length - query.length).abs() > 2) {
      return false; // Length difference exceeds tolerance
    }

    for (int i = 0; i < text.length; i++) {
      int differences = levenshteinDistance(text.substring(i), query);
      if (differences <= 2) {
        return true; // Match found within tolerance
      }
    }

    return false; // No match found
  }

  int levenshteinDistance(String text, String query) {
    if (text.isEmpty) {
      return query.length;
    }
    if (query.isEmpty) {
      return text.length;
    }

    List<int> previousRow = List<int>.filled(query.length + 1, 0);
    List<int> currentRow = List<int>.filled(query.length + 1, 0);

    for (int i = 0; i <= query.length; i++) {
      previousRow[i] = i;
    }

    for (int i = 0; i < text.length; i++) {
      currentRow[0] = i + 1;

      for (int j = 0; j < query.length; j++) {
        int insertions = previousRow[j + 1] + 1;
        int deletions = currentRow[j] + 1;
        int substitutions = previousRow[j] + (text[i] != query[j] ? 1 : 0);

        currentRow[j + 1] = min(insertions, min(deletions, substitutions));
      }

      List<int> tempRow = previousRow;
      previousRow = currentRow;
      currentRow = tempRow;
    }

    return previousRow[query.length];
  }

  /*Levenshtein algorithm*/

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildWebLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: _buildLeftWidget(context),
          ),
          if (_selectedGroup != null && _selectedGroup != "") ...[
            Container(
              width: 1,
              color: Colors.grey,
            ),
            Expanded(
              flex: 3,
              child: GroupMessagesPage(
                key: ValueKey(_selectedGroup!.id),
                groupId: _selectedGroup!.id,
                user: widget.user,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeftWidget(BuildContext context) {
    List<Group> groups = filteredGroups;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: kWhiteBackgroundColor,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        //roleColor,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(
          "Groups",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: (query) {
                    filterGroups(query);
                  },
                  decoration: InputDecoration(
                    labelText: 'Search',
                    labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).secondaryHeaderColor),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: groups.length == 0
                    ? noGroupWidget()
                    : ListView(
                        padding: EdgeInsets.only(top: 10, bottom: 80),
                        children: groups.map((group) {
                          Message? firstMessage =
                              firstMessageOfGroups[group.id];
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedGroup = group;
                                    downloadGroupPictureData(group.id);
                                  });
                                },
                                child: Container(
                                  color: _selectedGroup == group
                                      ? Theme.of(context).primaryColorDark
                                      : Theme.of(context)
                                          .scaffoldBackgroundColor,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 8),
                                    child: ListTile(
                                      leading: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          child:
                                              groupPicture(context, group.id)),
                                      title: Text(
                                        '${group.DisplayName}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            formatTimeInMillis(
                                                firstMessage != null
                                                    ? firstMessage.timestamp
                                                    : 0),
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              //Maybe have icon?
                                              //Icon(Icons.message, size: 20),
                                              //SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  '${firstMessage != null ? firstMessage.displayName : ''}: ${firstMessage != null ? firstMessage.text : ''}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                            ],
                                          ),
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
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialogWeb(context);
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

  Widget _buildMobileLayout(BuildContext context) {
    List<Group> groups = filteredGroups;
    if (_selectedGroup != null && _selectedGroup != "") {
      Future.delayed(Duration(milliseconds: 200), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => GroupMessagesPage(
              key: ValueKey(_selectedGroup!.id),
              groupId: _selectedGroup!.id,
              user: widget.user,
            ),
          ),
        );
      });
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Groups",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (query) {
                filterGroups(query);
              },
              decoration: InputDecoration(
                labelText: 'Search',
                labelStyle: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Theme.of(context).secondaryHeaderColor),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: groups.length == 0
                ? noGroupWidget()
                : ListView(
                    padding: EdgeInsets.only(top: 10, bottom: 80),
                    children: groups.map((group) {
                      Message? firstMessage = firstMessageOfGroups[group.id];
                      return Column(
                        children: [
                          GestureDetector(
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
                            child: Container(
                              color: _selectedGroup == group
                                  ? Theme.of(context).primaryColorDark
                                  : Theme.of(context).scaffoldBackgroundColor,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 8),
                                child: ListTile(
                                  leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(200),
                                      child: groupPicture(context, group.id)),
                                  title: Text(
                                    '${group.DisplayName}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        formatTimeInMillis(
                                            firstMessage != null
                                                ? firstMessage.timestamp
                                                : 0),
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          //Maybe have icon?
                                          //Icon(Icons.message, size: 20),
                                          //SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              '${firstMessage != null ? firstMessage.displayName : ''}: ${firstMessage != null ? firstMessage.text : ''}',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                        ],
                                      ),
                                      Divider(
                                        color:
                                            Provider.of<ThemeNotifier>(context)
                                                        .currentTheme ==
                                                    kDarkTheme
                                                ? Colors.white60
                                                : Theme.of(context)
                                                    .primaryColor,
                                        thickness: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialogMobile(context);
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

  popUpDialogWeb(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                "Create a group",
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LineTextField(
                    icon: Icons.title,
                    lableText: 'Group name',
                    controller: groupNameController,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  LineTextField(
                    icon: Icons.description,
                    lableText: 'Group Description',
                    controller: descriptionController,
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    {
                      createGroup(context, groupNameController.text,
                          descriptionController.text, _showErrorSnackbar);
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

  popUpDialogMobile(BuildContext context) {
    TextEditingController groupNameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Style.darkBlue,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        return StatefulBuilder(builder: ((context, setState) {
          return SingleChildScrollView(
            child: Container(
              height: mediaQuery.size.height * 0.9,
              padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Create a group",
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: 20),
                      LineTextField(
                        icon: Icons.title,
                        lableText: 'Group name',
                        controller: groupNameController,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      LineTextField(
                        icon: Icons.description,
                        lableText: 'Group Description',
                        controller: descriptionController,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              createGroup(
                                context,
                                groupNameController.text,
                                descriptionController.text,
                                _showErrorSnackbar,
                              );
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                            ),
                            child: const Text("CREATE"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context); // closes the modal
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }));
      },
    );
  }

  Widget groupPicture(BuildContext context, String groupId) {
    Stream<Uint8List?> groupPicStream = FirebaseStorage.instance
        .ref('GroupPictures/' + groupId)
        .getData()
        .asStream()
        .handleError((error, stackTrace) => null);

    return StreamBuilder<Uint8List?>(
        stream: groupPicStream,
        builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
          if (snapshot.hasData) {
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
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
                                Navigator.of(dialogContext).pop();
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
              Icons.group,
              size: 80,
            );
          }
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
                  if (kIsWeb) {
                    popUpDialogWeb(context);
                  } else {
                    popUpDialogMobile(context);
                  }
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
              "You've not joined any groups, tap on the add icon to create a group or also search from top search bar.",
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
        'adminID': storedUsername
      }),
    );

    // if (response.statusCode == 200) {
    //   showErrorSnackbar('Created a group successfully!', false);
    //   //if (!kIsWeb) _firebaseMessaging.subscribeToTopic(groupName);
    // } else {
    //   showErrorSnackbar('Failed to create a group: ${response.body}', true);
    // }
    groupNameController.clear();
    descriptionController.clear();
  }
}
