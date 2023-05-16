import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';
import '../domain/Token.dart';
import '../domain/User.dart';
import 'screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unilink2023/domain/cacheFactory.dart' as cache;

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
    "Modify Attributes",
    "Change Password",
    "Remove Account",
    "Chat",
    "Settings"
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
        NewsFeedPage1(), //futuramente as news
        SearchUsersPage(user: _currentUser),
        ListUsersPage(user: _currentUser),
        ModifyAttributesPage(
          user: _currentUser,
          onUserUpdate: (updatedUser) {
            setState(() {
              _currentUser = updatedUser;
            });
          },
        ),
        ChangePasswordPage(user: _currentUser),
        RemoveAccountPage(user: _currentUser),
        ChatPage(),
        SettingsPage(),
        Placeholder(), //estudante
        Placeholder(), //professor
        Placeholder(), //diretor
      ];

  Future<Uint8List?> downloadData() async {
    try {
      return FirebaseStorage.instance
          .ref('ProfilePictures/' + _currentUser.username)
          .getData();
    } catch (e) {
      print(e);
    }
  }

  Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();

    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    final fileBytes = await pickedFile!.readAsBytes();

    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('ProfilePictures/' + _currentUser.username);

    UploadTask uploadTask = storageReference.putData(fileBytes);

    String url = await storageReference.getDownloadURL();
  }

  Widget picture(BuildContext context) {
    return FutureBuilder<Uint8List?>(
        future: profilePic,
        builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
          if (snapshot.hasData) {
            return Image.memory(snapshot.data!);
          } else if (snapshot.hasError) {
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
          Positioned(
              bottom: 1,
              right: 1,
              child: Container(
                height: 25,
                width: 25,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: InkWell(
                  onTap: () async {
                    try {
                      await getImage(true);
                      profilePic = downloadData();
                      setState(() {});
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Icon(
                    Icons.add_a_photo,
                    size: 15.0,
                    color: Color(0xFF404040),
                  ),
                ),
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color roleColor = _currentUser.getRoleColor(widget.user.role);
    bool _isExpanded = false;
    List<bool> _isExpandedExpasionTile = [false, false];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 8, 52, 88), //roleColor,
        title: Text(
          _title[_selectedIndex],
          style: TextStyle(
              color: Colors
                  .white // roleColor == Colors.yellow ? Colors.black : Colors.white,
              ),
        ),
        centerTitle: true,
        actions: [
          Tooltip(
            message: 'Quick Logout',
            child: IconButton(
              icon: Icon(Icons.logout),
              color: roleColor == Colors.yellow ? Colors.black : Colors.white,
              onPressed: () async {
                final token = await cache.getValue('users', 'token');
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HomePage(
                      key: ValueKey(_currentUser),
                      user: _currentUser,
                      roleColor: _currentUser.getRoleColor(_currentUser.role),
                    ),
                  ),
                );
                _isExpanded = !_isExpanded; // replace with your screen
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
                        Row(
                          children: [
                            Text(
                              ' ${widget.user.displayName} ',
                              style: TextStyle(
                                color: Colors.white,
                                /*roleColor == Colors.yellow
                                    ? Colors.black
                                    : Colors.white,*/
                                fontSize: 18,
                              ),
                            ),
                            Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_down_outlined
                                  : Icons.keyboard_arrow_up_outlined,
                              color: Colors.white,
                            ),
                          ],
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
                        ),
                      ]),
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
                    title: Text('Estudante'),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 8;
                      });
                      Navigator.pop(context);
                    },
                  )
                : Container(),
            widget.user.role == 'PROF' || widget.user.role == 'SU'
                ? ListTile(
                    leading: Icon(Icons.newspaper),
                    title: Text('Prof'),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 9;
                      });
                      Navigator.pop(context);
                    },
                  )
                : Container(),
            widget.user.role == 'DIRECTOR' || widget.user.role == 'SU'
                ? ListTile(
                    leading: Icon(Icons.newspaper),
                    title: Text('Diretor'),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 10;
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
            SizedBox(height: 200),
            Divider(
              // Adjusts the divider's vertical extent. The actual divider line is in the middle of the extent.
              thickness: 1, // Adjusts the divider's thickness.
              color: kBackgroundColor, // Adjusts the divider's color.
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings',
                  style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                setState(() {
                  _selectedIndex = 7;
                });
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.logout_sharp),
              title:
                  Text('Logout', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () async {
                final token = await cache.getValue('users', 'token');
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
    final url = "https://unilink23.oa.r.appspot.com/rest/logout/";
    final tokenID = await cache.getValue('users', 'token');
    final storedUsername = await cache.getValue('users', 'username');
    Token token = new Token(tokenID: tokenID, username: storedUsername);

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${json.encode(token.toJson())}'
      },
    );

    if (response.statusCode == 200) {
      // Clear token from cache
      cache.removeLoginCache();

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
