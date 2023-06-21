import 'package:flutter/material.dart';
import '../constants.dart';
import '../data/cache_factory_provider.dart';
import '../domain/Token.dart';
import '../domain/User.dart';
import '../widgets/my_age_field.dart';
import '../widgets/widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screen.dart';

class ModifyAttributesPage extends StatefulWidget {
  final User user;
  final Function(User) onUserUpdate;

  ModifyAttributesPage({required this.user, required this.onUserUpdate});

  @override
  _ModifyAttributesPage createState() => _ModifyAttributesPage();
}

class _ModifyAttributesPage extends State<ModifyAttributesPage> {
  bool passwordVisibility = true;

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController targetUsernameController =
      TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String _selectedProfileVisibility = 'Profile Visibility';
  String sv = '';
  String _selectedUserRole = 'User Role';
  String sr = '';
  String _selectedActivityState = 'Activity State';
  String sa = '';
  String _selectedEducationLevel = 'Education Level';
  final TextEditingController registration_dateController =
      TextEditingController();
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
  final TextEditingController photoController = TextEditingController();

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

  Future<void> modifyAttributes(
    String password,
    String educationLevel,
    String birthDate,
    String targetUsername,
    String displayName,
    String email,
    String role,
    String activityState,
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
    String photo,
    void Function(String, bool) showErrorSnackbar,
    bool redirect,
  ) async {
    final url = kBaseUrl + 'rest/modify/';
    final tokenID = await cacheFactory.get('users', 'token');
    final storedUsername = await cacheFactory.get('users', 'username');
    Token token = new Token(tokenID: tokenID, username: storedUsername);

    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${json.encode(token.toJson())}'
      },
      body: json.encode({
        'username': widget.user.username,
        'email': email,
        'password': password,
        'educationLevel': educationLevel,
        'birthDate': birthDate,
        'displayName': displayName,
        'targetUsername': targetUsername,
        'role': role,
        'activityState': activityState,
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
        'photo': photo,
      }),
    );

    if (response.statusCode == 200) {
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
        mobilePhone: responseBody['mobilePhone'],
        occupation: responseBody['occupation'],
      );

      if (responseBody['username'] == widget.user.username) {
        if (widget.onUserUpdate != null) {
          widget.onUserUpdate(user);
          if (redirect) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          }
        }
      }
      if (redirect) {
        showErrorSnackbar('Changes applied successfully!', false);
      }
    } else {
      showErrorSnackbar('Failed to modify attributes: ${response.body}', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Confirm your identity:",
                            style: kBodyText.copyWith(
                              color: Colors.white,
                            ),
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
                          Text(
                            "Attributes to modify:",
                            style: kBodyText.copyWith(
                              color: Colors.white,
                            ),
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
                          regAge(
                            textColor: Colors.grey,
                            controller: registration_dateController,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          if (widget.user.role != 'STUDENT') ...[
                            MyTextField(
                              small: true,
                              controller: targetUsernameController,
                              hintText:
                                  'Target username for changes (leave empty for your own account)',
                              inputType: TextInputType.name,
                            ),
                            MyTextField(
                              small: false,
                              controller: displayNameController,
                              hintText: 'Name',
                              inputType: TextInputType.name,
                            ),
                            MyTextField(
                              small: false,
                              controller: emailController,
                              hintText: 'Email',
                              inputType: TextInputType.name,
                            ),
                            if (widget.user.role == 'DIRECTOR') ...[
                              MyTextComboBox(
                                selectedValue: _selectedUserRole,
                                hintText: 'User Role',
                                items: ['User Role', 'STUDENT', 'PROF'],
                                onChanged: (dynamic newValue) {
                                  setState(() {
                                    _selectedUserRole = newValue;
                                  });
                                },
                              ),
                            ],
                            if (widget.user.role == 'SU') ...[
                              MyTextComboBox(
                                selectedValue: _selectedUserRole,
                                hintText: 'User Role',
                                items: [
                                  'User Role',
                                  'STUDENT',
                                  'PROF',
                                  'DIRECTOR',
                                  'SU'
                                ],
                                onChanged: (dynamic newValue) {
                                  setState(() {
                                    _selectedUserRole = newValue;
                                  });
                                },
                              ),
                            ],
                            MyTextComboBox(
                              selectedValue: _selectedActivityState,
                              hintText: 'Activity State',
                              items: ['Activity State', 'Active', 'Inactive'],
                              onChanged: (dynamic newValue) {
                                setState(() {
                                  _selectedActivityState = newValue;
                                });
                              },
                            ),
                          ],
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
                          buttonName: 'Apply Changes',
                          onTap: () {
                            Future.delayed(Duration(milliseconds: 1000), () {
                              modifyAttributes(
                                passwordController.text,
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
                                targetUsernameController.text,
                                displayNameController.text,
                                emailController.text,
                                sr = _selectedUserRole == 'User Role'
                                    ? ""
                                    : _selectedUserRole,
                                sa = _selectedActivityState == 'Active'
                                    ? 'ACTIVE'
                                    : _selectedActivityState == 'Inactive'
                                        ? 'INACTIVE'
                                        : "",
                                sv = _selectedProfileVisibility == 'Private'
                                    ? 'PRIVATE'
                                    : _selectedProfileVisibility == 'Public'
                                        ? 'PUBLIC'
                                        : "",
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
                                photoController.text,
                                _showErrorSnackbar,
                                true,
                              );
                            });
                          },
                          bgColor: Colors.white,
                          textColor: Colors.black87,
                          height: 60,
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
