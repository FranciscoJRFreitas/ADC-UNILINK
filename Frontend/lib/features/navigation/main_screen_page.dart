import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilink2023/features/BackOfficeHub/BackOfficePage.dart';
import 'package:unilink2023/features/anomaly/anomalypage.dart';
import 'package:unilink2023/features/calendar/presentation/my_events_page.dart';
import 'package:unilink2023/features/chat/presentation/chat_page.dart';
import 'package:unilink2023/features/contacts/presentation/contacts_page.dart';
import 'package:unilink2023/features/listUsers/list_users_page.dart';
import 'package:unilink2023/features/map/MapPage.dart';
import 'package:unilink2023/features/navigation/not_logged_in_page.dart';
import 'package:unilink2023/features/news/presentation/news_page.dart';
import 'package:unilink2023/features/searchUser/search_users_page.dart';
import 'package:unilink2023/features/settings/settings_page.dart';
import 'package:unilink2023/features/userManagement/presentation/userData/home_page.dart';
import 'package:unilink2023/features/userManagement/presentation/userAuth/change_password_page.dart';
import 'package:unilink2023/features/userManagement/presentation/userAuth/remove_account_page.dart';
import '../../constants.dart';
import '../../data/cache_factory_provider.dart';
import '../../domain/UserNotifier.dart';
import '../../domain/Token.dart';
import '../userManagement/domain/User.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:photo_view/photo_view.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import '../calendar/presentation/calendar_page.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatefulWidget {
  final int? index;
  final DateTime? date;
  final String? selectedGroup;
  final String? location;

  MainScreen({this.index, this.date, this.location, this.selectedGroup});

  @override
  _MainScreenState createState() =>
      _MainScreenState(index, date, location, selectedGroup);
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  int _selectedIndex = 0;
  int _bottomNavigationIndex = 0;
  DateTime scheduleDate = DateTime.now();
  String markerLocation = "";
  String _selectedGroup = "";
  List<String> _title = [
    "News",
    "Search",
    "List",
    "Profile",
    "Change Password",
    "Remove Account",
    "Chat",
    "Contacts",
    "Settings",
    "Student",
    "Campus",
    "Anomaly",
    "BackOffice Hub",
    "Teacher",
    "Director",
    "Events",
  ];
  late List<double> scales = List.filled(_widgetOptions().length, 1);
  late User _currentUser;
  late bool isFirst = true;

  DocumentReference picsRef =
      FirebaseFirestore.instance.collection('ProfilePictures').doc();

  _MainScreenState(
      int? index, DateTime? date, String? location, String? selectedGroup) {
    if (index != null) {
      _selectedIndex = index;
      _bottomNavigationIndex = index == 10
          ? 2
          : index == 6
              ? 3
              : index == 3
                  ? 4
                  : index == 15
                      ? 1
                      : 0;
    }
    if (date != null) scheduleDate = date;
    if (location != null) markerLocation = location;
    if (selectedGroup != null) _selectedGroup = selectedGroup;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> _widgetOptions() => [
        NewsFeedPage(), //0
        SearchUsersPage(user: _currentUser), //1
        ListUsersPage(user: _currentUser), //2
        HomePage(), //3
        ChangePasswordPage(), //4
        RemoveAccountPage(), //5
        ChatPage(
          user: _currentUser,
          selectedGroup: _selectedGroup,
        ), //6
        ContactsPage(), //7
        SettingsPage(
            loggedIn: true,
            isBackOffice: _currentUser.role == 'BACKOFFICE'), //8
        CalendarPage(
            username: _currentUser.username,
            date: scheduleDate), //estudante //9
        MyMap(markerLocation: markerLocation), //10
        ReportAnomalyPage(user: _currentUser), //11
        BackOfficePage(), //12
        Placeholder(), //13
        Placeholder(), //diretor //14
        MyEventsPage(username: _currentUser.username), //15
      ];

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
                width: 80.0, // Set your desired width
                height: 80.0, // and height
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
                  child: picture(context)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildWebLayout(context);
    } else {
      return _buildWebLayout(context);
    }
  }

  Widget _buildWebLayout(BuildContext context) {
    final userProvider = Provider.of<UserNotifier>(context);
    _currentUser = userProvider.currentUser!;
    if (isFirst) {
      isFirst = false;
      _selectedIndex = _currentUser.role != 'BACKOFFICE' ? widget.index! : 12;
    }
    Color roleColor = _currentUser.getRoleColor(_currentUser.role);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.blue, Colors.green],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
          backgroundColor: Theme.of(context).primaryColor,
          //roleColor,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: Text(
            _title[_selectedIndex],
            style: Theme.of(context).textTheme.bodyLarge,
            selectionColor: Colors.black,
          ),
          centerTitle: true,
          actions: [
            Tooltip(
              message: 'Quick Logout',
              child: IconButton(
                icon: Icon(Icons.logout, color: logoutColor(context)),
                onPressed: () async {
                  final token = await cacheFactory.get('users', 'token');
                  if (token != null) {
                    await logout(
                        context, _currentUser.username, _showErrorSnackbar);
                  } else {
                    _showErrorSnackbar('Error logging out', true);
                  }
                },
              ),
            )
          ],
        ),

        drawer: Drawer(
          backgroundColor: Theme.of(context).primaryColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor //roleColor,
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
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Column(children: [
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            processDisplayName(_currentUser.displayName),
                            style: _currentUser.displayName.length < 5
                                ? Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(color: Colors.white)
                                : _currentUser.displayName.length < 10
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
                            'Student Number: ${_currentUser.studentNumber}',
                            style: TextStyle(
                              color: Colors.white60,
                              //roleColor == Colors.yellow ? Colors.black: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ]),
                      ),
                    ]),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
              if (_currentUser.role != 'BACKOFFICE')
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 3;
                      _bottomNavigationIndex = 4;
                    });
                    Navigator.pop(context);
                  },
                ),
              ExpansionTile(
                  leading: Icon(
                    Icons.person_add_alt_1_outlined,
                  ),
                  title: Text(
                      _currentUser.role == 'STUDENT'
                          ? 'Student'
                          : _currentUser.role == 'PROFESSOR'
                              ? 'Professor'
                              : _currentUser.role == 'DIRECTOR'
                                  ? 'Director'
                                  : 'SU',
                      style: Theme.of(context).textTheme.bodyLarge),
                  children: [
                    ListTile(
                      leading: Icon(Icons.perm_contact_calendar),
                      title: Text('Calendar'),
                      onTap: () {
                        setState(() {
                          scheduleDate = DateTime.now();
                          _selectedIndex = 9;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.event_note),
                      title: Text('My Events'),
                      onTap: () {
                        setState(() {
                          _selectedIndex = 15;
                          _bottomNavigationIndex = 1;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ]),

              ExpansionTile(
                  leading: Icon(
                    Icons.group,
                  ),
                  title: Text('Community',
                      style: Theme.of(context).textTheme.bodyLarge),
                  children: [
                    ListTile(
                      leading: Icon(Icons.search),
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
                      leading: Icon(
                        Icons.manage_search,
                      ),
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
              if (_currentUser.role != 'BACKOFFICE')
                ListTile(
                  leading: Icon(Icons.newspaper),
                  title: Text('News'),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                      _bottomNavigationIndex = 0;
                    });
                    Navigator.pop(context);
                  },
                ),
              if (_currentUser.role != 'BACKOFFICE')
                ListTile(
                  leading: Icon(Icons.chat),
                  title: Text('Chat',
                      style: Theme.of(context).textTheme.bodyLarge),
                  onTap: () {
                    setState(() {
                      _selectedGroup = "";
                      _selectedIndex = 6;
                      _bottomNavigationIndex = 3;
                    });
                    Navigator.pop(context);
                  },
                ),
              ListTile(
                leading: Icon(Icons.map),
                title: Text('Campus',
                    style: Theme.of(context).textTheme.bodyLarge),
                onTap: () {
                  setState(() {
                    markerLocation = "";
                    _selectedIndex = 10;
                    _bottomNavigationIndex = 2;
                  });
                  Navigator.pop(context);
                },
              ),
              if (_currentUser.role != 'BACKOFFICE')
                ListTile(
                  leading: Icon(Icons.dangerous),
                  title: Text('Anomaly',
                      style: Theme.of(context).textTheme.bodyLarge),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 11;
                    });
                    Navigator.pop(context);
                  },
                ),
              if (_currentUser.role == "BACKOFFICE" ||
                  _currentUser.role == "SU")
                ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('BackOffice Hub',
                      style: Theme.of(context).textTheme.bodyLarge),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 12;
                    });
                    Navigator.pop(context);
                  },
                ),
              SizedBox(height: 75),
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
                leading: Icon(
                  Icons.logout_sharp,
                  color: logoutColor(context),
                ),
                title: Text('Logout',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: logoutColor(context))),
                onTap: () async {
                  final token = await cacheFactory.get('users', 'token');
                  if (token != null) {
                    await logout(
                        context, _currentUser.username, _showErrorSnackbar);
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
        bottomNavigationBar: !kIsWeb
            ? BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                unselectedItemColor: Theme.of(context).secondaryHeaderColor,
                selectedItemColor: Theme.of(context).dividerColor,
                currentIndex: _bottomNavigationIndex,
                onTap: (index) {
                  setState(() {
                    _selectedGroup = "";
                    markerLocation = "";
                    scheduleDate = DateTime.now();
                    _bottomNavigationIndex = index;
                    _selectedIndex = index == 1
                        ? 15
                        : index == 2
                            ? 10
                            : index == 3
                                ? 6
                                : index == 4
                                    ? 3
                                    : index;
                    scales[_selectedIndex] = 1;
                    _controller.reverse();
                    scales[_selectedIndex] = 0;
                  });
                  Future.delayed(const Duration(milliseconds: 250), () {
                    setState(() {
                      scales[index] = 1;
                      _controller.forward();
                    });
                  });
                },
                items: [
                  BottomNavigationBarItem(
                    icon: _buildIcon(Icons.newspaper, 0, AxisDirection.up),
                    label: 'News',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildIcon(Icons.event_note, 15, AxisDirection.right),
                    label: 'Events',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildIcon(Icons.map, 10, AxisDirection.right),
                    label: 'Campus',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildIcon(Icons.chat, 6, AxisDirection.down),
                    label: 'Chat',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildIcon(Icons.person, 3, AxisDirection.left),
                    label: 'Profile',
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index, AxisDirection direction) {
    return _selectedIndex == index ? _applyAnimation(icon, index) : Icon(icon);
  }

  Widget _applyAnimation(IconData icon, int index) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller]),
      builder: (context, child) {
        if (index == 0) {
          // For news icon
          return Transform.translate(
            offset: Offset(0, -5 * math.sin(_controller.value * math.pi * 2)),
            child: child,
          );
        } else if (index == 15) {
          // For search icon
          return Transform.scale(
              scale: 1.0 +
                  (_controller.status == AnimationStatus.forward ? 0.2 : -0.2) *
                      _controller.value,
              child: child);
        } else if (index == 10) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi, // For 270 degree rotation
            child: child,
          );
        } else if (index == 6) {
          // For chat icon
          return Transform.scale(
            scale: 1.0 +
                (_controller.status == AnimationStatus.forward ? 0.2 : -0.2) *
                    _controller.value,
            child: child,
          );
        } else if (index == 3) {
          // If the icon is for settings
          return Transform.translate(
            offset: Offset(0, -5 * math.sin(_controller.value * math.pi * 2)),
            child: child,
          );
        }
        return child!;
      },
      child: Icon(icon),
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
        if (!kIsWeb) _unSubscribeTopic(_currentUser, username);
      }

      FirebaseAuth.FirebaseAuth.instance.signOut();
      cacheFactory.removeLoginCache();
      cacheFactory.removeMessagesCache();
      cacheFactory.removeGroupsCache();

      String page = await cacheFactory.get("settings", "index");
      int index = 0;
      if (page == "News") index = 0;
      if (page == "Contacts") index = 1;
      if (page == "Campus") index = 3;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => NotLoggedInScreen(index: index)),
        (Route<dynamic> route) => false,
      );

      showErrorSnackbar('${response.body}', false);
    } else {
      showErrorSnackbar('${response.body}', true);
    }
  }

  void _unSubscribeTopic(FirebaseAuth.User currentUser, String username) async {
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child('chat').child(username);
    DatabaseReference userGroupsRef = userRef.child('Groups');

    DatabaseEvent userGroupsEvent = await userGroupsRef.once();

    DataSnapshot userGroupsSnapshot = userGroupsEvent.snapshot;

    if (userGroupsSnapshot.value is Map<dynamic, dynamic>) {
      Map<dynamic, dynamic> userGroups =
          userGroupsSnapshot.value as Map<dynamic, dynamic>;
      for (String groupId in userGroups.keys) {
        await FirebaseMessaging.instance.unsubscribeFromTopic(groupId);
      }
    }
  }
}
