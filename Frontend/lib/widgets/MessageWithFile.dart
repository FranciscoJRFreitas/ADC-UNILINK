import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;

class MessageWithFile extends StatefulWidget {
  final String id;
  final String sender;
  final String senderDisplay;
  final int time;
  final bool sentByMe;
  final bool isSystemMessage;
  final String groupId;
  final bool isAdmin;
  final String fileExtension;
  final String message;
  final bool isEdited;

  const MessageWithFile({
    Key? key,
    required this.id,
    required this.sender,
    required this.senderDisplay,
    required this.time,
    required this.sentByMe,
    required this.groupId,
    required this.fileExtension,
    required this.isAdmin,
    this.isSystemMessage = false,
    required this.message,
    required this.isEdited,
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
          child: Text('Edit', style: Theme.of(context).textTheme.bodyLarge),
          value: 'edit',
        ),
        PopupMenuItem(
          child: Text('Download', style: Theme.of(context).textTheme.bodyLarge),
          value: 'download',
        ),
        PopupMenuItem(
          child: Text('Delete', style: Theme.of(context).textTheme.bodyLarge),
          value: 'delete',
        ),
        PopupMenuItem(
          child: Text('Details', style: Theme.of(context).textTheme.bodyLarge),
          value: 'details',
        ),
      ];
    } else if (widget.isAdmin) {
      menuItems = [
        PopupMenuItem(
          child: Text('Download', style: Theme.of(context).textTheme.bodyLarge),
          value: 'download',
        ),
        PopupMenuItem(
          child: Text('Delete', style: Theme.of(context).textTheme.bodyLarge),
          value: 'delete',
        ),
        PopupMenuItem(
          child: Text('Details', style: Theme.of(context).textTheme.bodyLarge),
          value: 'details',
        ),
      ];
    } else if (widget.isAdmin) {
      menuItems = [
        PopupMenuItem(
          child: Text('Download', style: Theme.of(context).textTheme.bodyLarge),
          value: 'download',
        ),
        PopupMenuItem(
          child: Text('Details', style: Theme.of(context).textTheme.bodyLarge),
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
      color: Theme.of(context).hoverColor,
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
          title: Text('Edit Message',
              style: Theme.of(context).textTheme.titleMedium),
          content: TextField(
            style: Theme.of(context).textTheme.bodyLarge,
            onChanged: (value) {
              editedText = value; // Update the edited text
            },
            controller: TextEditingController(text: editedText),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(0, 10, 20, 10),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(92, 161, 161, 161))),
              errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2.0)),
              focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2.0)),
            ), // Set initial value
          ),
          actions: [
            TextButton(
              onPressed: () {
                final DatabaseReference messageRef = FirebaseDatabase.instance
                    .ref()
                    .child('messages')
                    .child(widget.groupId);
                messageRef.child(widget.id).child("message").set(editedText);
                messageRef.child(widget.id).child("isEdited").set(true);

                Navigator.pop(context); // Close the dialog
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
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
          title: Text('Confirm Delete',
              style: Theme.of(context).textTheme.titleMedium),
          content: Text('Are you sure you want to delete this message?',
              style: Theme.of(context).textTheme.bodyLarge),
          actions: [
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
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
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
          title:
              Text('Details', style: Theme.of(context).textTheme.titleMedium),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Username: ${widget.sender}",
                  style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(height: 12), // Add some spacing between lines
              Text(
                  formatDateInMillis(widget.time) +
                      ", " +
                      formatTimeInMillis(widget.time),
                  style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('OK'),
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
                widget.senderDisplay,
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
                  const SizedBox(
                    width: 20,
                  ),
                  if(widget.isEdited)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      formatTimeInMillis(widget.time),
                      style: TextStyle(fontSize: 10, color: Colors.grey),),),
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Text(
                      formatTimeInMillis(widget.time),
                      style: TextStyle(fontSize: 10, color: Colors.grey),
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
    return await FirebaseStorage.instance
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

  // Future<Uint8List?> downloadMessagePictureData(String id) async {
  //   return await FirebaseStorage.instance
  //       .ref(
  //           'GroupAttachements/${widget.groupId}/${id}.${widget.fileExtension}')
  //       .getData()
  //       .onError((error, stackTrace) => null);
  // }

  Future<String?> getImageUrl(String id) async {
    String? url = await FirebaseStorage.instance
        .ref(
            'GroupAttachements/${widget.groupId}/${id}.${widget.fileExtension}')
        .getDownloadURL()
        .onError((error, stackTrace) => "");
    return url;
  }

  Widget picture(BuildContext context) {
    return FutureBuilder<String?>(
      future: getImageUrl(widget.id),
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.hasData) {
          final String imageUrl = snapshot.data!;
          return CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
            imageBuilder: (context, imageProvider) {
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
                              imageProvider: imageProvider,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: IconButton(
                                icon: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
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
                                    size: 24,
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
                child: Image(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              );
            },
          );
        } else {
          return const Icon(
            Icons.image,
            size: 80,
          );
        }
      },
    );
  }

  Widget messageImageWidget(BuildContext context) {
    return InkWell(
      onTap: () {
        //edit image link click as per your need.
      },
      child: Stack(
        children: <Widget>[
          Container(
            child: ClipRRect(
              borderRadius: BorderRadius.horizontal(),
              child: picture(context),
            ),
          ),
        ],
      ),
    );
  }

  String formatDateInMillis(int? timeInMillis) {
    var date = DateTime.fromMillisecondsSinceEpoch(timeInMillis!);
    var formatter = DateFormat('d/M/y');
    return formatter.format(date);
  }

  String formatTimeInMillis(int timeInMillis) {
    var date = DateTime.fromMillisecondsSinceEpoch(timeInMillis);
    var formatter = DateFormat('HH:mm');
    return formatter.format(date);
  }
}
