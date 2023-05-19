import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import '../constants.dart';
import '../domain/User.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({required this.user, required Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User _currentUser;
  late Future<Uint8List?> profilePic;

  void initState() {
    super.initState();

    profilePic = downloadData();
  }

  DocumentReference picsRef =
      FirebaseFirestore.instance.collection('ProfilePictures').doc();

  Future<Uint8List?> downloadData() async {
    return FirebaseStorage.instance
        .ref('ProfilePictures/' + _currentUser.username)
        .getData()
        .onError((error, stackTrace) => null);
  }

  Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();

    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    final fileBytes = await pickedFile!.readAsBytes();

    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('ProfilePictures/' + _currentUser.username);

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
              size: 80,
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
          Positioned(
              bottom: 1,
              right: 1,
              child: Container(
                height: 25,
                width: 25,
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
                    size: 15.0,
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
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {},
          ),
        ],
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
                    widget.user.displayName,
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
            Text('User Info', style: Theme.of(context).textTheme.titleMedium),
            InfoItem(
              title: 'Role',
              value: widget.user.role ?? 'N/A',
              icon: Icons.person,
            ),
            SizedBox(height: 20),
            Divider(
              // Adjusts the divider's vertical extent. The actual divider line is in the middle of the extent.
              thickness: 1, // Adjusts the divider's thickness.
              color: Style.lightBlue,
            ),
            SizedBox(height: 20),
            Text(
              'Dados Pessoais',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 20),
            InfoItem(
              title: 'Username',
              value: widget.user.username,
              icon: Icons.alternate_email,
            ),
            InfoItem(
              title: 'Email',
              value: widget.user.email,
              icon: Icons.mail,
            ),
            InfoItem(
                title: "Education Level",
                value: widget.user.educationLevel ?? '',
                icon: Icons.school),
            InfoItem(
                title: "Birth date",
                value: widget.user.birthDate ?? '',
                icon: Icons.schedule),
            InfoItem(
                title: "Profile Visibility",
                value: widget.user.profileVisibility ?? '',
                icon: Icons.public),
            InfoItem(
                title: "Address",
                value: widget.user.address ?? '',
                icon: Icons.school),
            InfoItem(
                title: "NIF", value: widget.user.nif ?? '', icon: Icons.school),
            // ...more info items...
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
