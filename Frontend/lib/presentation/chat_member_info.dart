import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../data/cache_factory_provider.dart';

import '../domain/Token.dart';

import 'package:http/http.dart' as http;

import '../domain/UserNotifier.dart';

class chatMemberInfo extends StatefulWidget {
  final String username;
  final String sessionUsername;
  final String displayName;
  final String groupId;
  final bool isAdmin;
  const chatMemberInfo(
      {required this.username,
      required this.displayName,
      required this.isAdmin,
      required this.sessionUsername,
      required this.groupId});

  @override
  _chatMemberInfoPageState createState() => _chatMemberInfoPageState();
}

class _chatMemberInfoPageState extends State<chatMemberInfo> {
  DocumentReference picsRef =
      FirebaseFirestore.instance.collection('ProfilePictures').doc();

  @override
  void initState() {
    super.initState();
  }

  Widget picture(BuildContext context) {
    final photoProvider = Provider.of<UserNotifier>(context);
    final Future<Uint8List?>? userPhoto = photoProvider.currentPic;

    return FutureBuilder<Uint8List?>(
        future: userPhoto,
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
              Icons.account_circle,
              size: 80,
            );
          }
          return const CircularProgressIndicator();
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
                  child: picture(context)),
            ),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
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
                    widget.displayName,
                    style: Theme.of(context).textTheme.headline6,
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
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
            SizedBox(height: 20),
            InfoItem(
              title: 'Username',
              value: widget.username,
              icon: Icons.alternate_email,
            ),
            SizedBox(height: 20),
            if (widget.isAdmin) ...[
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            title: Text('Confirmation'),
                            content: Text(
                                'Are you sure you want to kick ${widget.username}?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  kickGroup(
                                      context,
                                      widget.sessionUsername,
                                      widget.groupId,
                                      widget.username,
                                      _showErrorSnackbar);
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                child: Text('Yes'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Text('No'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text('Kick'),
                  ),
                  SizedBox(width: 1),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            title: Text('Confirmation'),
                            content: Text(
                                'Are you sure you want to demote ${widget.username}?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  final DatabaseReference membersRef =
                                      FirebaseDatabase.instance
                                          .ref()
                                          .child('members')
                                          .child(widget.groupId);
                                  membersRef.child(widget.username).set(false);
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Text('Yes'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Text('No'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text('Demote'),
                  ),
                  SizedBox(width: 1),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            title: Text('Confirmation'),
                            content: Text(
                                'Are you sure you want to promote ${widget.username}?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  final DatabaseReference membersRef =
                                      FirebaseDatabase.instance
                                          .ref()
                                          .child('members')
                                          .child(widget.groupId);
                                  membersRef.child(widget.username).set(true);
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Text('Yes'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Text('No'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text('Promote'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> kickGroup(
    BuildContext context,
    String sessionUserId,
    String groupId,
    String userId,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    final url = "https://unilink23.oa.r.appspot.com/rest/chat/leave?groupId=" +
        groupId +
        "&userId=" +
        userId;
    final tokenID = await cacheFactory.get('users', 'token');
    Token token = new Token(tokenID: tokenID, username: sessionUserId);

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
}

class InfoItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  InfoItem({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).primaryIconTheme.color,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
