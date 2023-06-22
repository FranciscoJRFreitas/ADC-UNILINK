import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:unilink2023/presentation/chat_info_page.dart';
import 'package:unilink2023/widgets/messageImage.dart';
import '../widgets/MessagePDF.dart';
import '../widgets/message_tile.dart';
import '../domain/Message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  PlatformFile? pickedFile;
  Stream<List<Message>>? messageStream;
  final ScrollController _scrollController = ScrollController();
  late int messageCap = 10; //still experiment
  late bool isLoading = false;
  late bool isAdmin = false;
  FocusNode messageFocusNode = FocusNode();
  late final FirebaseMessaging _messaging;

  @override
  void initState() {
    super.initState();

    _messaging = FirebaseMessaging.instance;

    _configureMessaging();

    messageFocusNode.requestFocus();

    // Get a reference to the messages node for the specific group
    messagesRef =
        FirebaseDatabase.instance.ref().child('messages').child(widget.groupId);
    StreamController<List<Message>> streamController = StreamController();

    // Set up a listener to fetch and update the messages in real-time
    messagesRef.limitToLast(messageCap).onChildAdded.listen((event) {
      setState(() {
        // Parse the data snapshot into a Message object
        Message message = Message.fromSnapshot(event.snapshot);
        // Add the message to the list
        messages.add(message);
        streamController.add(messages);
        messageStream = streamController.stream;
      });
      _scrollToBottom();
    });

    messagesRef.onChildChanged.listen((event) {
      setState(() {
        // Parse the data snapshot into a Message object
        Message updatedMessage = Message.fromSnapshot(event.snapshot);
        // Find the index of the message in the list
        int index =
            messages.indexWhere((message) => message.id == updatedMessage.id);
        if (index >= 0) {
          // Replace the existing message with the updated message
          messages[index] = updatedMessage;
          streamController.add(messages);
        }
      });
    });

    messagesRef.onChildRemoved.listen((event) {
      setState(() {
        // Parse the data snapshot into a Message object
        Message removedMessage = Message.fromSnapshot(event.snapshot);
        // Remove the message from the list
        messages.removeWhere((message) => message.id == removedMessage.id);
        streamController.add(messages);
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
                children: [
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
                        if (value != "") sendMessage(value);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    onTap: () {
                      sendMessage(messageController.text);
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
                  GestureDetector(
                    onTap: () {
                      sendImageMessage();
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
                  const SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    onTap: () {
                      sendFileMessage();
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
          olderMessages.add(message);
        });

        // Add the older messages at the beginning of the messages list
        setState(() {
          messages.insertAll(0, olderMessages);
        });
      }
    });
  }

  chatMessages() {
    return StreamBuilder<List<Message>>(
        stream: messageStream,
        builder: (context, AsyncSnapshot<List<Message>> snapshot) {
          if (snapshot.hasData) {
            if (!isLoading) {
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _scrollToBottom());
            } else {
              isLoading = false;
            }
            int? lastTimestamp = 0;
            return ListView.builder(
              controller: _scrollController,
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                Message? message = snapshot.data?[index];
                if (message == null) return Container();

                if (index != 0) {
                  lastTimestamp = snapshot.data?[index - 1].timestamp;
                }

                List<Widget> widgets = [];

                if (isDifferentDay(lastTimestamp, message.timestamp)) {
                  widgets.add(MessageTile(
                    id: message.id,
                    groupId: widget.groupId,
                    message: formatDateInMillis(message.timestamp),
                    sender: "",
                    time: "",
                    isAdmin: false,
                    sentByMe: false,
                    isSystemMessage: true,
                  ));
                }

                widgets.add(message.type == 'media'
                    ? MessageImage(
                        id: message.id,
                        extension: message.extension!,
                        sender: message.name,
                        time: formatTimeInMillis(message.timestamp),
                        sentByMe: widget.username == message.name,
                        isSystemMessage: message.type == "system",
                        groupId: widget.groupId,
                      )
                    : message.type == "attachment"
                        ? MessageFiles(
                            id: message.id,
                            sender: message.name,
                            time: formatTimeInMillis(message.timestamp),
                            sentByMe: widget.username == message.name,
                            groupId: widget.groupId,
                            fileExtension: message.extension!,
                          )
                        : MessageTile(
                            id: message.id,
                            groupId: widget.groupId,
                            message: message.text,
                            sender: message.name,
                            time: formatTimeInMillis(message.timestamp),
                            isAdmin: isAdmin,
                            sentByMe: widget.username == message.name,
                            isSystemMessage: message.type == "system",
                          ));

                return Column(
                  children: widgets,
                );
              },
            );
          } else
            return Container();
        });
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

  sendMessage(String content) {
    final DatabaseReference messageRef =
        FirebaseDatabase.instance.ref().child('messages').child(widget.groupId);
    Map<String, dynamic> messageData = {
      'type': 'text',
      'ending': "text",
      'message': content,
      'name': widget.username,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    messageRef.push().set(messageData).then((value) {
      messageController.clear();
      messageFocusNode.requestFocus();
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
    });
  }

  sendImageMessage() async {
    final DatabaseReference messageRef =
        FirebaseDatabase.instance.ref().child('messages').child(widget.groupId);
    DatabaseReference newMessageRef = messageRef.push();
    String? generatedId = newMessageRef.key;

    ImagePicker picker = ImagePicker();

    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    final fileBytes = await pickedFile!.readAsBytes();
    String? extension = pickedFile.mimeType?.split("/")[1];
    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('GroupAttachements/${widget.groupId}/$generatedId.$extension');

    await storageReference.putData(fileBytes);
    setState(() {});
    Map<String, dynamic> messageData = {
      'type': "media",
      'ending': extension,
      'message': generatedId,
      'name': widget.username,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    messageRef
        .child(generatedId!)
        .set(messageData)
        .then((value) {})
        .catchError((error) {
      // Handle the error if the message fails to send
      print('Failed to send attachment message: $error');
    });

    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  sendFileMessage() async {
    final DatabaseReference messageRef =
        FirebaseDatabase.instance.ref().child('messages').child(widget.groupId);
    DatabaseReference newMessageRef = messageRef.push();
    String? generatedId = newMessageRef.key;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    String? extension;
    if (result != null && result.files.isNotEmpty) {
      final fileBytes = result.files.first.bytes;
      extension = result.files.first.extension;
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('GroupAttachements/${widget.groupId}/$generatedId.$extension');

      await storageReference.putData(fileBytes!);

      setState(() {});
    }
    Map<String, dynamic> messageData = {
      'type': 'attachment',
      'ending': extension,
      'message': generatedId,
      'name': widget.username,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    if (extension != null) {
      messageRef
          .child(generatedId!)
          .set(messageData)
          .then((value) {})
          .catchError((error) {
        // Handle the error if the message fails to send
        print('Failed to send attachment message: $error');
      });
    }
    ;

    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }
}
