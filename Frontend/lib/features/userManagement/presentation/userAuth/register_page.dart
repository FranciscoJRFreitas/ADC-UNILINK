import 'dart:convert';
import '../../../screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import '../../../../widgets/my_age_field.dart';
import '../../../../widgets/widget.dart';
import '../../../../constants.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool passwordVisibility = true;
  bool confirmPwdVisibility = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwdController = TextEditingController();
  final TextEditingController studentNumberController = TextEditingController();
  String _selectedEducationLevel = 'Education Level';
  final TextEditingController registration_dateController =
      TextEditingController();
  String _selectedProfileVisibility = 'Profile Visibility (Public by default)';
  String sv = '';
  final TextEditingController mobilePhoneController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController workplaceController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController courseController = TextEditingController();
  final TextEditingController additionalAddressController =
      TextEditingController();
  final TextEditingController localityController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController nifController = TextEditingController();

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

  Future<void> registerUser(
    String displayName,
    String username,
    String email,
    String studentNumber,
    String password,
    String confirmPwd,
    String educationLevel,
    String birthDate,
    String profileVisibility,
    String mobilePhone,
    String occupation,
    String course,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    final url = kBaseUrl + 'rest/register/';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'displayName': displayName,
        'username': username,
        'email': email,
        'studentNumber': studentNumber,
        'password': password,
        'confirmPwd': confirmPwd,
        'educationLevel': educationLevel,
        'birthDate': birthDate,
        'profileVisibility': profileVisibility,
        'mobilePhone': mobilePhone,
        'occupation': occupation,
        'course': course,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      showErrorSnackbar(
          'Registration successful! Verify you email inbox to activate your account.',
          false);
    } else {
      showErrorSnackbar('Failed to register user: ${response.body}', true);
    }
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
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                child: Column(
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Register",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            "Create a new account to get started!",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Text(
                            "Mandatory Fields:",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          MyTextField(
                            small: false,
                            controller: nameController,
                            hintText: 'Name *',
                            inputType: TextInputType.name,
                          ),
                          MyTextField(
                            small: false,
                            controller: usernameController,
                            hintText: 'Username *',
                            inputType: TextInputType.name,
                          ),
                          MyTextField(
                            small: false,
                            controller: studentNumberController,
                            hintText: 'Student Number *',
                            inputType: TextInputType.name,
                          ),
                          MyTextField(
                            small: false,
                            controller: emailController,
                            hintText: 'Email *',
                            inputType: TextInputType.emailAddress,
                          ),
                          MyPasswordField(
                            controller: passwordController,
                            hintText: "Password *",
                            isPasswordVisible: passwordVisibility,
                            onTap: () {
                              setState(() {
                                passwordVisibility = !passwordVisibility;
                              });
                            },
                          ),
                          MyPasswordField(
                            controller: confirmPwdController,
                            hintText: "Confirm Password *",
                            isPasswordVisible: confirmPwdVisibility,
                            onTap: () {
                              setState(() {
                                confirmPwdVisibility = !confirmPwdVisibility;
                              });
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ExpansionTile(
                            title: Text(
                              "Optional Fields: (You can always change them later)",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            children: <Widget>[
                              MyTextField(
                                small: false,
                                controller: courseController,
                                hintText: 'Course',
                                inputType: TextInputType.name,
                              ),
                              MyTextField(
                                small: false,
                                controller: mobilePhoneController,
                                hintText: 'Mobile Phone',
                                inputType: TextInputType.phone,
                              ),
                              MyTextField(
                                small: false,
                                controller: occupationController,
                                hintText: 'Occupation',
                                inputType: TextInputType.text,
                              ),
                              MyTextComboBox(
                                selectedValue: _selectedEducationLevel,
                                hintText: 'Education Level',
                                items: [
                                  'Education Level',
                                  'Primary Education',
                                  'Secondary Education',
                                  'Undergraduate Degree',
                                  'Master\'s Degree',
                                  'Doctorate'
                                ],
                                onChanged: (dynamic newValue) {
                                  setState(() {
                                    _selectedEducationLevel = newValue;
                                  });
                                },
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              RegAge(
                                textColor:
                                    Theme.of(context).secondaryHeaderColor,
                                controller: registration_dateController,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              MyTextComboBox(
                                selectedValue: _selectedProfileVisibility,
                                hintText:
                                    'Profile Visibility (Public by default)',
                                items: [
                                  'Profile Visibility (Public by default)',
                                  'Public',
                                  'Private'
                                ],
                                onChanged: (dynamic newValue) {
                                  setState(() {
                                    _selectedProfileVisibility = newValue;
                                  });
                                },
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              MyTextButton(
                                buttonName: 'Register',
                                onTap: () {
                                  registerUser(
                                    nameController.text.trim(),
                                    usernameController.text.trim(),
                                    emailController.text.trim(),
                                    studentNumberController.text.trim(),
                                    passwordController.text,
                                    confirmPwdController.text,
                                    sv = _selectedEducationLevel == 'Doctorate'
                                        ? 'D'
                                        : _selectedEducationLevel ==
                                                'Secondary Education'
                                            ? 'SE'
                                            : _selectedEducationLevel ==
                                                    'Undergraduate Degree'
                                                ? 'UD'
                                                : _selectedEducationLevel ==
                                                        'Master\'s Degree'
                                                    ? 'MD'
                                                    : 'PE',
                                    registration_dateController.text,
                                    sv = _selectedProfileVisibility == 'Private'
                                        ? 'PRIVATE'
                                        : 'PUBLIC',
                                    //Default Private
                                    mobilePhoneController.text.trim(),
                                    occupationController.text.trim(),
                                    courseController.text.trim(),
                                    _showErrorSnackbar,
                                  );
                                },
                                bgColor: Theme.of(context).primaryColor,
                                textColor: Colors.white70,
                                height: 50,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already a user?  ',
                                style: TextStyle(fontSize: 16),
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) => LoginPage(),
                                        ),
                                      );
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Login',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: Colors.blue.shade400,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
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
