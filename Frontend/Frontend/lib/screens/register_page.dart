import 'dart:convert';
import 'package:apdc_ai_60313/screens/screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:http/http.dart' as http;
import '../widgets/widget.dart';
import '../constants.dart';

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
  String _selectedProfileVisibility = 'Profile Visibility';
  String sv = '';
  final TextEditingController landlinePhoneController = TextEditingController();
  final TextEditingController mobilePhoneController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController workplaceController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
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
    String password,
    String confirmPwd,
    String profileVisibility,
    String landlinePhone,
    String mobilePhone,
    String occupation,
    String workplace,
    String address,
    String additionalAddress,
    String locality,
    String postalCode,
    String nif,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    final url = 'http://unilink2023.oa.r.appspot.com/rest/register/';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'displayName': displayName,
        'username': username,
        'email': email,
        'password': password,
        'confirmPwd': confirmPwd,
        'profileVisibility': profileVisibility,
        'landlinePhone': landlinePhone,
        'mobilePhone': mobilePhone,
        'occupation': occupation,
        'workplace': workplace,
        'address': address,
        'additionalAddress': additionalAddress,
        'locality': locality,
        'postalCode': postalCode,
        'taxIdentificationNumber': nif,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      showErrorSnackbar(
          'Registration successful. Login to your new account!', false);
    } else {
      showErrorSnackbar('Failed to register user: ${response.body}', true);
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
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Register",
                            style: kHeadline,
                          ),
                          Text(
                            "Create a new account to get started!",
                            style: kBodyText2,
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: kBodyText.copyWith(color: Colors.blue),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => LoginPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Login',
                                  style: kBodyText.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Text(
                            "Mandatory Fields:",
                            style: kBodyText,
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
                            height: 25,
                          ),
                          Text(
                            "Optional Fields: (You can always change them later)",
                            style: kBodyText,
                          ),
                          MyTextComboBox(
                            selectedValue: _selectedProfileVisibility,
                            hintText: 'Profile Visibility',
                            items: ['Profile Visibility', 'Public', 'Private'],
                            onChanged: (dynamic newValue) {
                              setState(() {
                                _selectedProfileVisibility = newValue;
                              });
                            },
                          ),
                          MyTextField(
                            small: false,
                            controller: landlinePhoneController,
                            hintText: 'Landline Phone',
                            inputType: TextInputType.phone,
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
                          MyTextField(
                            small: false,
                            controller: workplaceController,
                            hintText: 'Workplace',
                            inputType: TextInputType.text,
                          ),
                          MyTextField(
                            small: false,
                            controller: addressController,
                            hintText: 'Address',
                            inputType: TextInputType.text,
                          ),
                          MyTextField(
                            small: false,
                            controller: additionalAddressController,
                            hintText: 'Additional Address',
                            inputType: TextInputType.text,
                          ),
                          MyTextField(
                            small: false,
                            controller: localityController,
                            hintText: 'Locality',
                            inputType: TextInputType.text,
                          ),
                          MyTextField(
                            small: false,
                            controller: postalCodeController,
                            hintText: 'Postal Code (1234-567)',
                            inputType: TextInputType.text,
                          ),
                          MyTextField(
                            small: false,
                            controller: nifController,
                            hintText: 'NIF (123456789)',
                            inputType: TextInputType.text,
                          ),
                        ],
                      ),
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
                              nameController.text,
                              usernameController.text,
                              emailController.text,
                              passwordController.text,
                              confirmPwdController.text,
                              sv = _selectedProfileVisibility == 'Public'
                                  ? 'PUBLIC'
                                  : 'PRIVATE',
                              //Default Private
                              landlinePhoneController.text,
                              mobilePhoneController.text,
                              occupationController.text,
                              workplaceController.text,
                              addressController.text,
                              additionalAddressController.text,
                              localityController.text,
                              postalCodeController.text,
                              nifController.text,
                              _showErrorSnackbar,
                            );
                          },
                          bgColor: Colors.white,
                          textColor: Colors.black87,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
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
