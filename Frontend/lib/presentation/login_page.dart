import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants.dart';
import '../data/cache_factory_provider.dart';
import '../presentation/screen.dart';
import '../domain/User.dart';
import '../widgets/widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  bool isPasswordVisible = true;
  final TextEditingController emailUsernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    void doNothingSnackbar(String message, bool isError, bool show) {}

    (() async {
      if (cacheFactory.get('settings', 'checkLogin') != null)
        login(
            context,
            await cacheFactory.get('users', 'username')! as String,
            await cacheFactory.get('users', 'password')! as String,
            doNothingSnackbar);
      setState(() {});
    });
  }

  @override
  void dispose() {
    emailUsernameController.dispose();
    passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // Function to display the snackbar
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
                          "Welcome back,",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "You've been missed!",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        MyTextField(
                          small: false,
                          hintText: 'Email or username',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color:
                                      Theme.of(context).secondaryHeaderColor),
                          inputType: TextInputType.text,
                          controller: emailUsernameController,
                          focusNode: _emailFocusNode,
                          onSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_passwordFocusNode);
                          },
                        ),
                        MyPasswordField(
                          isPasswordVisible: isPasswordVisible,
                          onTap: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          controller: passwordController,
                          hintText: 'Password',
                          focusNode: _passwordFocusNode,
                          onSubmitted: (_) {
                            login(
                              context,
                              emailUsernameController.text,
                              passwordController.text,
                              _showErrorSnackbar,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: kBodyText.copyWith(color: Colors.blue),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => RegisterPage(),
                              ),
                            );
                          },
                          child: Text('Register',
                              style: Theme.of(context).textTheme.bodySmall),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    MyTextButton(
                      buttonName: 'Login',
                      onTap: () {
                        login(
                          context,
                          emailUsernameController.text,
                          passwordController.text,
                          _showErrorSnackbar,
                        );
                      },
                      bgColor: Theme.of(context).primaryColor,
                      textColor: Colors.black87,
                      height: 60,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<int> login(
  BuildContext context,
  String username,
  String password,
  void Function(String, bool, bool) showErrorSnackbar,
) async {
  final url = kBaseUrl + "rest/login/";
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'username': username,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    // Handle successful login
    String authTokenHeader = response.headers['authorization'] ?? '';
    List<String> token =
        authTokenHeader.substring("Bearer ".length).trim().split("|");

    Map<String, dynamic> responseBody = jsonDecode(response.body);
    User user = User(
      displayName: responseBody['displayName'],
      username: responseBody['username'],
      email: responseBody['email'],
      role: responseBody['role'],
      educationLevel: responseBody['educationLevel'],
      birthDate: responseBody['birthDate'],
      profileVisibility: responseBody['profileVisibility'],
      state: responseBody['state'],
      landlinePhone: responseBody['landlinePhone'],
      mobilePhone: responseBody['mobilePhone'],
      occupation: responseBody['occupation'],
      workplace: responseBody['workplace'],
      address: responseBody['address'],
      additionalAddress: responseBody['additionalAddress'],
      locality: responseBody['locality'],
      postalCode: responseBody['postalCode'],
      nif: responseBody['nif'],
      photoUrl: responseBody['photo'],
    );

    cacheFactory.set('username', user.username);
    cacheFactory.set('password', password);
    cacheFactory.set('token', token[0]);
    cacheFactory.setUser(user, token[0], password);
    cacheFactory.set('displayName', user.displayName);
    cacheFactory.set('email', user.email);

    cacheFactory.set('checkLogin', 'true');
    /*} else if (io.Platform.isAndroid) {
      SqliteService().deleteUser(username);
      SqliteService().insertUser(user, token[0], password);
    }*/

    //await SqliteService().printTableContent('settings');

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(user: user)),
    );
    showErrorSnackbar("Login Successful!", false, true);
  } else {
    // Handle unexpected error
    showErrorSnackbar(response.body, true, true);
  }

  return response.statusCode;
}
