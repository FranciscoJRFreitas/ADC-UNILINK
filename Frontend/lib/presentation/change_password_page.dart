import 'package:flutter/material.dart';
import '../data/cache_factory_provider.dart';
import '../domain/Token.dart';
import '../domain/User.dart';
import '../widgets/widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:unilink2023/domain/cacheFactory.dart' as cache;
import '../constants.dart';

class ChangePasswordPage extends StatefulWidget {
  final User user;

  ChangePasswordPage({required this.user});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController currentPwdController = TextEditingController();
  TextEditingController newPwdController = TextEditingController();
  TextEditingController confirmNewPwdController = TextEditingController();
  bool currentPwdVisibility = true;
  bool newPwdVisibility = true;
  bool confirmNewPwdVisibility = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            MyPasswordField(
              controller: currentPwdController,
              hintText: "Current Password *",
              isPasswordVisible: currentPwdVisibility,
              onTap: () {
                setState(() {
                  currentPwdVisibility = !currentPwdVisibility;
                });
              },
            ),
            MyPasswordField(
              controller: newPwdController,
              hintText: "New Password *",
              isPasswordVisible: newPwdVisibility,
              onTap: () {
                setState(() {
                  newPwdVisibility = !newPwdVisibility;
                });
              },
            ),
            MyPasswordField(
              controller: confirmNewPwdController,
              hintText: "Confirm New Password *",
              isPasswordVisible: confirmNewPwdVisibility,
              onTap: () {
                setState(() {
                  confirmNewPwdVisibility = !confirmNewPwdVisibility;
                });
              },
            ),
            SizedBox(height: 16),
            MyTextButton(
              buttonName: 'Change Password',
              onTap: () async {
                await changePassword(
                  context,
                  widget.user.username,
                  currentPwdController.text,
                  newPwdController.text,
                  confirmNewPwdController.text,
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

  Future<void> changePassword(
    BuildContext context,
    String username,
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    final url = kBaseUrl + "rest/changePwd/";

    final tokenID = await cacheFactory.get('users', 'token');
    final storedUsername = await cacheFactory.get('users', 'username');

    Token token = new Token(tokenID: tokenID, username: storedUsername);

    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${json.encode(token.toJson())}'
      },
      body: jsonEncode({
        'username': username,
        'currentPwd': currentPassword,
        'newPwd': newPassword,
        'confirmPwd': confirmPassword,
      }),
    );

    if (response.statusCode == 200) {
      //Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password changed successfully."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
