import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilink2023/presentation/contacts_page.dart';
import '../constants.dart';
import '../data/cache_factory_provider.dart';
import '../domain/UserNotifier.dart';
import '../domain/Token.dart';
import '../domain/User.dart';
import 'newMapPage.dart';
import 'screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:photo_view/photo_view.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import '../presentation/schedule_page.dart';

class NotLoggedInScreen extends StatefulWidget {
  final int? index;

  NotLoggedInScreen({this.index});

  @override
  _NotLoggedInScreenState createState() => _NotLoggedInScreenState(index);
}

class _NotLoggedInScreenState extends State<NotLoggedInScreen> {
  int _selectedIndex = 0;
  List<String> _title = [
    "News",
    "Contacts",
    "Settings",
    "Map",
    "Login"
  ];

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
    SettingsPage(),
    MapPage(username: ""),
    WelcomePage(), //professor
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor, //roleColor,
        title: Text(
          _title[_selectedIndex],
          style: Theme.of(context).textTheme.bodyLarge,
          selectionColor: Colors.white,
        ),
        centerTitle: true,
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
