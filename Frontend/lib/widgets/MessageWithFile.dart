import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageWithFile extends StatefulWidget {
  final String id;
  final String sender;
  final String time;
  final bool sentByMe;
  final bool isSystemMessage;
  final String groupId;
  final bool isAdmin;
  final String fileExtension;
  final String message;

  const MessageWithFile({
    Key? key,
    required this.id,
    required this.sender,
    required this.time,
    required this.sentByMe,
    required this.groupId,
    required this.fileExtension,
    required this.isAdmin,
    this.isSystemMessage = false,
    required this.message,
  }) : super(key: key);

  @override
  State<MessageWithFile> createState() => _MessageWithFileState();
}

class _MessageWithFileState extends State<MessageWithFile> {
  Offset? _tapPosition;

  void _showContextMenu(BuildContext context) {
    setState(() {});

    final List<PopupMenuEntry<dynamic>> menuItems;
    if (widget.sentByMe) {
      menuItems = [
        PopupMenuItem(
          child: Text('Edit'),
          value: 'edit',
        ),
        PopupMenuItem(
          child: Text('Download'),
          value: 'download',
        ),
        PopupMenuItem(
          child: Text('Delete'),
          value: 'delete',
        ),
        PopupMenuItem(
          child: Text('Details'),
          value: 'details',
        ),
      ];
    } else if (widget.isAdmin) {
      menuItems = [
        PopupMenuItem(
          child: Text('Download'),
          value: 'download',
        ),
        PopupMenuItem(
          child: Text('Delete'),
          value: 'delete',
        ),
        PopupMenuItem(
          child: Text('Details'),
          value: 'details',
        ),
      ];
    } else {
      menuItems = [
        PopupMenuItem(
          child: Text('Download'),
          value: 'download',
        ),
        PopupMenuItem(
          child: Text('Details'),
          value: 'details',
        ),
      ];
    }

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromCenter(
          center: _tapPosition!,
          width: 0,
          height: 0,
        ),
        Offset.zero & MediaQuery.of(context).size,
      ),
      items: menuItems,
    ).then((value) {
      // Handle menu item selection
      if (value == 'edit') {
        _handleEdit();
      } else if (value == 'delete') {
        _handleDelete();
      } else if (value == 'details') {
        _handleDetails();
      } else if (value == 'download') {
        _handleDownload();
      }

      setState(() {});
    });
  }

  void _handleEdit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String editedText = widget.message; // Holds the edited text

        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text('Edit Message'),
          content: TextField(
            onChanged: (value) {
              editedText = value; // Update the edited text
            },
            controller:
                TextEditingController(text: editedText), // Set initial value
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final DatabaseReference messageRef = FirebaseDatabase.instance
                    .ref()
                    .child('messages')
                    .child(widget.groupId);
                messageRef.child(widget.id).child("message").set(editedText);

                Navigator.pop(context); // Close the dialog
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final storageRef = FirebaseStorage.instance.ref(
                    'GroupAttachements/${widget.groupId}/${widget.id}.${widget.fileExtension}');
                await storageRef.delete();
                final DatabaseReference messageRef = FirebaseDatabase.instance
                    .ref()
                    .child('messages')
                    .child(widget.groupId);
                messageRef.child(widget.id).remove();

                Navigator.pop(context); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _handleDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text('Details'),
          content: Text("Username : ${widget.sender}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void _handleDownload() {
    openFile(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        if (!kIsWeb) {
          _tapPosition = details.globalPosition;
        }
      },
      onLongPress: () {
        if (!kIsWeb) {
          _showContextMenu(context);
        }
      },
      onSecondaryTapDown: (TapDownDetails details) {
        _tapPosition = details.globalPosition;
        _showContextMenu(context);
      },
      child: Container(
        padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.sentByMe ? 0 : 24,
          right: widget.sentByMe ? 24 : 0,
        ),
        alignment:
            widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: widget.sentByMe
              ? const EdgeInsets.only(left: 30)
              : const EdgeInsets.only(right: 30),
          padding: const EdgeInsets.only(
            top: 17,
            bottom: 17,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            borderRadius: widget.sentByMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
            color: widget.sentByMe
                ? Theme.of(context).primaryColor
                : Colors.grey[700],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.sender,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Wrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  Column(children: [
                    if (widget.fileExtension == 'png' ||
                        widget.fileExtension == 'jpeg' ||
                        widget.fileExtension == 'jpg')
                      messageImageWidget(context)
                    else
                      profilePicture(context),
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ]),

                  //profilePicture(context),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      widget.time,
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Uint8List?> downloadFileData(String id) async {
    return FirebaseStorage.instance
        .ref('GroupAttachements/${widget.groupId}/$id.${widget.fileExtension}')
        .getData()
        .onError((error, stackTrace) => null);
  }

  void openFile(String id) async {
    final url = await FirebaseStorage.instance
        .ref('GroupAttachements/${widget.groupId}/$id.${widget.fileExtension}')
        .getDownloadURL();
    if (await canLaunch(url)) {
      final headers = <String, String>{
        'Content-Type': 'application/octet-stream',
      };
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: headers,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget fileIcon(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: downloadFileData(widget.id),
      builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
        if (snapshot.hasData) {
          return GestureDetector(
              onTap: () => openFile(widget.id),
              child: const Icon(
                Icons.insert_drive_file,
                size: 48,
                color: Colors.white,
              ));
        } else {
          return const Icon(
            Icons.insert_drive_file,
            size: 48,
            color: Colors.white,
          );
        }
      },
    );
  }

  Widget profilePicture(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle file preview or open action here
      },
      child: Stack(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: fileIcon(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List?> downloadMessagePictureData(String id) async {
    return FirebaseStorage.instance
        .ref(
            'GroupAttachements/${widget.groupId}/${id}.${widget.fileExtension}')
        .getData()
        .onError((error, stackTrace) => null);
  }

  Widget picture(BuildContext context) {
    return FutureBuilder<Uint8List?>(
        future: downloadMessagePictureData(widget.id),
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
                                      .rectangle, // use circle if the icon is circular
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
              Icons.image,
              size: 80,
            );
          }
        });
  }

  Widget messageImageWidget(BuildContext context) {
    return InkWell(
      onTap: () {
        //edit image link click as per your need.
      },
      child: Stack(
        children: <Widget>[
          Container(
            width: 80,
            height: 80,
            child: Container(
              child: ClipRRect(
                  borderRadius: BorderRadius.horizontal(),
                  child: picture(context)),
            ),
          ),
        ],
      ),
    );
  }
}
