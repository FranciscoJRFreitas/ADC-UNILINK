import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../constants.dart';
import '../../domain/User.dart';

class ProfilePage extends StatelessWidget {
  final User user;
  final bool isNotUser;

  ProfilePage({required this.user, required this.isNotUser});

  Future<Uint8List?> downloadData(String username) async {
    return FirebaseStorage.instance
        .ref('ProfilePictures/' + username)
        .getData()
        .onError((error, stackTrace) => null);
  }

  Widget picture(BuildContext context) {
    return FutureBuilder<Uint8List?>(
        future: downloadData(user.username),
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
                                  shape: BoxShape.circle,
                                  // use circle if the icon is circular
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
              child: Container(
                width: 80.0, // Set your desired width
                height: 80.0, // and height
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: MemoryImage(snapshot.data!),
                  ),
                ),
              ),
            );
          } else {
            return Icon(
              Icons.account_circle,
              color: Theme.of(context).secondaryHeaderColor,
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor, //roleColor,
        title: Text(
          "User Information",
          style: Theme.of(context).textTheme.bodyLarge,
          selectionColor: Colors.white,
        ),
        centerTitle: true,
      ),
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
                    user.displayName,
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
              value: user.role ?? 'N/A',
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
            ]),
            SizedBox(height: 20),
            InfoItem(
              title: 'Username',
              value: user.username,
              icon: Icons.alternate_email,
            ),
            InfoItem(
              title: 'Email',
              value: user.email,
              icon: Icons.mail,
            ),
            InfoItem(
              title: "Education Level",
              value: user.educationLevel == 'D'
                  ? 'Doctorate'
                  : user.educationLevel == 'SE'
                      ? 'Secondary Education'
                      : user.educationLevel == 'UD'
                          ? 'Undergraduate Degree'
                          : user.educationLevel == 'MD'
                              ? 'Master\'s Degree'
                              : user.educationLevel == 'PE'
                                  ? 'Primary Education'
                                  : '',
              icon: Icons.school,
            ),
            InfoItem(
              title: "Birth date",
              value: user.birthDate ?? '',
              icon: Icons.schedule,
            ),
            InfoItem(
              title: "Mobile Phone",
              value: user.mobilePhone ?? '',
              icon: Icons.phone,
            ),
            InfoItem(
              title: "Occupation",
              value: user.occupation ?? '',
              icon: Icons.cases_rounded,
            ),
            InfoItem(
              title: "Profile Visibility",
              value: user.profileVisibility ?? '',
              icon: Icons.public,
            ),
            InfoItem(
              title: "Account Creation Date",
              value: user.creationTime ?? '',
              icon: Icons.app_registration_rounded,
            ),
          ],
        ),
      ),
    );
  }
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
