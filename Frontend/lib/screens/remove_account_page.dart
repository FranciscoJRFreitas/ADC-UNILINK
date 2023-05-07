import 'package:unilink2023/screens/screen.dart';
import 'package:flutter/material.dart';
import '../util/Token.dart';
import '../util/User.dart';
import '../widgets/widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RemoveAccountPage extends StatefulWidget {
  final User user;
  final Token token;

  RemoveAccountPage({required this.user, required this.token});

  @override
  _RemoveAccountPageState createState() => _RemoveAccountPageState();
}

class _RemoveAccountPageState extends State<RemoveAccountPage> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController targetUsernameController = TextEditingController();
  bool passwordVisibility = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            if (widget.user.role != 'USER') ...[
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
              onTap: () async {
                await removeAccount(
                  context,
                  widget.user.username,
                  passwordController.text,
                  targetUsernameController.text,
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

  Future<void> removeAccount(
    BuildContext context,
    String username,
    String password,
    String targetUsername,
    String token,
  ) async {
    final url = "http://unilink2023.oa.r.appspot.com/rest/remove/";
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
        'targetUsername': targetUsername,
        'token': token,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Account removed successfully."),
          backgroundColor: Colors.green,
        ),
      );
      if (targetUsername.isEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WelcomePage()),
        );
      }
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
