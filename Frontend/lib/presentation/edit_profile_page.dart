import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import '../constants.dart';
import '../data/cache_factory_provider.dart';
import '../domain/Token.dart';
import '../domain/User.dart';
import '../widgets/ToggleButton.dart';
import '../widgets/widget.dart';
import '../widgets/LineTextField.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screen.dart';

class EditProfilePage extends StatefulWidget {
  final User user;
  final Function(User) onUserUpdate;

  EditProfilePage({required this.user, required this.onUserUpdate});

  @override
  _EditProfilePage createState() => _EditProfilePage();
}

class _EditProfilePage extends State<EditProfilePage> {
  bool passwordVisibility = true;

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController targetUsernameController =
      TextEditingController();
  late TextEditingController displayNameController;
  late TextEditingController emailController;
  String _selectedProfileVisibility = 'Profile Visibility';
  String sv = '';
  String _selectedUserRole = 'User Role';
  String sr = '';
  String _selectedActivityState = 'Activity State';
  String sa = '';
  String _selectedEducationLevel = 'Education Level';
  late TextEditingController birthDateController;
  final TextEditingController landlinePhoneController = TextEditingController();
  final TextEditingController mobilePhoneController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController workplaceController = TextEditingController();
  late TextEditingController addressController;
  final TextEditingController additionalAddressController =
      TextEditingController();
  final TextEditingController localityController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  late TextEditingController nifController;

  late Future<Uint8List?> profilePic;

  DocumentReference picsRef =
      FirebaseFirestore.instance.collection('ProfilePictures').doc();

  @override
  void initState() {
    displayNameController =
        TextEditingController(text: widget.user.displayName);
    emailController = TextEditingController(text: widget.user.email);
    birthDateController = TextEditingController(text: widget.user.birthDate);
    addressController = TextEditingController(text: widget.user.address);
    nifController = TextEditingController(text: widget.user.nif);

    profilePic = downloadData();
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

      if (responseBody['username'] == widget.user.username) {
        if (widget.onUserUpdate != null) {
          widget.onUserUpdate(user);
          if (redirect) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(user: user)),
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

  Future<Uint8List?> downloadData() async {
    return FirebaseStorage.instance
        .ref('ProfilePictures/' + widget.user.username)
        .getData()
        .onError((error, stackTrace) => null);
  }

  Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();

    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    final fileBytes = await pickedFile!.readAsBytes();

    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('ProfilePictures/' + widget.user.username);

    await storageReference.putData(fileBytes);
    setState(() {});
  }

  Widget picture(BuildContext context) {
    return FutureBuilder<Uint8List?>(
        future: profilePic,
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
                    profilePic = downloadData();
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
    bool _isPublic = widget.user.profileVisibility!.toLowerCase() == 'public';
    double offset = MediaQuery.of(context).size.width * 0.1;
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
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LineTextField(
                          title: 'Display Name',
                          icon: Icons.alternate_email,
                          controller: displayNameController),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LineTextField(
                          title: 'Email',
                          icon: Icons.mail,
                          controller: emailController),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LineTextField(
                          title: "Birth date",
                          icon: Icons.schedule,
                          controller: birthDateController),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LineTextField(
                          title: "Address",
                          icon: Icons.home,
                          controller: addressController),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LineTextField(
                          title: "NIF",
                          icon: Icons.perm_identity,
                          controller: nifController),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: ToggleButton(
                          active: _isPublic,
                          title: "Profile Visibility",
                          optionL: "Private",
                          optionR: "Public"),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(offset, 20, offset, 0),
                      child: MyTextButton(
                        alignment: Alignment.center,
                        buttonName: 'Save Changes',
                        onTap: () async {
                          String? password;
                          password =
                              await cacheFactory.get('users', 'password');
                          print(password);
                          print(nifController.text);
                          modifyAttributes(
                              password!,
                              '',
                              birthDateController.text,
                              widget.user.username,
                              displayNameController.text,
                              emailController.text,
                              'SU',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '',
                              addressController.text,
                              '',
                              '',
                              '2012-666',
                              nifController.text,
                              '',
                              _showErrorSnackbar,
                              true);
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
