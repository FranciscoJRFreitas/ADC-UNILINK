import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unilink2023/domain/cacheFactory.dart' as cache;

import '../widgets/message_tile.dart';

class GroupMessagesPage extends StatefulWidget {
  final String groupId;
  final String username;

  GroupMessagesPage({required this.groupId, required this.username});

  @override
  _GroupMessagesPageState createState() => _GroupMessagesPageState();
}

class _GroupMessagesPageState extends State<GroupMessagesPage> {
  TextEditingController messageController = TextEditingController();
  late DatabaseReference messagesRef;
  late List<Message> messages = [];
  Stream<List<Message>>? messageStream;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Get a reference to the messages node for the specific group
    messagesRef =
        FirebaseDatabase.instance.ref().child('messages').child(widget.groupId);
    StreamController<List<Message>> streamController = StreamController();

    // Set up a listener to fetch and update the messages in real-time
    messagesRef.onChildAdded.listen((event) {
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
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500), curve: Curves.easeOut);
    }
  }

  void _jumpToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    // Clean up the listener
    messagesRef.onChildAdded.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupId),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: () {
                // nextScreen(
                //     context,
                //     GroupInfo(
                //       groupId: widget.groupId,
                //       groupName: widget.groupName,
                //       adminName: admin,
                //     ));
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: Stack(
        children: <Widget>[
          // chat messages here
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              width: MediaQuery.of(context).size.width,
              color: Color.fromARGB(255, 28, 42, 172),
              child: Row(children: [
                Expanded(
                    child: TextFormField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Send a message...",
                    hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                    border: InputBorder.none,
                  ),
                )),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  //Add enter event listener to send message
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
                    )),
                  ),
                )
              ]),
            ),
          )
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder<List<Message>>(
      stream: messageStream,
      builder: (context, AsyncSnapshot<List<Message>> snapshot) {
        return snapshot.hasData
            ? ListView.builder(
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
              )
            : Container();
      },
    );
  }

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
    }).catchError((error) {
      // Handle the error if the message fails to send
      print('Failed to send message: $error');
    });
    messageController.clear();
  }
}

class Message {
  final String id;
  final String text;
  final String name;
  final int timestamp;

  Message({
    required this.id,
    required this.text,
    required this.name,
    required this.timestamp,
  });

  factory Message.fromSnapshot(DataSnapshot snapshot) {
    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    return Message(
      id: snapshot.key!,
      text: data['message'] as String,
      name: data['name'] as String,
      timestamp: data['timestamp'] as int,
    );
  }
}
