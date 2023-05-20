import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:unilink2023/presentation/userprofile_page.dart';
import '../domain/Token.dart';
import '../domain/User.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unilink2023/domain/cacheFactory.dart' as cache;
import '../constants.dart';

class ListUsersPage extends StatefulWidget {
  final User user;

  ListUsersPage({required this.user});

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
    final url = kBaseUrl + 'rest/list/';
    final tokenID = await cache.getValue('users', 'token');
    final storedUsername = await cache.getValue('users', 'username');
    Token token = new Token(tokenID: tokenID, username: storedUsername);

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${json.encode(token.toJson())}'
      },
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
            bool isNotUser = true; //widget.user.role != 'USER';
            if (users.isEmpty && !isNotUser)
              return Text(
                  "There are no active and public to be displayed at the moment...");
            else if (users.isEmpty && widget.user.role != 'SU')
              return Text(
                  "There are no users to be displayed for your role...");
            //SU can always see his own info
            else
              /*return Card(
                color: Colors.white60,
                child: ListTile(
                  title: Text(
                      '${user.displayName}${user.username == widget.user.username ? ' (You)' : ''}'),
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
              );*/
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => UserProfilePage(
                              user: user,
                              targetUser: widget.user,
                              isNotUser: isNotUser,
                            )),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: ListTile(
                      leading: picture(context, user.username),
                      title: Text(
                        '${user.displayName}${user.username == widget.user.username ? ' (You)' : ''}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.person, size: 20),
                              SizedBox(width: 5),
                              Text('Username: ${user.username}'),
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
          },
        ),
      ),
    );
  }

  Future<Uint8List?> downloadData(String username) async {

    return FirebaseStorage.instance.ref(
        'ProfilePictures/' + username).getData().onError((error, stackTrace) => null);
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
                  builder: (BuildContext dialogContext) { // Here
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
                                shape: BoxShape.circle, // use circle if the icon is circular
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
                                Navigator.of(dialogContext).pop(); // Use dialogContext here
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
