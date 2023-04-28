import 'package:flutter/material.dart';
import '../constants.dart';
import '../util/Token.dart';
import '../util/User.dart';
import '../widgets/widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchUsersPage extends StatefulWidget {
  final User user;
  final Token token;

  SearchUsersPage({@required this.user, @required this.token});

  @override
  _SearchUsersPageState createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];

  Future<void> searchUsers(String query) async {
    final url = 'http://localhost:8080/rest/search/';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': widget.user.username,
        'token': widget.token.tokenID,
        'searchQuery': query,
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseBody = jsonDecode(response.body);
      setState(() {
        _searchResults = responseBody
            .map(
              (userJson) => User.fromJson(userJson),
            )
            .toList();
      });
    } else {
      print('Failed to search users: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Search',
                labelStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.search, color: Colors.white),
              ),
              onChanged: (value) {
                if (value.trim().isNotEmpty) {
                  searchUsers(value.trim());
                } else {
                  setState(() {
                    _searchResults = [];
                  });
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                User user = _searchResults[index];
                bool isNotUser = widget.user.role != 'USER';
                return Card(
                  child: ListTile(
                    title: Text('${user.displayName}${user.username == widget.user.username ? ' (You)' : ''}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Username: ${user.username}'),
                        Text('Email: ${user.email}'),
                        if (isNotUser) Text('Role: ${user.role}'),
                        if (isNotUser) Text('State: ${user.state}'),
                        if (isNotUser)
                          Text('Profile Visibility: ${user.profileVisibility}'),
                        if (isNotUser) Text('Landline: ${user.landlinePhone}'),
                        if (isNotUser) Text('Mobile: ${user.mobilePhone}'),
                        if (isNotUser) Text('Occupation: ${user.occupation}'),
                        if (isNotUser) Text('Workplace: ${user.workplace}'),
                        if (isNotUser) Text('Address: ${user.address}'),
                        if (isNotUser)
                          Text('Additional Address: ${user.additionalAddress}'),
                        if (isNotUser) Text('Locality: ${user.locality}'),
                        if (isNotUser) Text('Postal Code: ${user.postalCode}'),
                        if (isNotUser) Text('NIF: ${user.nif}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
