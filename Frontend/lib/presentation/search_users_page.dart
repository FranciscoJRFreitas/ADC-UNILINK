import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import 'package:unilink2023/presentation/userprofile_page.dart';
import '../constants.dart';
import '../data/cache_factory_provider.dart';
import '../domain/Token.dart';
import '../domain/User.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchUsersPage extends StatefulWidget {
  final User user;

  SearchUsersPage({required this.user});

  @override
  _SearchUsersPageState createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];
  String? uUsername;

  @override
  void initState() {
    super.initState();
    loadData(); // Call the method in initState
  }

  Future<void> loadData() async {
    uUsername = await cacheFactory.get('users', 'username');
    //TODO More data needs to be retrieved
    setState(() {});
  }

  Future<void> searchUsers(String query) async {
    final url = kBaseUrl + 'rest/search/';
    final tokenID = await cacheFactory.get('users', 'token');
    final storedUsername = await cacheFactory.get('users', 'username');
    Token token = new Token(tokenID: tokenID, username: storedUsername);

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${json.encode(token.toJson())}'
      },
      body: json.encode({
        'username': widget.user.username,
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
              style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
              decoration: InputDecoration(
                labelText: 'Search',
                labelStyle:
                    TextStyle(color: Theme.of(context).secondaryHeaderColor),
                prefixIcon: Icon(Icons.search,
                    color: Theme.of(context).secondaryHeaderColor),
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
                bool isNotUser = widget.user.role != 'STUDENT';
                /*return Card(
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
                    color: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      child: ListTile(
                        leading: picture(context, user.username),
                        title: Text(
                          '${user.displayName}${user.username == uUsername ? ' (You)' : ''}', //TODO Mudar para token em vez de widget
                          //TODO Faz sentido user ver se a si próprio no search?
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    Icons.person,
                                    size: 20),
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
        ],
      ),
    );
  }

  Future<Uint8List?> downloadData(String username) async {
    return FirebaseStorage.instance
        .ref('ProfilePictures/' + username)
        .getData()
        .onError((error, stackTrace) => null);
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
              child: Image.memory(snapshot.data!),
            );
          } else {
            return Icon(
              Icons.account_circle,
              color: Theme.of(context).secondaryHeaderColor,
              size: 50,
            );
          }
          return const CircularProgressIndicator();
        });
  }
}
