import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageWithFile extends StatefulWidget {
  final String id;
  final String sender;
  final String time;
  final bool sentByMe;
  final bool isSystemMessage;
  final String groupId;
  final String fileExtension;

  const MessageWithFile({
    Key? key,
    required this.id,
    required this.sender,
    required this.time,
    required this.sentByMe,
    required this.groupId,
    required this.fileExtension,
    this.isSystemMessage = false,
  }) : super(key: key);

  @override
  State<MessageWithFile> createState() => _MessageWithFileState();
}

class _MessageWithFileState extends State<MessageWithFile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: widget.sentByMe ? 0 : 24,
        right: widget.sentByMe ? 24 : 0,
      ),
      alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
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
              widget.sender.toUpperCase(),
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
                profilePicture(context),
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
}

// chatMessages() {
//   return StreamBuilder<List<Message>>(
//       stream: messageStream,
//       builder: (context, AsyncSnapshot<List<Message>> snapshot) {
//         if (snapshot.hasData) {
//           if (!isLoading) {
//             WidgetsBinding.instance
//                 .addPostFrameCallback((_) => _scrollToBottom());
//           } else {
//             isLoading = false;
//           }
//           int? lastTimestamp = 0;
//           return ListView.builder(
//             controller: _scrollController,
//             itemCount: snapshot.data?.length ?? 0,
//             itemBuilder: (context, index) {
//               Message? message = snapshot.data?[index];
//               if (message == null) return Container();

//               if (index != 0) {
//                 lastTimestamp = snapshot.data?[index - 1].timestamp;
//               }

//               List<Widget> widgets = [];

//               if (isDifferentDay(lastTimestamp, message.timestamp)) {
//                 widgets.add(MessageTile(
//                   message: formatDateInMillis(message.timestamp),
//                   sender: "",
//                   time: "",
//                   sentByMe: false,
//                   isSystemMessage: true,
//                 ));
//               }

//               widgets.add(message.containsFile
//                   ? MessageImage(
//                       id: message.id,
//                       extension: message.extension!,
//                       sender: message.name,
//                       time: formatTimeInMillis(message.timestamp),
//                       sentByMe: widget.username == message.name,
//                       isSystemMessage: message.type == "system",
//                       groupId: widget.groupId,
//                     )
//                   : message.type == "attachment"
//                       ? MessageFiles(
//                           id: message.id,
//                           sender: message.name,
//                           time: formatTimeInMillis(message.timestamp),
//                           sentByMe: widget.username == message.name,
//                           groupId: widget.groupId,
//                           fileExtension: message.extension!,
//                         )
//                       : MessageTile(
//                           message: message.text,
//                           sender: message.name,
//                           time: formatTimeInMillis(message.timestamp),
//                           sentByMe: widget.username == message.name,
//                           isSystemMessage: message.type == "system",
//                         ));

//               return Column(
//                 children: widgets,
//               );
//             },
//           );
//         } else
//           return Container();
//       });
// }
