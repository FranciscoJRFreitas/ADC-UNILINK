import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unilink2023/widgets/widgets.dart';

import '../../../../constants.dart';
import '../../../../widgets/my_text_button.dart';
import '../../../../widgets/my_text_field.dart';
import 'login_page.dart';

class RecoverPasswordPage extends StatefulWidget {
  @override
  RecoverPasswordPageState createState() => RecoverPasswordPageState();
}

class RecoverPasswordPageState extends State<RecoverPasswordPage> {
  FocusNode _emailFocusNode = FocusNode();
  final TextEditingController emailUsernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    emailUsernameController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
          child: Stack(
            children: [
              SingleChildScrollView(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Problems logging in?",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Enter your email or username, and we'll send you a link to recover access to your account.",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      MyTextField(
                        small: false,
                        hintText: 'Email or username',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).secondaryHeaderColor),
                        inputType: TextInputType.text,
                        controller: emailUsernameController,
                        focusNode: _emailFocusNode,
                        onSubmitted: (_) {
                          setState(() {
                            _isLoading = true;
                          });
                          recoverPassword(
                            context,
                            emailUsernameController.text,
                            _showErrorSnackbar,
                          ).then((_) {
                            setState(() {
                              _isLoading = false;
                            });
                          });
                        },
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      MyTextButton(
                        buttonName: _isLoading ? 'Loading...' : 'Send Recovery Email',
                        onTap: _isLoading
                            ? () {}
                            : () {
                                setState(() {
                                  _isLoading = true;
                                });
                                recoverPassword(
                                  context,
                                  emailUsernameController.text.trim(),
                                  _showErrorSnackbar,
                                ).then((_) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                });
                              },
                        bgColor: Theme.of(context).primaryColor,
                        textColor: Colors.white70,
                        height: 50,
                      ),
                    ],
                  ),
                ],
              ))
            ],
          ),
        )));
  }

  void _showErrorSnackbar(String message, bool Error) {
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

  Future<void> recoverPassword(
    BuildContext context,
    String username,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    if (username.isEmpty) {
      showErrorSnackbar("Please provide your email or username!", true);
      return;
    }

    final url = kBaseUrl + "rest/recoverPwd/?username=$username";

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      showErrorSnackbar(
          "Please check your inbox and follow the recovery account steps.",
          false);
    } else if (response.statusCode == 417) {
      showErrorSnackbar(response.body, true);
    } else {
      showErrorSnackbar(
          "Failed to recover password. Please try again later.", true);
    }
  }
}
