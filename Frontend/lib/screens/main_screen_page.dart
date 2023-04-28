import 'package:apdc_ai_60313/screens/search_users_page.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../util/Token.dart';
import '../util/User.dart';
import '../screens/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MainScreen extends StatefulWidget {
  final User user;
  final Token token;

  MainScreen({@required this.user, @required this.token});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _title;
  User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  List<Widget> _widgetOptions() => [
        HomePage(
          key: ValueKey(_currentUser),
          user: _currentUser,
          token: widget.token,
          roleColor: _getRoleColor(_currentUser.role),
        ),
        SearchUsersPage(user: _currentUser, token: widget.token),
        ListUsersPage(user: _currentUser, token: widget.token),
        ModifyAttributesPage(
          user: _currentUser,
          token: widget.token,
          onUserUpdate: (updatedUser) {
            setState(() {
              _currentUser = updatedUser;
            });
          },
        ),
        ChangePasswordPage(user: _currentUser, token: widget.token),
        RemoveAccountPage(user: _currentUser, token: widget.token),
      ];

  @override
  Widget build(BuildContext context) {
    Color roleColor = _getRoleColor(widget.user.role);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: roleColor,
        title: Text(
          "Home",
          style: TextStyle(
            color: roleColor == Colors.yellow ? Colors.black : Colors.white,
          ),
        ),
        actions: [
          Tooltip(
            message: 'Quick Logout',
            child: IconButton(
              icon: Icon(Icons.logout),
              color: roleColor == Colors.yellow ? Colors.black : Colors.white,
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                String token = prefs.getString('token');
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
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: roleColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Welcome, ${widget.user.displayName}',
                    style: TextStyle(
                      color: roleColor == Colors.yellow
                          ? Colors.black
                          : Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Role: ${widget.user.role}',
                    style: TextStyle(
                      color: roleColor == Colors.yellow
                          ? Colors.black
                          : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Home Page'),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                  _title = "Home Page";
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Search Users'),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                  _title = "Search Users";
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('List Users'),
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                  _title = "List Users";
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Modify Attributes'),
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                  _title = "Modify Attributes";
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Change Password'),
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                  _title = "Change Password";
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Remove Account'),
              onTap: () {
                setState(() {
                  _selectedIndex = 5;
                  _title = "Remove Account";
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                String token = prefs.getString('token');
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
      body: _widgetOptions()[_selectedIndex],
    );
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
    final url = "http://localhost:8080/rest/logout/";
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
      }),
    );

    if (response.statusCode == 200) {
      // Clear token from shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WelcomePage()),
      );
      showErrorSnackbar('${response.body}', false);
    } else {
      showErrorSnackbar('${response.body}', true);
    }
  }

  Color _getRoleColor(String role) {
    switch (_getRole(role)) {
      case Role.USER:
        return Colors.green;
      case Role.GBO:
        return Colors.yellow;
      case Role.GS:
        return Colors.orange;
      case Role.SU:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Role _getRole(String role) {
    switch (role) {
      case "USER":
        return Role.USER;
      case "GBO":
        return Role.GBO;
      case "GA":
        return Role.GA;
      case "GS":
        return Role.GS;
      case "SU":
        return Role.SU;
      default:
        return Role.UKN;
    }
  }
}
