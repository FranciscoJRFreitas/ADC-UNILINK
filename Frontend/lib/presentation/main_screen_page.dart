import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unilink2023/presentation/contacts_page.dart';
import '../constants.dart';
import '../data/cache_factory_provider.dart';
import '../domain/Token.dart';
import '../domain/User.dart';
import 'screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:photo_view/photo_view.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;

class MainScreen extends StatefulWidget {
  final User user;

  MainScreen({required this.user});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<String> _title = [
    "News",
    "Search",
    "List",
    "User Profile",
    "Change Password",
    "Remove Account",
    "Chat",
    "Contacts",
    "Settings",
    "Student",
    "Teacher",
    "Director",
  ];
  late User _currentUser;
  late Future<Uint8List?> profilePic;

  DocumentReference picsRef =
      FirebaseFirestore.instance.collection('ProfilePictures').doc();

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    profilePic = downloadData();
  }

  List<Widget> _widgetOptions() => [
        NewsFeedPage(), //futuramente as news
        SearchUsersPage(user: _currentUser),
        ListUsersPage(user: _currentUser),
        /*ModifyAttributesPage(
          user: _currentUser,
          onUserUpdate: (updatedUser) {
            setState(() {
              _currentUser = updatedUser;
            });
          },
        ),*/
        HomePage(user: _currentUser),
        ChangePasswordPage(user: _currentUser),
        RemoveAccountPage(user: _currentUser),
        ChatPage(),
        ContactsPage(),
        SettingsPage(),
        Placeholder(), //estudante
        Placeholder(), //professor
        Placeholder(), //diretor
      ];

  Future<Uint8List?> downloadData() async {
    return FirebaseStorage.instance
        .ref('ProfilePictures/' + _currentUser.username)
        .getData()
        .onError((error, stackTrace) => null);
  }

  Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();

    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    final fileBytes = await pickedFile!.readAsBytes();

    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('ProfilePictures/' + _currentUser.username);

    await storageReference.putData(fileBytes);
    setState(() {});
  }

  Widget picture(BuildContext context) {
    return FutureBuilder<Uint8List?>(
        future: profilePic,
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

  @override
  Widget build(BuildContext context) {
    Color roleColor = _currentUser.getRoleColor(widget.user.role);
    bool _isExpanded = false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 8, 52, 88), //roleColor,
        title: Text(
          _title[_selectedIndex],
          style: Theme.of(context).textTheme.bodyLarge,
          selectionColor: Colors.white,
        ),
        centerTitle: true,
        actions: [
          Tooltip(
            message: 'Quick Logout',
            child: IconButton(
              icon: Icon(Icons.logout),
              color: roleColor == Colors.yellow ? Colors.black : Colors.white,
              onPressed: () async {
                final token = await cacheFactory.get('users', 'token');
                if (token != null) {
                  await logout(
                      context, widget.user.username, _showErrorSnackbar);
                } else {
                  _showErrorSnackbar('Error logging out', true);
                }
              },
            ),
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: Color.fromARGB(255, 8, 52, 88),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.pop(context); // replace with your screen
              },
              child: DrawerHeader(
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 8, 52, 88) //roleColor,
                    ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(children: [
                      profilePicture(context),
                      SizedBox(
                        width: 10,
                      ),
                      Column(children: [
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          processDisplayName(widget.user.displayName),
                          style: widget.user.displayName.length < 5
                              ? Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: Colors.white)
                              : widget.user.displayName.length < 10
                                  ? Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: Colors.white)
                                  : Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          //trocar por numero de aluno
                          'Role: ${widget.user.role}',
                          style: TextStyle(
                            color: Colors.white60,
                            //roleColor == Colors.yellow ? Colors.black: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ]),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_down_outlined
                            : Icons.keyboard_arrow_up_outlined,
                        color: Colors.white,
                      ),
                    ]),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ),
            widget.user.role == 'STUDENT' || widget.user.role == 'SU'
                ? ListTile(
                    leading: Icon(Icons.newspaper),
                    title: Text('Student'),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 9;
                      });
                      Navigator.pop(context);
                    },
                  )
                : Container(),
            widget.user.role == 'PROF' || widget.user.role == 'SU'
                ? ListTile(
                    leading: Icon(Icons.newspaper),
                    title: Text('Professor'),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 10;
                      });
                      Navigator.pop(context);
                    },
                  )
                : Container(),
            widget.user.role == 'DIRECTOR' || widget.user.role == 'SU'
                ? ListTile(
                    leading: Icon(Icons.newspaper),
                    title: Text('Director'),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 11;
                      });
                      Navigator.pop(context);
                    },
                  )
                : Container(),
            ListTile(
              leading: Icon(Icons.newspaper),
              title: Text('News'),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ExpansionTile(
                leading: Icon(
                  Icons.group,
                ),
                title: Text('Community',
                    style: Theme.of(context).textTheme.bodyLarge),
                children: [
                  ListTile(
                    title: Text('Search Users',
                        style: Theme.of(context).textTheme.bodyLarge),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text('List Users',
                        style: Theme.of(context).textTheme.bodyLarge),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                      Navigator.pop(context);
                    },
                  )
                ]),

            ExpansionTile(
              leading: Icon(Icons.person),
              title:
                  Text('Profile', style: Theme.of(context).textTheme.bodyLarge),
              children: <Widget>[
                ListTile(
                  title: Text('Modify Attributes',
                      style: Theme.of(context).textTheme.bodyLarge),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 3;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Change Password',
                      style: Theme.of(context).textTheme.bodyLarge),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 4;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Remove Account',
                      style: Theme.of(context).textTheme.bodyLarge),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 5;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chat', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                setState(() {
                  _selectedIndex = 6;
                });
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 125),
            Divider(
              // Adjusts the divider's vertical extent. The actual divider line is in the middle of the extent.
              thickness: 1, // Adjusts the divider's thickness.
              color: kBackgroundColor, // Adjusts the divider's color.
            ),
            ListTile(
              leading: Icon(Icons.call),
              title: Text('Contacts',
                  style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                setState(() {
                  _selectedIndex = 7;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings',
                  style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                setState(() {
                  _selectedIndex = 8;
                });
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.logout_sharp),
              title:
                  Text('Logout', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () async {
                final token = await cacheFactory.get('users', 'token');
                if (token != null) {
                  await logout(
                      context, widget.user.username, _showErrorSnackbar);
                } else {
                  _showErrorSnackbar('Error logging out', true);
                }
              },
            ),
            // ... other Drawer items
          ],
        ),
      ),
      //body: _widgetOptions()[_selectedIndex],
      body: getSelectedWidget(),
    );
  }

  String processDisplayName(String displayName) {
    if (displayName.length < 20) return displayName;
    List<String> words = displayName.split(' ');
    String result = '';
    int currentLength = 0;
    if (words.length < 2) return displayName.substring(0, 17) + '...';

    for (String word in words) {
      if (currentLength + word.length > 20) {
        result += '\n';
        currentLength = 0;
      }

      result += word + ' ';
      currentLength += word.length + 1; // 1 for the space
    }

    return result.trimRight();
  }

  Widget getSelectedWidget() {
    var options = _widgetOptions();
    if (_selectedIndex < options.length) {
      return options[_selectedIndex];
    } else {
      // You can return some placeholder widget here when _selectedIndex is out of range
      return Text('Selected index out of range! ${options}');
    }
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

  Future<void> logout(
    BuildContext context,
    String username,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    final url = kBaseUrl + "rest/logout/";
    final tokenID = await cacheFactory.get('users', 'token');
    final storedUsername = await cacheFactory.get('users', 'username');
    Token token = new Token(tokenID: tokenID, username: storedUsername);

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${json.encode(token.toJson())}'
      },
    );

    if (response.statusCode == 200) {
      final FirebaseAuth.User? _currentUser =
          FirebaseAuth.FirebaseAuth.instance.currentUser;

      if (_currentUser != null) {
        DatabaseReference userRef = FirebaseDatabase.instance
            .ref()
            .child('chat')
            .child(username);
        DatabaseReference userGroupsRef = userRef.child('Groups');

        // Retrieve user's group IDs from the database
        DatabaseEvent userGroupsEvent = await userGroupsRef.once();

        DataSnapshot userGroupsSnapshot = userGroupsEvent.snapshot;

        // Unsubscribe from all the groups
        if (userGroupsSnapshot.value is Map<dynamic, dynamic>) {
          Map<dynamic, dynamic> userGroups =
              userGroupsSnapshot.value as Map<dynamic, dynamic>;
          for (String groupId in userGroups.keys) {
            await FirebaseMessaging.instance.unsubscribeFromTopic(groupId);
          }
        }
      }

      FirebaseAuth.FirebaseAuth.instance.signOut();
      cacheFactory.removeLoginCache();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WelcomePage()),
      );
      showErrorSnackbar('${response.body}', false);
    } else {
      showErrorSnackbar('${response.body}', true);
    }
  }
}
