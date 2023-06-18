import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unilink2023/presentation/chat_info_page.dart';
import '../widgets/message_tile.dart';
import '../domain/Message.dart';

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
  late DatabaseReference chatsRef;
  late DatabaseReference membersRef;
  late DatabaseReference messagesRef;
  late List<Message> messages = [];
  late String desc;
  late List<String> members = [];
  Stream<List<Message>>? messageStream;
  final ScrollController _scrollController = ScrollController();
  late int messageCap = 10; //still experiment
  late bool isLoadning = false;
  FocusNode messageFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    messageFocusNode.requestFocus();
    chatsRef =
        FirebaseDatabase.instance.ref().child('groups').child(widget.groupId);
    chatsRef.once().then((chatSnapshot) {
      Map<dynamic, dynamic> chatsData =
          chatSnapshot.snapshot.value as Map<dynamic, dynamic>;
      desc = chatsData['description'];
    });

    membersRef =
        FirebaseDatabase.instance.ref().child('members').child(widget.groupId);
    membersRef.onChildAdded.listen((event) {
      String memberId = event.snapshot.key as String;
      members.add(memberId);
    });

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
    membersRef.onChildAdded.drain();
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
                    members: members,
                    groupId: widget.groupId,
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
                  isLoadning = true;
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
                        sendMessage(value);
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
          if (!isLoadning) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _scrollToBottom());
          } else {
            isLoadning = false;
          }
          return ListView.builder(
            controller: _scrollController,
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              Message? message = snapshot.data?[index];
              return message != null
                  ? MessageTile(
                      message: message.text,
                      sender: message.name,
                      sentByMe: widget.username == message.name,
                    )
                  : Container();
            },
          );
        } else {
          return Container();
        }
      },
    );
  }

  /*Future<void> inviteGroup(
    BuildContext context,
    String groupId,
    String userId,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    final url = "https://unilink23.oa.r.appspot.com/rest/chat/invite/" +
        groupId +
        "/" +
        userId;

    final response = await http.post(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${json.encode(token.toJson())}'
    });

    if (response.statusCode == 200) {}
  }*/

  sendMessage(String content) {
    final DatabaseReference messageRef =
        FirebaseDatabase.instance.ref().child('messages').child(widget.groupId);
    Map<String, dynamic> messageData = {
      'message': content,
      'name': widget.username,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    messageRef.push().set(messageData).then((value) {
      messageController.clear();
      //Request focus on the message text field
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
}
