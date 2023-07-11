import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../data/cache_factory_provider.dart';
import '../domain/Token.dart';
import 'package:http/http.dart' as http;
import '../features/userManagement/domain/User.dart';

class AutocompleteDropdown extends StatefulWidget {
  final String groupId;
  final Function(String, bool) showError;

  AutocompleteDropdown({required this.groupId, required this.showError});

  @override
  _AutocompleteDropdownState createState() => _AutocompleteDropdownState();
}

class _AutocompleteDropdownState extends State<AutocompleteDropdown> {
  String _selectedOption = '';
  late List<String> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final url = kBaseUrl + 'rest/list/';
    final tokenID = await cacheFactory.get('users', 'token');
    final storedUsername = await cacheFactory.get('users', 'username');
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
      List<String> updatedUsers = responseBody
          .map((userJson) => User.fromJson(userJson).username)
          .toList();

      setState(() {
        users = updatedUsers;
      });
    } else {
      print('Failed to fetch users: ${response.body}');
    }
  }

  Future<void> inviteGroup(
      String groupId,
      String userId,
      void Function(String, bool) showErrorSnackbar,
      ) async {
    final url =
        kBaseUrl + "rest/chat/invite?groupId=" + groupId + "&userId=" + userId;
    final tokenID = await cacheFactory.get('users', 'token');
    final storedUsername = await cacheFactory.get('users', 'username');
    Token token = new Token(tokenID: tokenID, username: storedUsername);

    final response = await http.post(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${json.encode(token.toJson())}'
    });

    if (response.statusCode == 200) {
      showErrorSnackbar('Invite sent!', false);
    } else {
      showErrorSnackbar('Error sending the invite!', true);
    }
  }

  Widget mobileLayout(BuildContext context){
          return SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context); // closes the modal
                      },
                    ),
                  ),
                Column(
                    children: [
                      SizedBox(height: 50),
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return users;
                          }
                          return users.where((option) =>
                              option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (String selectedOption) {
                          setState(() {
                            _selectedOption = selectedOption;
                          });
                        },
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController fieldTextEditingController,
                            FocusNode fieldFocusNode,
                            VoidCallback onFieldSubmitted) {
                          return TextFormField(
                            controller: fieldTextEditingController,
                            focusNode: fieldFocusNode,
                            onChanged: (text) => _selectedOption = text,
                            decoration: InputDecoration(
                              labelText: "Search for a User",
                              hintStyle: Theme.of(context).textTheme.bodyLarge,
                              labelStyle: Theme.of(context).textTheme.bodyLarge,
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Color.fromARGB(92, 161, 161, 161))),
                              errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red, width: 2.0)),
                              focusedErrorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red, width: 2.0)),
                            ),
                          );
                        },
                        optionsViewBuilder: (BuildContext context,
                            AutocompleteOnSelected<String> onSelected,
                            Iterable<String> options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              child: Container(
                                height: MediaQuery.of(context).size.height * 0.29,
                                width: MediaQuery.of(context).size.width * 0.89,
                                child: ListView(
                                  children: options
                                      .map((String option) => ListTile(
                                    title: Text(option),
                                    onTap: () {
                                      onSelected(option);
                                    },
                                  ))
                                      .toList(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: () async {
                          {
                            inviteGroup(widget.groupId, _selectedOption, widget.showError);
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87),
                        child: const Text("SEND"),
                      ),
                    ])
                      ]),
                    
                  ),
          );


  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? AlertDialog(
        title: Text(
          "Send an Invite",
          textAlign: TextAlign.left,
        ),
        backgroundColor: Theme.of(context).canvasColor,
        content: SingleChildScrollView(
        child: Column(
        children: [
          Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return users;
        }
        return users.where((option) =>
            option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String selectedOption) {
        setState(() {
          _selectedOption = selectedOption;
        });
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController fieldTextEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted) {
        return TextFormField(
          controller: fieldTextEditingController,
          focusNode: fieldFocusNode,
          onChanged: (text) => _selectedOption = text,
          decoration: InputDecoration(
            labelText: "Search for a User",
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(92, 161, 161, 161))),
            errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2.0)),
            focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2.0)),
          ),
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected,
          Iterable<String> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: Container(
              height: 200.0,
              width: 250.0,
              child: ListView(
                children: options
                    .map((String option) => ListTile(
                  title: Text(option),
                  onTap: () {
                    onSelected(option);
                  },
                ))
                    .toList(),
              ),
            ),
          ),
        );
      },
          )
        ])
        ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            {
              inviteGroup(widget.groupId, _selectedOption, widget.showError);
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
              primary: Theme.of(context).primaryColor),
          child: const Text("SEND"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
              primary: Theme.of(context).primaryColor),
          child: const Text("CANCEL"),
        ),
      ],
    ): mobileLayout(context);
  }

  /*void _showErrorSnackbar(String message, bool Error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Error ? Colors.red : Colors.blue.shade900,
      ),
    );
  }*/
}
