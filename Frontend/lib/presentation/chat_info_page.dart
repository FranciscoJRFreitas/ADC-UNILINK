import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:unilink2023/presentation/chat_msg_page.dart';
import '../constants.dart';
import '../domain/Group.dart';
import '../data/cache_factory_provider.dart';
import '../widgets/my_text_button.dart';
import 'screen.dart';

class ChatInfoPage extends StatefulWidget {
  final List<String> members;
  final String groupId;
  ChatInfoPage({required this.members, required this.groupId});

  @override
  State<ChatInfoPage> createState() => _ChatInfoPageState();
}

class _ChatInfoPageState extends State<ChatInfoPage> {
  late Future<Uint8List?> groupPic;
  @override
  void initState() {
    super.initState();
    groupPic = downloadGroupPictureData();
  }

  Future<Uint8List?> downloadGroupPictureData() async {
    return FirebaseStorage.instance
        .ref('GroupPictures/' + widget.groupId)
        .getData()
        .onError((error, stackTrace) => null);
  }

  Widget groupPicture(BuildContext context) {
    return FutureBuilder<Uint8List?>(
        future: groupPic,
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
                  child: groupPicture(context)),
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
          centerTitle: true,
          elevation: 0,
          title: Text(widget.groupId),
          backgroundColor: Color.fromARGB(255, 8, 52, 88),
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
                      widget.groupId,
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
              //Text('User Info', style: Theme.of(context).textTheme.titleMedium),
              InfoItem(
                title: 'Admin',
                value: widget.groupId ?? 'N/A',
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
                  '${widget.members.length} Participants',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: SizedBox(
                        height: 30,
                        width: 100,
                        child: MyTextButton(
                          buttonName: 'Add',
                          onTap: () {
                            // showDialog(
                            //     context: context,
                            //     builder: (BuildContext context) {
                            //       return EditProfilePage(
                            //         user: widget.user,
                            //         onUserUpdate: (updatedUser) {
                            //           setState(() {
                            //             _currentUser = updatedUser;
                            //           });
                            //         },
                            //       );
                            //     });
                          },
                          bgColor: Style.lightBlue,
                          textColor: Style.white,
                          height: 60,
                        )))
              ]),
              SizedBox(height: 20),
              //...more info items...
              // Container(
              //     padding: EdgeInsets.only(top: 10, bottom: 80),
              //     child: ListView.builder(
              //         itemCount: widget.members.length,
              //         itemBuilder: (context, index) {
              //           String memberName = widget.members[index];
              //           print(memberName);
              //           return GestureDetector(
              //             onTap: () {},
              //             child: Card(
              //               shape: RoundedRectangleBorder(
              //                   borderRadius: BorderRadius.circular(10)),
              //               elevation: 5,
              //               margin: EdgeInsets.symmetric(vertical: 8),
              //               child: Padding(
              //                 padding: EdgeInsets.symmetric(
              //                     vertical: 10, horizontal: 8),
              //                 child: ListTile(
              //                   //leading: picture(context, memberName),
              //                   title: Text(
              //                     '${memberName}',
              //                     style: TextStyle(fontWeight: FontWeight.bold),
              //                   ),
              //                   subtitle: Column(
              //                     crossAxisAlignment: CrossAxisAlignment.start,
              //                     children: [
              //                       SizedBox(height: 8),
              //                       Row(
              //                         children: [
              //                           Icon(Icons.person, size: 20),
              //                           SizedBox(width: 5),
              //                           Text('Username: ${memberName}'),
              //                         ],
              //                       ),
              //                       // ... Add other information rows with icons here
              //                       // Make sure to add some spacing (SizedBox) between rows for better readability
              //                     ],
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           );
              //         }))
            ],
          ),
        ));
  }

  // Future<Uint8List?> downloadData(String username) async {
  //   return FirebaseStorage.instance
  //       .ref('ProfilePictures/' + username)
  //       .getData()
  //       .onError((error, stackTrace) => null);
  // }

  // Widget picture(BuildContext context, String username) {
  //   return FutureBuilder<Uint8List?>(
  //       future: downloadData(username),
  //       builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
  //         if (snapshot.hasData) {
  //           return GestureDetector(
  //             onTap: () {
  //               showDialog(
  //                 context: context,
  //                 builder: (BuildContext dialogContext) {
  //                   // Here
  //                   return Dialog(
  //                     child: Stack(
  //                       alignment: Alignment.topRight,
  //                       children: [
  //                         PhotoView(
  //                           imageProvider: MemoryImage(snapshot.data!),
  //                         ),
  //                         Padding(
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: IconButton(
  //                             icon: Container(
  //                               decoration: BoxDecoration(
  //                                 shape: BoxShape
  //                                     .circle, // use circle if the icon is circular
  //                                 boxShadow: [
  //                                   BoxShadow(
  //                                     color: Colors.black,
  //                                     blurRadius: 15.0,
  //                                     spreadRadius: 2.0,
  //                                   ),
  //                                 ],
  //                               ),
  //                               child: Icon(
  //                                 Icons.close,
  //                                 color: Colors.white,
  //                               ),
  //                             ),
  //                             onPressed: () {
  //                               Navigator.of(dialogContext)
  //                                   .pop(); // Use dialogContext here
  //                             },
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 },
  //               );
  //             },
  //             child: Image.memory(snapshot.data!),
  //           );
  //         } else {
  //           return const Icon(
  //             Icons.account_circle,
  //             size: 50,
  //           );
  //         }
  //         return const CircularProgressIndicator();
  //       });
  // }
}
