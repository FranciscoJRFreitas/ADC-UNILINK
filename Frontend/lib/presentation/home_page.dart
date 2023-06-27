import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:unilink2023/presentation/edit_profile_page.dart';
import 'package:unilink2023/widgets/my_text_button.dart';
import '../constants.dart';
import '../domain/UserNotifier.dart';
import '../domain/User.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User _currentUser;

  DocumentReference picsRef =
      FirebaseFirestore.instance.collection('ProfilePictures').doc();

  @override
  void initState() {
    super.initState();
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
                              icon: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape
                                      .circle, // use circle if the icon is circular
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
                              ), // Choose your icon and color
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
              size: 80,
            );
          }
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
            width: 80,
            height: 80,
            child: CircleAvatar(
              backgroundColor: Colors.white70,
              radius: 20,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(200),
                  child: picture(context)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserNotifier>(context);
    _currentUser = userProvider.currentUser!;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Row(
              children: [
                profilePicture(context),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _currentUser.displayName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(
              // Adjusts the divider's vertical extent. The actual divider line is in the middle of the extent.
              thickness: 1, // Adjusts the divider's thickness.
              color: Style.lightBlue,
            ),
            SizedBox(height: 10),
            InfoItem(
              title: 'Role',
              value: _currentUser.role ?? 'N/A',
              icon: Icons.person,
            ),
            SizedBox(height: 5),
            Divider(
              // Adjusts the divider's vertical extent. The actual divider line is in the middle of the extent.
              thickness: 1, // Adjusts the divider's thickness.
              color: Style.lightBlue,
            ),
            SizedBox(height: 20),
            Row(children: [
              Text(
                'Profile Information',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Container(
                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  child: SizedBox(
                      height: 35,
                      width: 100,
                      child: MyTextButton(
                        buttonName: 'Edit Profile',
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return EditProfilePage(user: _currentUser);
                              });
                        },
                        bgColor: Style.lightBlue,
                        textColor: Style.white,
                        height: 60,
                      )))
            ]),
            SizedBox(height: 20),
            InfoItem(
              title: 'Username',
              value: _currentUser.username,
              icon: Icons.alternate_email,
            ),
            InfoItem(
              title: 'Email',
              value: _currentUser.email,
              icon: Icons.mail,
            ),
            InfoItem(
              title: "Education Level",
              value: _currentUser.educationLevel == 'D'
                  ? 'Doctorate'
                  : _currentUser.educationLevel == 'SE'
                      ? 'Secondary Education'
                      : _currentUser.educationLevel == 'UD'
                          ? 'Undergraduate Degree'
                          : _currentUser.educationLevel == 'MD'
                              ? 'Master\'s Degree'
                              : _currentUser.educationLevel == 'PE'
                                  ? 'Primary Education'
                                  : '',
              icon: Icons.school,
            ),
            InfoItem(
              title: "Birth date",
              value: _currentUser.birthDate ?? '',
              icon: Icons.schedule,
            ),
            InfoItem(
              title: "Mobile Phone",
              value: _currentUser.mobilePhone ?? '',
              icon: Icons.phone,
            ),
            InfoItem(
              title: "Occupation",
              value: _currentUser.occupation ?? '',
              icon: Icons.cases_rounded,
            ),
            InfoItem(
              title: "Profile Visibility",
              value: _currentUser.profileVisibility ?? '',
              icon: Icons.public,
            ),
            InfoItem(
              title: "Account Creation Date",
              value: _currentUser.creationTime ?? '',
              icon: Icons.app_registration_rounded,
            ),
          ],
        ),
      ),
    );
  }

  //Widget editBuild(BuildContext context) {
  //return
  //}
}

class InfoItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  InfoItem({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).primaryIconTheme.color,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
