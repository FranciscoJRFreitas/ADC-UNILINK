import 'package:unilink2023/features/screen.dart';
import 'package:flutter/material.dart';

import '../../data/cache_factory_provider.dart';
import '../../domain/Token.dart';
import '../../widgets/widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RemoveAccountPage extends StatefulWidget {
  RemoveAccountPage();

  @override
  _RemoveAccountPageState createState() => _RemoveAccountPageState();
}

class _RemoveAccountPageState extends State<RemoveAccountPage> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController targetUsernameController = TextEditingController();
  bool passwordVisibility = true;
  BuildContext? pageContext;
  String? _currentRole;
  String? _currentUsername;

  void initState() {
    super.initState();
    getUser();
  }

  Future<void> getUser() async {
    _currentRole = await cacheFactory.get('users', 'role');
    _currentUsername = await cacheFactory.get('users', 'username');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    this.pageContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Remove Account",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: SvgPicture.asset(
            'assets/images/back_arrow.svg',
            width: 40,
            height: 30,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            if (_currentRole != 'STUDENT') ...[
              MyTextField(
                small: true,
                controller: targetUsernameController,
                hintText: "Target username (leave empty for your account)",
                inputType: TextInputType.name,
              ),
            ],
            MyPasswordField(
              controller: passwordController,
              hintText: "Your Password *",
              isPasswordVisible: passwordVisibility,
              onTap: () {
                setState(() {
                  passwordVisibility = !passwordVisibility;
                });
              },
            ),
            SizedBox(height: 16),
            MyTextButton(
              buttonName: 'Remove Account',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      titlePadding: EdgeInsets.fromLTRB(24, 24, 24, 12),
                      contentPadding: EdgeInsets.fromLTRB(24, 0, 24, 16),
                      title: Text(
                        'Confirm Remove Account',
                        style: TextStyle(color: Colors.black87, fontSize: 18),
                      ),
                      content: Text(
                        'Are you sure you want to remove this account? This action is irreversible!',
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      actionsPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                            'Cancel',
                            style:
                                TextStyle(color: Colors.black87, fontSize: 16),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: Text(
                            'Remove',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            /*await removeAccount(
                              context,
                              widget.user.username,
                              passwordController.text,
                              targetUsernameController.text,
                            ).then((Map<String, dynamic> message) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message['content']),
                                  backgroundColor: message['color'],
                                ),
                              );
                              if (message['redirect']) {
                                Future.delayed(Duration(milliseconds: 500), () {
                                  Navigator.pushAndRemoveUntil(
                                    pageContext!,
                                    MaterialPageRoute(
                                        builder: (context) => WelcomePage()),
                                    (route) => false,
                                  );
                                });
                              }
                            });*/
                            onRemoveButtonPressed(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              bgColor: Colors.white,
              textColor: Colors.black87,
              height: 60,
            ),
          ],
        ),
      ),
    );
  }

  void onRemoveButtonPressed(BuildContext context) async {
    Navigator.of(context).pop();
    Map<String, dynamic> message = await removeAccount(
      context,
      _currentUsername!,
      passwordController.text,
      targetUsernameController.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message['content']),
        backgroundColor: message['color'],
      ),
    );
    if (message['redirect']) {
      Navigator.of(context)
          .popUntil((route) => route.settings.name == 'WelcomePage');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WelcomePage(),
        ),
      );
    }
  }

  Future<Map<String, dynamic>> removeAccount(
    BuildContext context,
    String username,
    String password,
    String targetUsername,
  ) async {
    final url =
        kBaseUrl + 'rest/remove/?targetUsername=$targetUsername&pwd=$password';

    final tokenID = await cacheFactory.get('users', 'token');
    final storedUsername = await cacheFactory.get('users', 'username');

    Token token = new Token(tokenID: tokenID, username: storedUsername);

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${json.encode(token.toJson())}',
      },
    );

    if (response.statusCode == 200) {
      if (targetUsername.isEmpty)
        FirebaseStorage.instance
            .ref()
            .child('ProfilePictures/$username')
            .delete()
            .onError((error, stackTrace) => null);
      else
        FirebaseStorage.instance
            .ref()
            .child('ProfilePictures/$targetUsername')
            .delete()
            .onError((error, stackTrace) => null);

      if (this.mounted) {
        return {
          'content': 'Account removed successfully.',
          'color': Colors.green,
          'redirect': targetUsername.isEmpty || targetUsername == storedUsername
        };
      }
    } else {
      if (this.mounted) {
        return {
          'content': response.body,
          'color': Colors.red,
          'redirect': false
        };
      }
    }
    return {'content': '', 'color': Colors.grey, 'redirect': false};
  }

  void showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
