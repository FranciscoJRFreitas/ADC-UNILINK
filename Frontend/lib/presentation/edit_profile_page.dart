import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../data/cache_factory_provider.dart';
import '../domain/UserNotifier.dart';
import '../domain/Token.dart';
import '../domain/User.dart';
import '../widgets/LineComboBox.dart';
import '../widgets/LineDateField.dart';
import '../widgets/ToggleButton.dart';
import '../widgets/widget.dart';
import '../widgets/LineTextField.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  final User user;
  EditProfilePage({required this.user});

  @override
  _EditProfilePage createState() => _EditProfilePage();
}

class _EditProfilePage extends State<EditProfilePage> {
  late User user;
  final TextEditingController passwordController = TextEditingController();
  late TextEditingController displayNameController;
  late String? _selectedEducationLevel;
  late TextEditingController birthDateController;
  late TextEditingController mobilePhoneController;
  late TextEditingController occupationController;

  DocumentReference picsRef =
      FirebaseFirestore.instance.collection('ProfilePictures').doc();

  @override
  void initState() {
    super.initState();
    user = widget.user;
    initialize();
  }

  void initialize() {
    displayNameController = TextEditingController(text: user.displayName);
    birthDateController = TextEditingController(text: user.birthDate);
    mobilePhoneController = TextEditingController(text: user.mobilePhone);
    occupationController = TextEditingController(text: user.occupation);
    _selectedEducationLevel = user.educationLevel == 'D'
        ? 'Doctorate'
        : user.educationLevel == 'SE'
            ? 'Secondary Education'
            : user.educationLevel == 'UD'
                ? 'Undergraduate Degree'
                : user.educationLevel == 'MD'
                    ? 'Master\'s Degree'
                    : user.educationLevel == 'PE'
                        ? 'Primary Education'
                        : 'Education Level';
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

  Future<void> modifyAttributes(
    String password,
    String educationLevel,
    String birthDate,
    String targetUsername,
    String displayName,
    String role,
    String activityState,
    String profileVisibility,
    String mobilePhone,
    String occupation,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    final url = kBaseUrl + 'rest/modify/';
    final tokenID = await cacheFactory.get('users', 'token');
    Token token = new Token(tokenID: tokenID, username: user.username);

    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${json.encode(token.toJson())}'
      },
      body: json.encode({
        'username': user.username,
        'password': password,
        'email': user.email,
        'educationLevel': educationLevel,
        'birthDate': birthDate,
        'displayName': displayName,
        'targetUsername': '',
        'role': role,
        'activityState': activityState,
        'profileVisibility': profileVisibility,
        'mobilePhone': mobilePhone,
        'occupation': occupation,
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

      await Provider.of<UserNotifier>(context, listen: false).updateUser(user);

      //cacheFactory.setUser(
      //  user, await cacheFactory.get('users', 'token'), password);
      showErrorSnackbar('Changes applied successfully!', false);
      Navigator.pop(context);
    } else {
      showErrorSnackbar('Failed to modify attributes: ${response.body}', true);
    }
  }

  Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();

    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    final fileBytes = await pickedFile!.readAsBytes();

    Reference storageReference = FirebaseStorage.instance.ref().child(
        'ProfilePictures/' + await cacheFactory.get('users', 'username'));

    await storageReference.putData(fileBytes);
    await Provider.of<UserNotifier>(context, listen: false).downloadData();
    setState(() {});
  }

  Widget picture(BuildContext context) {
    final photoProvider = Provider.of<UserNotifier>(context);
    final Future<Uint8List?>? userPhoto = photoProvider.currentPic;

    return FutureBuilder<Uint8List?>(
        future: userPhoto,
        builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
          if (snapshot.hasData) {
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return Dialog(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          PhotoView(
                            imageProvider: MemoryImage(snapshot.data!),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 15.0,
                                      spreadRadius: 2.0,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: ClipOval(
                child: FittedBox(
                  child: Image.memory(
                    snapshot.data!,
                    fit: BoxFit.fill,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            );
          } else {
            return const Icon(
              Icons.account_circle,
              color: Colors.green,
              size: 125,
            );
          }
          return const CircularProgressIndicator();
        });
  }

  Widget profilePicture(BuildContext context) {
    return InkWell(
      onTap: () {
        //edit image link click as per your need.
      },
      child: Stack(
        children: <Widget>[
          Container(
            width: 125,
            height: 125,
            child: picture(context),
          ),
          Positioned(
              bottom: 1,
              right: 1,
              child: Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: InkWell(
                  onTap: () async {
                    await getImage(true);
                    setState(() {});
                  },
                  child: Icon(
                    Icons.add_a_photo,
                    size: 30.0,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool _isPublic = user.profileVisibility!.toLowerCase() == 'public';
    double offset = MediaQuery.of(context).size.width * 0.08;
    return Dialog(
      insetPadding: EdgeInsets.fromLTRB(offset, 80, offset, 50),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 750, // Set the maximum width for the Dialog
              ),
              child: Padding(
                padding: EdgeInsets.only(
                    top: 20), // Provide space for the image at the top
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    Divider(
                      thickness: 2,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LineTextField(
                          title: 'Display Name',
                          icon: Icons.alternate_email,
                          controller: displayNameController),
                    ),
                    SizedBox(height: 5),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: LineComboBox(
                          selectedValue: _selectedEducationLevel!,
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
                          icon: Icons.school,
                        )),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LineDateField(
                          title: "Birth date",
                          icon: Icons.schedule,
                          controller: birthDateController),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LineTextField(
                          title: "Mobile Phone",
                          icon: Icons.phone,
                          controller: mobilePhoneController),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LineTextField(
                          title: "Occupation",
                          icon: Icons.cases_rounded,
                          controller: occupationController),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: ToggleButton(
                        active: _isPublic,
                        title: "Profile Visibility",
                        optionL: "Private",
                        optionR: "Public",
                        onToggle: (value) {
                          _isPublic = value;
                        },
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.fromLTRB(offset, 20, offset, 0),
                      child: MyTextButton(
                        alignment: Alignment.center,
                        buttonName: 'Save Changes',
                        onTap: () async {
                          String? password;
                          password =
                              await cacheFactory.get('users', 'password');
                          modifyAttributes(
                            password!,
                            _selectedEducationLevel == 'Doctorate'
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
                            birthDateController.text,
                            user.username,
                            displayNameController.text,
                            user.role!,
                            'ACTIVE',
                            _isPublic ? 'PUBLIC' : 'PRIVATE',
                            mobilePhoneController.text,
                            occupationController.text,
                            _showErrorSnackbar,
                          );
                        },
                        bgColor: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        height: 45,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          Positioned(top: -65, child: profilePicture(context)),
          Positioned(
            top: 1,
            right: 1,
            child: IconButton(
              hoverColor:
                  Theme.of(context).secondaryHeaderColor.withOpacity(0.6),
              splashRadius: 20.0,
              icon: Container(
                height: 25,
                width: 25,
                child: Icon(
                  Icons.close,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget textField(TextInputType inputType, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 20.0, height: 1.0),
      keyboardType: inputType,
      decoration: InputDecoration(
        contentPadding:
            EdgeInsets.only(top: 15), // you can control this as you want
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
