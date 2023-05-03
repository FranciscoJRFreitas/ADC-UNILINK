import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../screens/screen.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import '../util/Token.dart';
import '../util/User.dart';
import '../widgets/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void storeTokenAndExpiration(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isPasswordVisible = true;
  final TextEditingController emailUsernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailUsernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Function to display the snackbar
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

  Future<void> login(
    BuildContext context,
    String username,
    String password,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    final url = "http://localhost:8080/rest/login/";
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
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      String tokenID = responseBody['tokenID'];

      Token token = Token(tokenID: tokenID);

      User user = User(
        displayName: responseBody['displayName'],
        username: responseBody['username'],
        email: responseBody['email'],
        role: responseBody['role'],
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

      storeTokenAndExpiration(tokenID);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MainScreen(user: user, token: token)),
      );
      showErrorSnackbar("Login Successful!", false);
    } else if (response.statusCode == 403) {
      // Handle failed login
      showErrorSnackbar("Invalid login credentials. Please try again.", true);
    } else {
      // Handle unexpected error
      showErrorSnackbar(
          "An unexpected error occurred. Please try again.", true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image(
            width: 24,
            color: Colors.white,
            image: Svg('assets/images/back_arrow.svg'),
          ),
        ),
      ),
      body: SafeArea(
        //to make page scrollable
        child: CustomScrollView(
          reverse: true,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome back,",
                                  style: kHeadline,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "You've been missed!",
                                  style: kBodyText2,
                                ),
                                SizedBox(
                                  height: 60,
                                ),
                                MyTextField(
                                  small: false,
                                  hintText: 'Email or username',
                                  inputType: TextInputType.text,
                                  controller: emailUsernameController,
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
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      // Wrap the login button and the row with a Column widget
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
                              child: Text(
                                'Register',
                                style: kBodyText.copyWith(
                                  color: Colors.white,
                                ),
                              ),
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
                          bgColor: Colors.white,
                          textColor: Colors.black87,
                        ),
                      ],
                    ),
                    Expanded(child: Container()),
                    // Add an Expanded widget to create the bottom margin
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
