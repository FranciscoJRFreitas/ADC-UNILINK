import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import '../constants.dart';
import 'package:http/http.dart' as http;
import 'package:unilink2023/presentation/chat_page.dart';

import '../data/cache_factory_provider.dart';
import '../domain/Token.dart';
import '../widgets/my_text_field.dart';

class ChatInfoPage extends StatefulWidget {
  final String groupId;
  final String username;
  ChatInfoPage({required this.groupId, required this.username});

  @override
  State<ChatInfoPage> createState() => _ChatInfoPageState();
}

class _ChatInfoPageState extends State<ChatInfoPage> {
  final TextEditingController userNameController = TextEditingController();
  late Future<Uint8List?> groupPic;
  late List<MembersData> members = [];
  late DatabaseReference membersRef;
  late DatabaseReference chatsRef;
  late String desc = "";
  late bool isAdmin = false;
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

    chatsRef =
        FirebaseDatabase.instance.ref().child('groups').child(widget.groupId);
    chatsRef.once().then((chatSnapshot) {
      Map<dynamic, dynamic> chatsData =
          chatSnapshot.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        desc = chatsData["description"];
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
                                  shape: BoxShape
                                      .circle, // use circle if the icon is circular
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
              child: Image.memory(snapshot.data!),
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
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(widget.groupId),
          backgroundColor: Color.fromARGB(255, 8, 52, 88),
        ),
        body: SingleChildScrollView(
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
                // Adjusts the divider's vertical extent. The actual divider line is in the middle of the extent.
                thickness: 1, // Adjusts the divider's thickness.
                color: Style.lightBlue,
              ),
              SizedBox(height: 10),
              Text(
                desc,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 5),
              Divider(
                // Adjusts the divider's vertical extent. The actual divider line is in the middle of the extent.
                thickness: 1, // Adjusts the divider's thickness.
                color: Style.lightBlue,
              ),
              SizedBox(height: 20),
              Row(children: [
                Text(
                  '${members.length} Participants',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: SizedBox(
                        height: 30,
                        width: 30,
                        child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                                onTap: () {
                                  leavePopUpDialog(context);
                                },
                                child: Icon(
                                  Icons.group_remove,
                                  color: Colors.white,
                                  size: 20,
                                ))))),
                if (isAdmin)
                  Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: SizedBox(
                          height: 30,
                          width: 30,
                          child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                  onTap: () {
                                    popUpDialog(context);
                                  },
                                  child: Icon(
                                    Icons.group_add,
                                    color: Colors.white,
                                    size: 20,
                                  )))))
              ]),
              SizedBox(height: 20),
              //...more info items...
              Container(
                  padding: EdgeInsets.only(top: 10, bottom: 80),
                  child: SizedBox(
                      height: 1000,
                      child: ListView.builder(
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            MembersData member = members[index];
                            return GestureDetector(
                              onTap: () {},
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 5,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 8),
                                  child: ListTile(
                                    leading: picture(context, member.username),
                                    title: Text(
                                      '${member.dispName}${member.username == widget.username ? ' (You)' : ''}${member.isAdmin ? ' (Admin)' : ''}',
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
                                            Icon(Icons.person, size: 20),
                                            SizedBox(width: 5),
                                            Text(
                                                'Username: ${member.username}'),
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

                            return null;
                          })))
            ],
          ),
        ));
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
                "Send an Invite",
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyTextField(
                    small: false,
                    hintText: 'Username',
                    inputType: TextInputType.text,
                    controller: userNameController,
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    userNameController.clear();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: const Text("CANCEL"),
                ),
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
                )
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
          title: const Text(
            "Leave Group",
            textAlign: TextAlign.left,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Are you sure you want to leave this group?",
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Call the function to leave the group here
                leaveGroup(context, widget.groupId, widget.username,
                    _showErrorSnackbar);

                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              child: const Text("LEAVE"),
            )
          ],
        );
      },
    );
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
                                  shape: BoxShape
                                      .circle, // use circle if the icon is circular
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
              child: Image.memory(snapshot.data!),
            );
          } else {
            return const Icon(
              Icons.account_circle,
              size: 50,
            );
          }
          return const CircularProgressIndicator();
        });
  }
}

Future<void> inviteGroup(
  BuildContext context,
  String groupId,
  String userId,
  void Function(String, bool) showErrorSnackbar,
) async {
  final url = "https://unilink23.oa.r.appspot.com/rest/chat/invite?groupId=" +
      groupId +
      "&userId=" +
      userId;
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

Future<void> leaveGroup(
  BuildContext context,
  String groupId,
  String userId,
  void Function(String, bool) showErrorSnackbar,
) async {
  final url = "https://unilink23.oa.r.appspot.com/rest/chat/leave?groupId=" +
      groupId +
      "&userId=" +
      userId;
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
  final bool isAdmin;
  MembersData(
      {required this.username, required this.dispName, required this.isAdmin});
}