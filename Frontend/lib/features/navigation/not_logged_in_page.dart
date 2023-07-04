import 'package:flutter/material.dart';
import 'package:unilink2023/constants.dart';

import 'package:unilink2023/features/contacts/presentation/contacts_page.dart';
import 'package:unilink2023/features/map/MapPage.dart';
import 'package:unilink2023/features/screen.dart';

class NotLoggedInScreen extends StatefulWidget {
  final int? index;

  NotLoggedInScreen({this.index});

  @override
  _NotLoggedInScreenState createState() => _NotLoggedInScreenState(index);
}

class _NotLoggedInScreenState extends State<NotLoggedInScreen> {
  int _selectedIndex = 0;
  List<String> _title = ["News", "Contacts", "Settings", "Map", "Login"];

  _NotLoggedInScreenState(int? index) {
    if (index != null) _selectedIndex = index;
  }

  @override
  void initState() {
    super.initState();
  }

  List<Widget> _widgetOptions() => [
        NewsFeedPage(),
        ContactsPage(),
        SettingsPage(
          loggedIn: false,
        ),
        MyMap(),
        WelcomePage(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: kWhiteBackgroundColor,
        ),
        backgroundColor: Theme.of(context).primaryColor, //roleColor,
        title: Text(
          _title[_selectedIndex],
          style: Theme.of(context).textTheme.bodyLarge,
          selectionColor: Colors.white,
        ),
        centerTitle: true,
        actions: [
          Tooltip(
            message: 'Login',
            child: IconButton(
              icon: Icon(Icons.login),
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
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
            SizedBox(height: 75),
            ListTile(
              leading: Icon(Icons.login),
              title: Text('Login'),
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                });
                Navigator.pop(context);
              },
            ),
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
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Map', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
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
                  _selectedIndex = 1;
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
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
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
}
