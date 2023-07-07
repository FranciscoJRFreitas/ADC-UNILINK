import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:unilink2023/data/cache_factory_provider.dart';
import 'package:unilink2023/features/chat/presentation/chat_info_page.dart';
import 'package:unilink2023/widgets/CombinedButton.dart';
import 'package:unilink2023/widgets/MessageWithFile.dart';
import '../../../constants.dart';
import '../../userManagement/domain/User.dart';
import '../../../widgets/message_tile.dart';
import '../domain/Message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:unilink2023/domain/ThemeNotifier.dart';

class GroupMessagesPage extends StatefulWidget {
  final String groupId;
  final User user;

  final TextEditingController emailUsernameController = TextEditingController();

  GroupMessagesPage({Key? key, required this.groupId, required this.user})
      : super(key: key); // Pass the key to the super constructor

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
  late int messageCap = 10;
  late int cacheMessageCap = 12;
  late bool isLoading = false;
  late bool isAdmin = false;
  FocusNode messageFocusNode = FocusNode();
  late final FirebaseMessaging _messaging;
  final GlobalKey<CombinedButtonState> combinedButtonKey =
      GlobalKey<CombinedButtonState>();
  late bool info = false;
  late bool isScrollLocked = false;

  //late String lastMessageId = '';

  //late CameraDescription camera;

  @override
  void initState() {
    super.initState();

    _messaging = FirebaseMessaging.instance;
    // _initCamera();
    _configureMessaging();
    if (kIsWeb) messageFocusNode.requestFocus();

    // Get a reference to the messages node for the specific group
    messagesRef =
        FirebaseDatabase.instance.ref().child('messages').child(widget.groupId);

    // messagesRef
    //     .orderByKey()
    //     .limitToLast(1)
    //     .once()
    //     .then((event) {
    //   setState(()  {
    //     var valueMap = event.snapshot.value as Map<dynamic, dynamic>; // convert the snapshot value to Map
    //     var lastMessageKey = valueMap.keys.first; // Get the key of the last message
    //     var lastMessageData = valueMap[lastMessageKey];
    //     Message message = Message.fromSnapshotValue(lastMessageKey, lastMessageData);
    //     lastMessageId = message.id;
    //     });
    //   });

    initMessages();
  }

  void initMessages() async {
    messages = await cacheFactory.getMessages(widget.groupId);

    if (messages.isEmpty) {
      // Fetch messages from Firebase if the cache is empty
      messagesRef
          .orderByKey()
          .limitToLast(cacheMessageCap)
          .once()
          .then((event) {
        Map<dynamic, dynamic> valueMap =
            event.snapshot.value as Map<dynamic, dynamic>;

        valueMap.forEach((key, value) {
          Message message = Message.fromMapKey(key, value);
          messages.add(message);
          cacheFactory.setMessages(widget.groupId, message);
        });

        setState(() {});
      });
    }

    messagesRef.orderByKey().onChildAdded.listen((event) {
      if (messages.length >= cacheMessageCap) {
        messages
            .removeAt(0); // remove the oldest message if the limit is reached
      }

      Message message = Message.fromSnapshot(event.snapshot);
      setState(() {
        messages.add(message);
      });

      cacheFactory.setMessages(widget.groupId, message);
    });

    // Listen for updated messages
    messagesRef.onChildChanged.listen((event) {
      setState(() {
        Message updatedMessage = Message.fromSnapshot(event.snapshot);
        int messageIndex =
            messages.indexWhere((message) => message.id == updatedMessage.id);
        if (messageIndex != -1) {
          messages[messageIndex] = updatedMessage;
          cacheFactory.updateMessage(widget.groupId, updatedMessage);
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
        cacheFactory.deleteMessage(widget.groupId, removedMessage.id);
        messages.removeWhere((message) => message.id == removedMessage.id);
      });
    });
    DatabaseReference memberRef =
        FirebaseDatabase.instance.ref().child('members').child(widget.groupId);

    memberRef.child(widget.user.username).once().then((event) {
      bool isAdmin = event.snapshot.value as bool;
      setState(() {
        this.isAdmin = isAdmin;
      });
    });

    memberRef.onChildChanged.listen((event) {
      if (event.snapshot.key == widget.user.username) {
        setState(() {
          isAdmin = event.snapshot.value as bool;
        });
      }
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _configureMessaging() async {
    await _messaging.requestPermission(
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
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _bodyForWeb() {
    return Scaffold(
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
                  Flexible(
                    child: TextFormField(
                      controller: messageController,
                      focusNode: messageFocusNode,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: "Send a message...",
                        hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                        border: InputBorder.none,
                      ),
                      minLines: 5, //Normal textInputField will be displayed
                      maxLines:
                          null, // when user presses enter it will adapt to it
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
                      combinedButtonKey.currentState?.collapseOverlay();
                      sendMessage(messageController.text.isEmpty
                          ? ""
                          : messageController.text);
                      setState(() {});
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
                    key: combinedButtonKey,
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
                    camera: GestureDetector(
                      onTap: () {
                        takePicture();
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
                            Icons.add_a_photo,
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

  Widget _layoutForMobile() {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyLarge!.color,
        ),
        centerTitle: true,
        elevation: 0,
        title: Text(
          widget.groupId,
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              combinedButtonKey.currentState?.collapseOverlay();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatInfoPage(
                    groupId: widget.groupId,
                    username: widget.user.username,
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.info,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: <Widget>[
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (notification is ScrollEndNotification &&
                      _scrollController.position.pixels == 0) {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 16),
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
                        combinedButtonKey.currentState?.collapseOverlay();
                        sendMessage(messageController.text.isEmpty
                            ? ""
                            : messageController.text);
                        setState(() {});
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
                      key: combinedButtonKey,
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
                      camera: GestureDetector(
                        onTap: () {
                          takePicture();
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
                              Icons.add_a_photo,
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
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildLeftWidget(context),
          ),
          if (info == true) ...[
            Container(
              width: 1, // You can adjust the thickness of the divider
              color: Colors.grey, // You can adjust the color of the divider
            ),
            Expanded(
              flex: 1,
              child: ChatInfoPage(
                  groupId: widget.groupId, username: widget.user.username),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeftWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: info || MediaQuery.of(context).size.width <= 600
            ? BackButton(
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    if (info == false) Navigator.pop(context);
                    info = false;
                  });
                },
              )
            : null,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          widget.groupId,
          style: Theme.of(context).textTheme.bodyLarge,
          selectionColor: Colors.white,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          if (!info)
            IconButton(
              onPressed: () {
                setState(() {
                  info = true;
                });
              },
              icon: Icon(
                Icons.info,
                color: Provider.of<ThemeNotifier>(context).currentTheme ==
                        kDarkTheme
                    ? Colors.white70
                    : Theme.of(context).primaryColor,
              ),
            ),
        ],
      ),
      body: _bodyForWeb(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? _buildWebLayout(context) : _layoutForMobile();
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
          isScrollLocked = true;
          messages.insertAll(0, olderMessages);
        });
      }
    });
  }

  chatMessages() {
    if (messages.isEmpty) {
      return Container(); // Return an empty container if there are no messages
    }

    int? lastTimestamp = 0;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.builder(
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
              senderDisplay: "",
              time: 0,
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
                  senderDisplay: message.displayName,
                  time: message.timestamp,
                  sentByMe: widget.user.username == message.name,
                  groupId: widget.groupId,
                  isAdmin: isAdmin,
                  fileExtension: message.extension!,
                  message: message.text,
                )
              : MessageTile(
                  message: message.text,
                  sender: message.name,
                  senderDisplay: message.displayName,
                  time: message.timestamp,
                  sentByMe: widget.user.username == message.name,
                  isSystemMessage: message.isSystemMessage,
                  groupId: widget.groupId,
                  id: message.id,
                  isAdmin: isAdmin,
                ));

          if (!isScrollLocked) _scrollToBottom();

          return Column(
            children: widgets,
          );
        },
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
            : print("Extension was ok");
        final Reference storageReference = FirebaseStorage.instance.ref().child(
            'GroupAttachements/${widget.groupId}/$generatedId.$extension');

        await storageReference.putData(fileBytes);

        messageData = {
          'containsFile': true,
          'extension': extension,
          'message': content,
          'name': widget.user.username,
          'displayName': widget.user.displayName,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'isSystemMessage': false,
        };
      } else if (picked != null) {
        final fileBytes = picked!.files.first.bytes;
        String? extension = picked!.files.first.extension;

        Reference storageReference = FirebaseStorage.instance.ref().child(
            'GroupAttachements/${widget.groupId}/$generatedId.$extension');

        await storageReference.putData(fileBytes!);
        messageData = {
          'containsFile': true,
          'extension': extension,
          'message': content,
          'name': widget.user.username,
          'displayName': widget.user.displayName,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'isSystemMessage': false,
        };
      } else {
        messageData = {
          'containsFile': false,
          'message': content,
          'name': widget.user.username,
          'displayName': widget.user.displayName,
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

      SchedulerBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  takePicture() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      pickedFile = image;
      if (pickedFile != null) picked = null;
    });
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
                                combinedButtonKey.currentState
                                    ?.collapseOverlay();
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

  // Future<void> _initCamera() async {
  //   final cameras = await availableCameras();
  //   camera = cameras.first;
  // }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.file(File(imagePath)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          sendPicture(imagePath);
        },
        child: Icon(Icons.send),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void sendPicture(String imagePath) {}
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            if (!mounted) return;

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
