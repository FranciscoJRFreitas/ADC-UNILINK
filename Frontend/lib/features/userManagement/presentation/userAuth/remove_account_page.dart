import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:unilink2023/features/BackOfficeHub/BackOfficePage.dart';
import 'package:unilink2023/features/navigation/not_logged_in_page.dart';
import 'package:unilink2023/features/screen.dart';
import 'package:flutter/material.dart';
import '../../../../data/cache_factory_provider.dart';
import '../../../../domain/Token.dart';
import '../../../../widgets/widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RemoveAccountPage extends StatefulWidget {
  final bool isBackoffice;

  RemoveAccountPage({required this.isBackoffice});

  @override
  _RemoveAccountPageState createState() => _RemoveAccountPageState();
}

class _RemoveAccountPageState extends State<RemoveAccountPage> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController targetUsernameController = TextEditingController();
  bool passwordVisibility = true;
  String? _currentRole;
  String? _currentUsername;
  bool isDisposed = false;

  @override
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
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => Navigator.pop(context),
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
            SizedBox(height: 20),
            ..._buildUserInputFields(),
            _buildRemoveAccountButton(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildUserInputFields() {
    if (_currentRole == 'STUDENT') {
      return [
        MyPasswordField(
          controller: passwordController,
          hintText: "Your Password *",
          isPasswordVisible: passwordVisibility,
          onTap: () => setState(() {
            passwordVisibility = !passwordVisibility;
          }),
        )
      ];
    } else {
      return [
        MyTextField(
          small: true,
          controller: targetUsernameController,
          hintText: "Target username (leave empty for your account)",
          inputType: TextInputType.name,
        ),
        MyPasswordField(
          controller: passwordController,
          hintText: "Your Password *",
          isPasswordVisible: passwordVisibility,
          onTap: () => setState(() {
            passwordVisibility = !passwordVisibility;
          }),
        )
      ];
    }
  }

  Widget _buildRemoveAccountButton(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16),
        MyTextButton(
          buttonName: 'Remove Account',
          onTap: () {
            if (passwordController.text.isEmpty) {
              _showSnackbar("Please, enter a password.", Colors.red);
              return;
            }
            _confirmRemoveAccountDialog(context);
          },
          bgColor: Colors.white,
          textColor: Colors.black87,
          height: 60,
        ),
      ],
    );
  }

  void _showSnackbar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void _confirmRemoveAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.fromLTRB(24, 24, 24, 12),
          contentPadding: EdgeInsets.fromLTRB(24, 0, 24, 16),
          title: Text('Confirm Remove Account',
              style: TextStyle(color: Colors.black87, fontSize: 18)),
          content: Text(
            'Are you sure you want to remove this account? This action is irreversible!',
            style: TextStyle(color: Colors.black87, fontSize: 16),
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          actionsPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(color: Colors.black87, fontSize: 16)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text('Remove',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: () async {
                await removeAccount(
                  context,
                  _currentUsername!,
                  passwordController.text.trim(),
                  targetUsernameController.text.trim(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> removeAccount(
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

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (!kIsWeb) {
          DatabaseReference groupsRef =
              FirebaseDatabase.instance.ref().child('groups');

          DatabaseEvent allGroupsEvent = await groupsRef.once();
          DataSnapshot allGroupsSnapshot = allGroupsEvent.snapshot;

          if (allGroupsSnapshot.value is Map<dynamic, dynamic>) {
            Map<dynamic, dynamic> userGroups =
                allGroupsSnapshot.value as Map<dynamic, dynamic>;
            for (String groupId in userGroups.keys) {
              await FirebaseMessaging.instance.unsubscribeFromTopic(groupId);
              await FirebaseMessaging.instance.unsubscribeFromTopic('invite/${targetUsername.isEmpty ? username : targetUsername}');
            }
          }
        }
        removeUserDataFromFireBase(
            user, targetUsername.isEmpty ? username : targetUsername);
      }
    } catch (e) {
      if (!isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Could not remove user. There was an error while removing subscriptions from the Firebase: $e",
                style: TextStyle(
                  color: Colors.white,
                )),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
        return;
      }
    }

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${json.encode(token.toJson())}',
      },
    );

    if (response.statusCode == 200) {
      if (targetUsername.isEmpty) {
        if (!widget.isBackoffice) {
          cacheFactory.removeLoginCache();
          cacheFactory.removeMessagesCache();
          cacheFactory.removeGroupsCache();
        }
        try {
          FirebaseStorage.instance
              .ref()
              .child('ProfilePictures/$username')
              .delete()
              .onError((error, stackTrace) => null);
        } catch (e) {
          if (!isDisposed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    "There was an error while removing the account from the Firebase: $e",
                    style: TextStyle(
                      color: Colors.white,
                    )),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.pop(context);
            return;
          }
        }
      } else
        FirebaseStorage.instance
            .ref()
            .child('ProfilePictures/$targetUsername')
            .delete()
            .onError((error, stackTrace) => null);

      if (!isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account removed successfully.',
                style: TextStyle(
                  color: Colors.white,
                )),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
          context,
          !widget.isBackoffice
              ? MaterialPageRoute(builder: (context) => NotLoggedInScreen())
              : MaterialPageRoute(builder: (context) => MainScreen(index: 12)),
          (Route<dynamic> route) => false,
        );
        return;
      }
    } else {
      if (!isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.body,
                style: TextStyle(
                  color: Colors.white,
                )),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
        return;
      }
    }
    if (!isDisposed) {
      Navigator.pop(context);
      return;
    }
  }

  void showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void removeUserDataFromFireBase(User user, String username) async {
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child('chat').child(username);
    DatabaseReference userGroupsRef = userRef.child('Groups');

    // Retrieve user's group IDs from the database
    DatabaseEvent userGroupsEvent = await userGroupsRef.once();

    DataSnapshot userGroupsSnapshot = userGroupsEvent.snapshot;

    // Unsubscribe from all the groups
    if (userGroupsSnapshot.value is Map<dynamic, dynamic>) {
      /*Map<dynamic, dynamic> userGroups =
              userGroupsSnapshot.value as Map<dynamic, dynamic>;
          for (String groupId in userGroups.keys) {
            if (!kIsWeb) //PROVISIONAL
              await FirebaseMessaging.instance.unsubscribeFromTopic(groupId);
          }*/
    }

    //WARNING:
    //cant remove from users because user.getIdToken() can be from user that is deleting...
    /*FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(await user.getIdToken())
        .remove();*/

    //remove from schedule
  }
}
