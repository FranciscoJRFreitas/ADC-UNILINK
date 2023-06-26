import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:unilink2023/presentation/chat_info_page.dart';
import 'package:unilink2023/widgets/CombinedButton.dart';
import 'package:unilink2023/widgets/MessageWithFile.dart';
import 'package:unilink2023/widgets/messageImage.dart';
import '../widgets/MessagePDF.dart';
import '../widgets/message_tile.dart';
import '../domain/Message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class GroupMessagesPage extends StatefulWidget {
  final String groupId;
  final String username;
  final TextEditingController emailUsernameController = TextEditingController();

  GroupMessagesPage({required this.groupId, required this.username});

  @override
  _GroupMessagesPageState createState() => _GroupMessagesPageState();
}

class _GroupMessagesPageState extends State<GroupMessagesPage> {
  TextEditingController messageController = TextEditingController();
  late DatabaseReference messagesRef;
  late List<Message> messages = [];
  late List<String> removedMessages = []; // Add this line
  XFile? pickedFile;
  FilePickerResult? picked;
  late Stream<List<Message>> messageStream;
  final ScrollController _scrollController = ScrollController();
  late int messageCap = 10; //still experiment
  late bool isLoading = false;
  late bool isAdmin = false;
  FocusNode messageFocusNode = FocusNode();
  late final FirebaseMessaging _messaging;
  final GlobalKey<CombinedButtonState> _combinedButtonKey =
      GlobalKey<CombinedButtonState>();

  @override
  void initState() {
    super.initState();

    _messaging = FirebaseMessaging.instance;

    _configureMessaging();

    messageFocusNode.requestFocus();

    // Get a reference to the messages node for the specific group
    messagesRef =
        FirebaseDatabase.instance.ref().child('messages').child(widget.groupId);

    messagesRef
        .orderByKey()
        .limitToLast(messageCap)
        .onChildAdded
        .listen((event) {
      setState(() {
        Message message = Message.fromSnapshot(event.snapshot);
        if (!removedMessages.contains(message.id) &&
            messages.indexWhere((m) => m.id == message.id) == -1) {
          // Check if message was removed or already in the list
          messages.add(message);
        }
      });
      _scrollToBottom();
    });

    messagesRef.onChildChanged.listen((event) {
      setState(() {
        Message updatedMessage = Message.fromSnapshot(event.snapshot);
        int index =
            messages.indexWhere((message) => message.id == updatedMessage.id);
        if (index != -1) {
          // Update the existing message
          messages[index] = updatedMessage;
        }
      });
    });

// Listen for removed messages
    messagesRef.onChildRemoved.listen((event) {
      setState(() {
        Message removedMessage = Message.fromSnapshot(event.snapshot);
        removedMessages.add(removedMessage
            .id); // Add removed message id to removedMessages list
        messages.removeWhere((message) =>
            message.id ==
            removedMessage.id); // remove the message from messages
      });
    });

    DatabaseReference memberRef =
        FirebaseDatabase.instance.ref().child('members').child(widget.groupId);

    memberRef.child(widget.username).once().then((event) {
      bool isAdmin = event.snapshot.value as bool;
      setState(() {
        this.isAdmin = isAdmin;
      });
    });

    memberRef.onChildChanged.listen((event) {
      if (event.snapshot.key == widget.username) {
        setState(() {
          isAdmin = event.snapshot.value as bool;
        });
      }
    });
  }

  void _configureMessaging() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        // Handle your notification, you can show a dialog, a snackbar, etc.
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle when the app is opened from a notification
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    // Clean up the listener
    messageCap = 10;
    messagesRef.onChildAdded.drain();

    _scrollController.dispose();
    messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupId),
        backgroundColor: Color.fromARGB(255, 8, 52, 88),
        actions: [
          IconButton(
            onPressed: () {
               _combinedButtonKey.currentState?.collapseOverlay();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatInfoPage(
                    groupId: widget.groupId,
                    username: widget.username,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.info),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is ScrollEndNotification &&
                    _scrollController.position.pixels == 0) {
                  // Load older messages here
                  isLoading = true;
                  loadOlderMessages();
                }
                return false;
              },
              child: chatMessages(),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              width: MediaQuery.of(context).size.width,
              color: Color.fromARGB(0, 0, 0, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    child: pickedFile != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                                Row(
                                  children: [
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              10,
                                          child: Text(
                                            pickedFile!.name,
                                            textAlign: TextAlign.center,
                                          )),
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
                                          setState(() {
                                            pickedFile = null;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                messageImageWidget(context),
                              ])
                        : picked != null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Align(
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              10,
                                          child: Text(
                                            picked!.files.first.name,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
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
                                            setState(() {
                                              picked = null;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: const Icon(
                                      Icons.insert_drive_file,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              )
                            : const SizedBox(),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: messageController,
                      focusNode: messageFocusNode,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Send a message...",
                        hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                        border: InputBorder.none,
                      ),
                      onFieldSubmitted: (String value) {
                        sendMessage(value);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    onTap: () {
                      sendMessage(messageController.text.isEmpty
                          ? ""
                          : messageController.text);
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  CombinedButton(
                    key: _combinedButtonKey,
                    image: GestureDetector(
                      onTap: () {
                        setState(() {
                          attachImage();
                        });
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    file: GestureDetector(
                      onTap: () {
                        attachFile();
                        setState(() {});
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void loadOlderMessages() {
    // Get the timestamp of the oldest loaded message
    int oldestMessageTimestamp = messages.isEmpty
        ? DateTime.now().millisecondsSinceEpoch
        : messages.first.timestamp;

    // Query the messagesRef for older messages using the startAt() method
    messagesRef
        .orderByChild('timestamp')
        .endAt(oldestMessageTimestamp - 1)
        .limitToLast(messageCap)
        .once()
        .then((msgSnapshot) {
      if (msgSnapshot.snapshot.value != null) {
        // Parse and add the older messages to the messages list
        Map<dynamic, dynamic> messagesData =
            msgSnapshot.snapshot.value as Map<dynamic, dynamic>;
        List<Message> olderMessages = [];
        messagesData.forEach((key, value) {
          Message message =
              Message.fromSnapshot(msgSnapshot.snapshot.child(key));
          if (!messages.contains(message) &&
              !removedMessages.contains(message.id)) {
            // Check if the message is already in the list or in the removedMessages list
            olderMessages.add(message);
          }
        });

        // Add the older messages at the beginning of the messages list
        setState(() {
          messages.insertAll(0, olderMessages);
        });
      }
    });
  }

  chatMessages() {
    if (messages.isEmpty) {
      return Container(); // Return an empty container if there are no messages
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    int? lastTimestamp = 0;

    return ListView.builder(
      controller: _scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        Message message = messages[index];

        if (index != 0) {
          lastTimestamp = messages[index - 1].timestamp;
        }

        List<Widget> widgets = [];

        if (isDifferentDay(lastTimestamp, message.timestamp)) {
          widgets.add(MessageTile(
            message: formatDateInMillis(message.timestamp),
            sender: "",
            time: "",
            isAdmin: false,
            sentByMe: false,
            isSystemMessage: true,
            groupId: widget.groupId,
            id: message.id,
          ));
        }

        widgets.add(message.containsFile
            ? MessageWithFile(
                id: message.id,
                sender: message.name,
                time: formatTimeInMillis(message.timestamp),
                sentByMe: widget.username == message.name,
                groupId: widget.groupId,
                isAdmin: isAdmin,
                fileExtension: message.extension!,
                message: message.text,
              )
            : MessageTile(
                message: message.text,
                sender: message.name,
                time: formatTimeInMillis(message.timestamp),
                sentByMe: widget.username == message.name,
                isSystemMessage: message.isSystemMessage,
                groupId: widget.groupId,
                id: message.id,
                isAdmin: isAdmin,
              ));

        return Column(
          children: widgets,
        );
      },
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

  bool isDifferentDay(int? a, int b) {
    final dateTimeA = DateTime.fromMillisecondsSinceEpoch(a!);
    final dateTimeB = DateTime.fromMillisecondsSinceEpoch(b);
    return a != 0
        ? dateTimeA.year != dateTimeB.year ||
            dateTimeA.month != dateTimeB.month ||
            dateTimeA.day != dateTimeB.day
        : false;
  }

  sendMessage(String content) async {
    if (content.isNotEmpty || picked != null || pickedFile != null) {
      final DatabaseReference messageRef = FirebaseDatabase.instance
          .ref()
          .child('messages')
          .child(widget.groupId);
      DatabaseReference newMessageRef = messageRef.push();
      String? generatedId = newMessageRef.key;
      Map<String, dynamic> messageData;
      if (pickedFile != null) {
        final fileBytes = await pickedFile!.readAsBytes();
        String? extension = pickedFile!.mimeType?.split("/")[1];
        extension == null
            ? extension = pickedFile!.path.split("/").last.split(".")[1]
            : print("Extension was ook");
        final Reference storageReference = FirebaseStorage.instance.ref().child(
            'GroupAttachements/${widget.groupId}/$generatedId.$extension');

        await storageReference.putData(fileBytes);

        messageData = {
          'containsFile': true,
          'extension': extension,
          'message': content,
          'name': widget.username,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'isSystemMessage': false,
        };
      } else if (picked != null) {
        final fileBytes = picked!.files.first.bytes;
        String? extension = picked!.files.first.extension;
        print(
            "----------------------------------------------------------------------------------------------------------------------------------------------");
        print("ola");
        print(picked!.files.first.bytes);
        print(extension);
        print(
            "----------------------------------------------------------------------------------------------------------------------------------------------");

        Reference storageReference = FirebaseStorage.instance.ref().child(
            'GroupAttachements/${widget.groupId}/$generatedId.$extension');

        await storageReference.putData(fileBytes!);
        messageData = {
          'containsFile': true,
          'extension': extension,
          'message': content,
          'name': widget.username,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'isSystemMessage': false,
        };
      } else {
        messageData = {
          'containsFile': false,
          'message': content,
          'name': widget.username,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'isSystemMessage': false,
        };
      }
      messageRef.child(generatedId!).set(messageData).then((value) {
        messageController.clear();
        messageFocusNode.requestFocus();
        pickedFile = null;
        picked = null;
      }).catchError((error) {
        // Handle the error if the message fails to send
        print('Failed to send message: $error');
      });

      Future.delayed(Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() {});
      });
    }
  }

  attachImage() async {
    ImagePicker picker = ImagePicker();

    pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) picked = null;
    setState(() {});
  }

  attachFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      withData: true,
    );
    if (result != null) {
      pickedFile = null;
      picked = result;
    }

    setState(() {});
  }

  Widget picture(BuildContext context) {
    return FutureBuilder<Uint8List?>(
        future: layoutImage(),
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

  Future<Uint8List?> layoutImage() async {
    return await pickedFile!.readAsBytes();
  }

  Widget messageImageWidget(BuildContext context) {
    return InkWell(
      onTap: () {
        //edit image link click as per your need.
      },
      child: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width / 10,
            height: MediaQuery.of(context).size.width / 10,
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
