import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:unilink2023/data/web_cookies.dart';
import '../constants.dart';
import '../domain/Token.dart';
import '../domain/User.dart';
import '../widgets/register_page.dart';
import '../widgets/widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screen.dart';
import 'package:unilink2023/domain/cacheFactory.dart' as cache;
import 'dart:io';

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
  final TextEditingController additionalAddressController = TextEditingController();
  final TextEditingController localityController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  late TextEditingController nifController;

  late Future<Uint8List?> profilePic;

  DocumentReference picsRef =
  FirebaseFirestore.instance.collection('ProfilePictures').doc();

  @override
  void initState(){

    displayNameController = TextEditingController(text: widget.user.displayName);
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
    final tokenID = await cache.getValue('users', 'token');
    final storedUsername = await cache.getValue('users', 'username');
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
                    // Here
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
                              icon: Icon(Icons.close,
                                  color: Colors
                                      .white), // Choose your icon and color
                              onPressed: () {
                                Navigator.of(dialogContext)
                                    .pop(); // Use dialogContext here
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Image.memory(snapshot.data!),
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
            child: CircleAvatar(
              backgroundColor: Colors.white70,
              radius: 125,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(200),
                  child: picture(context)),
            ),
          ),
          Positioned(
              bottom: 1,
              right: 1,
              child: Container(
                height: 35,
                width: 35,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: InkWell(
                  onTap: () async {
                    await getImage(true);
                    profilePic = downloadData();
                    setState(() {});
                  },
                  child: const Icon(
                    Icons.add_a_photo,
                    size: 30.0,
                    color: Color(0xFF404040),
                  ),
                ),
              ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.fromLTRB(125, 80, 125, 50),
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(
              Radius.circular(20.0))),
      child: SingleChildScrollView(
          child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned(
                    top: -75,
                    child: profilePicture(context)
                ),
                Column(
                  children: [
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                      child: Text(
                        'Edit Profile',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),

                    /* Container(
                padding: EdgeInsets.fromLTRB(70, 0, 0, 0),
                child: profilePicture(context)
            ),*/
                    SizedBox(width: 16),
                    SizedBox(height: 20),
                    Divider(
                      // Adjusts the divider's vertical extent. The actual divider line is in the middle of the extent.
                      thickness: 5, // Adjusts the divider's thickness.
                      color: Style.lightBlue,
                    ),
                    SizedBox(height: 20),
                    ChangeInfoItem(
                        context, 'Display Name',
                        Icons.alternate_email,
                        displayNameController
                    ),
                    ChangeInfoItem( context,
                        'Email',
                        Icons.mail,
                        emailController
                    ),
                    /*ChangeInfoItem(context,
              title: "Education Level",
              value: widget.user.educationLevel ?? '',
              icon: Icons.school, ), */
                    ChangeInfoItem( context,
                        "Birth date",
                        Icons.schedule,
                        birthDateController
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                      child: InfoItem(
                      title: "Profile Visibility",
                      value: widget.user.profileVisibility ?? '',
                      icon: Icons.public,
                      ),
                    ),
                    ChangeInfoItem(
                        context, "Address",
                        Icons.school,
                        addressController
                    ),
                    ChangeInfoItem(context,
                        "NIF",
                        Icons.school,
                        nifController
                    ),
                    // ...more info items...

                    Container(
                      padding: EdgeInsets.fromLTRB(150, 20, 100, 0),
                      child: MyTextButton(
                          buttonName: 'Save Changes', 
                          onTap: () async {
                            String? password;
                            password = await cache.getValue('users', 'password');

                            print(password);
                            print(nifController.text);
                            modifyAttributes(password!, '', birthDateController.text, widget.user.username, displayNameController.text, emailController.text, 'SU', '', '', '', '', '', '', addressController.text, '', '', '2012-666', nifController.text, '', _showErrorSnackbar, true);
                            
                          }, 
                          bgColor: Style.lightBlue, 
                          textColor: Style.white, 
                          height: 45),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ]),
      )
    );
  }

  Widget ChangeInfoItem(BuildContext context, String title, IconData icon, TextEditingController controller) {
    return Container(
      padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: Icon(
            icon,
            color: Theme.of(context).primaryIconTheme.color,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: textField(TextInputType.name, controller)
    )
    );
  }

  Widget textField(TextInputType inputType, TextEditingController controller ){
    return TextField(
        controller: controller,
        style:  TextStyle(
          fontSize: 20.0,
          height: 1.0),
        keyboardType: inputType,
        );

  }

}


