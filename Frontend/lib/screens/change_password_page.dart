import 'package:flutter/material.dart';
import '../util/Token.dart';
import '../util/User.dart';
import '../widgets/widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePasswordPage extends StatefulWidget {
  final User user;
  final Token token;

  
  ChangePasswordPage({required this.user, required this.token});

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
                  widget.token.tokenID,
                );
              },
              bgColor: Colors.white,
              textColor: Colors.black87,
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
    String token,
  ) async {

    final url = "http://unilink2023.oa.r.appspot.com/rest/changePwd/";
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'currentPwd': currentPassword,
        'newPwd': newPassword,
        'confirmPwd': confirmPassword,
        'token': token,
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
