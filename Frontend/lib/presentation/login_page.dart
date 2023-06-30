import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../data/cache_factory_provider.dart';
import '../domain/UserNotifier.dart';
import '../presentation/screen.dart';
import '../domain/User.dart';
import '../widgets/widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter/foundation.dart';

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
  bool _isLoading = false;

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
                            setState(() {
                              _isLoading = true;
                            });
                            login(
                              context,
                              emailUsernameController.text,
                              passwordController.text,
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
                        Column(
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            MyTextButton(
                              buttonName: _isLoading ? 'Loading...' : 'Login',
                              onTap: _isLoading
                                  ? () {}
                                  : () {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      login(
                                        context,
                                        emailUsernameController.text,
                                        passwordController.text,
                                        _showErrorSnackbar,
                                      ).then((_) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      });
                                    },
                              bgColor: Theme.of(context).primaryColor,
                              textColor: Colors.black87,
                              height: 60,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                Container(
                  color:
                      Colors.black.withOpacity(0.5), // semi-transparent overlay
                  child: Center(
                    child: CircularProgressIndicator(), // a loading spinner
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

  http.Client client = http.Client();
  http.Response response;
  debugPrint(username + " " + password);
  if (username == '' && password == '') {
    showErrorSnackbar("Fill in your credentials.", true, true);
    return -1;
  } else {
    try {
      response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
    } on http.ClientException {
      showErrorSnackbar(
          "Connection failed. Please try again later.", true, true);
      return -1;
    }

    if (response.statusCode == 200) {
      // Handle successful login
      String authTokenHeader = response.headers['authorization'] ?? '';
      List<String> token =
          authTokenHeader.substring("Bearer ".length).trim().split("|");

      // Compute the processing on a separate isolate
      Map<String, dynamic> responseBody =
          await compute(parseResponse, response.body);

      User user = User(
        displayName: responseBody['displayName'],
        username: responseBody['username'],
        email: responseBody['email'],
        role: responseBody['role'],
        educationLevel: responseBody['educationLevel'],
        birthDate: responseBody['birthDate'],
        profileVisibility: responseBody['profileVisibility'],
        state: responseBody['state'],
        mobilePhone: responseBody['mobilePhone'],
        occupation: responseBody['occupation'],
        creationTime: DateFormat('dd/MM/yyyy').format(
            DateTime.fromMillisecondsSinceEpoch(
                responseBody['creationTime']['seconds'] * 1000)),
      );
      try {
        FirebaseAuth.UserCredential userCredential =
            await FirebaseAuth.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: user.email,
          password: password,
        );

        final FirebaseAuth.User? _currentUser = userCredential.user;

        if (_currentUser != null) {
          DatabaseReference userRef =
              FirebaseDatabase.instance.ref().child('chat').child(username);
          DatabaseReference userGroupsRef = userRef.child('Groups');

          /* // Store the token in the database
        await userRef
            .child('token')
            .set(await FirebaseMessaging.instance.getToken()); */

          // Retrieve user's group IDs from the database
          DatabaseEvent userGroupsEvent = await userGroupsRef.once();

          // Retrieve the DataSnapshot from the Event
          DataSnapshot userGroupsSnapshot = userGroupsEvent.snapshot;

          // Subscribe to all the groups
          if (userGroupsSnapshot.value is Map<dynamic, dynamic>) {
            Map<dynamic, dynamic> userGroups =
                userGroupsSnapshot.value as Map<dynamic, dynamic>;
            for (String groupId in userGroups.keys) {
              if (!kIsWeb)
                await FirebaseMessaging.instance.subscribeToTopic(groupId);
            }
          }
        }
      } catch (e) {
        // Failed to authenticate user
        print('Failed to authenticate user: $e');
      }

      cacheFactory.setUser(user, token[0], password);

      cacheFactory.set('checkLogin', 'true');
      cacheFactory.printDb();

      await Provider.of<UserNotifier>(context, listen: false).updateUser(user);
      await Provider.of<UserNotifier>(context, listen: false).downloadData();

      String page = await cacheFactory.get("settings", "index");
      int index = 0;

      if (page == "News") index = 0;
      if (page == "Profile") index = 3;
      if (page == "Schedule") index = 9;
      if (page == "Chat") index = 6;
      if (page == "Contacts") index = 7;
      if (page == "Map") index = 10;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(index: index)),
      );
      showErrorSnackbar("Login Successful!", false, true);
    } else {
      // Handle unexpected error
      if (response.statusCode == 500) {
        showErrorSnackbar(
            'There was a mistake on our side.Please try later.', true, true);
      } else if (response.statusCode == 403) {
        showErrorSnackbar('Wrong Password!', true, true);
      } else if (response.statusCode == 404) {
        showErrorSnackbar('Incorrect Info!', true, true);
      }
    }

    return response.statusCode;
  }
}

Map<String, dynamic> parseResponse(String responseBody) {
  return jsonDecode(responseBody);
}
