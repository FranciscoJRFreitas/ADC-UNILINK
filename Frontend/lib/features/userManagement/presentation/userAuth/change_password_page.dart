import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilink2023/features/userManagement/domain/User.dart';
import '../../../../data/cache_factory_provider.dart';
import '../../../../domain/Token.dart';
import '../../../../domain/UserNotifier.dart';
import '../../../../widgets/widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChangePasswordPage extends StatefulWidget {
  ChangePasswordPage();

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController currentPwdController = TextEditingController();
  TextEditingController newPwdController = TextEditingController();
  TextEditingController confirmNewPwdController = TextEditingController();
  FocusNode _passwordFocusNode = FocusNode();
  FocusNode _newPasswordFocusNode = FocusNode();
  FocusNode _confirmPasswordFocusNode = FocusNode();
  bool currentPwdVisibility = true;
  bool newPwdVisibility = true;
  bool confirmNewPwdVisibility = true;

  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    getUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _passwordFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    currentPwdController.dispose();
    newPwdController.dispose();
    confirmNewPwdController.dispose();
    super.dispose();
  }

  Future<void> getUser() async {
    _currentUsername = await cacheFactory.get('users', 'username');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Change Password",
          style: Theme.of(context).textTheme.bodyLarge,
          selectionColor: Colors.white,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
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
            MyPasswordField(
                controller: currentPwdController,
                hintText: "Current Password *",
                isPasswordVisible: currentPwdVisibility,
                focusNode: _passwordFocusNode,
                onTap: () {
                  setState(() {
                    currentPwdVisibility = !currentPwdVisibility;
                  });
                },
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_newPasswordFocusNode)),
            MyPasswordField(
              controller: newPwdController,
              hintText: "New Password *",
              isPasswordVisible: newPwdVisibility,
              focusNode: _newPasswordFocusNode,
              onTap: () {
                setState(() {
                  newPwdVisibility = !newPwdVisibility;
                });
              },
              onSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_confirmPasswordFocusNode),
            ),
            MyPasswordField(
              controller: confirmNewPwdController,
              hintText: "Confirm New Password *",
              isPasswordVisible: confirmNewPwdVisibility,
              focusNode: _confirmPasswordFocusNode,
              onTap: () {
                setState(() {
                  confirmNewPwdVisibility = !confirmNewPwdVisibility;
                });
              },
              onSubmitted: (_) async {
                await changePassword(
                  context,
                  _currentUsername!,
                  currentPwdController.text,
                  newPwdController.text,
                  confirmNewPwdController.text,
                );
              },
            ),
            SizedBox(height: 16),
            MyTextButton(
              buttonName: 'Change Password',
              onTap: () async {
                await changePassword(
                  context,
                  _currentUsername!,
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

  void _showErrorSnackbar(String message, bool Error, bool show) {
    if (!show) return;
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

  Future<void> changePassword(
    BuildContext context,
    String username,
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    if (currentPassword == '' || newPassword == '' || confirmPassword == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Form fields are empty!"),
          backgroundColor: Colors.red,
        ),
      );
    } else if (currentPassword == newPassword &&
        currentPassword == confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Your new password cannot be the same as your current password. Please choose a different password!",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
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
        User user = await Provider.of<UserNotifier>(context, listen: false)
            .currentUser!;
        cacheFactory.setUser(user, tokenID, newPassword);
        await Provider.of<UserNotifier>(context, listen: false)
            .updateUser(user);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Password changed successfully."),
            backgroundColor: Colors.green,
          ),
        );

        currentPwdController.clear();
        newPwdController.clear();
        confirmNewPwdController.clear();
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Passwords do not match."),
            backgroundColor: Colors.red,
          ),
        );

      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Incorrect current password."),
            backgroundColor: Colors.red,
          ),
        );

        currentPwdController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "There was an error on our side. Please try again later..."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
