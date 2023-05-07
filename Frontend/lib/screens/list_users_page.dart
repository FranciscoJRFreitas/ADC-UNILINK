import 'package:flutter/material.dart';
import '../constants.dart';
import '../util/Token.dart';
import '../util/User.dart';
import '../widgets/widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListUsersPage extends StatefulWidget {
  final User user;
  final Token token;

  ListUsersPage({required this.user, required this.token});

  @override
  _ListUsersPageState createState() => _ListUsersPageState();
}

class _ListUsersPageState extends State<ListUsersPage> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final url = 'http://unilink2023.oa.r.appspot.com/rest/list/';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': widget.user.username,
        'token': widget.token.tokenID,
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseBody = jsonDecode(response.body);
      print('Response body: $responseBody');
      setState(() {
        users = responseBody
            .map(
              (userJson) => User.fromJson(userJson),
            )
            .toList();
      });
    } else {
      print('Failed to fetch users: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(8),
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            User user = users[index];
            bool isNotUser = widget.user.role != 'USER';
            if (users.isEmpty && !isNotUser)
              return Text("There are no active and public to be displayed at the moment...");
            else if(users.isEmpty && widget.user.role != 'SU')
              return Text("There are no users to be displayed for your role...");
            //SU can always see his own info
            else
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
    );
  }
}
