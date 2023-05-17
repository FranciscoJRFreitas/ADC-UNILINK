import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class GroupMessagesPage extends StatefulWidget {
  final String groupId;

  GroupMessagesPage({required this.groupId});

  @override
  _GroupMessagesPageState createState() => _GroupMessagesPageState();
}

class _GroupMessagesPageState extends State<GroupMessagesPage> {
  late DatabaseReference messagesRef;
  late List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    // Get a reference to the messages node for the specific group
    messagesRef =
        FirebaseDatabase.instance.ref().child('messages').child(widget.groupId);

    // Set up a listener to fetch and update the messages in real-time
    messagesRef.onChildAdded.listen((event) {
      setState(() {
        // Parse the data snapshot into a Message object
        Message message = Message.fromSnapshot(event.snapshot);
        // Add the message to the list
        messages.add(message);
      });
    });
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
        title: Text('Group Messages'),
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          Message message = messages[index];
          return ListTile(
            title: Text(message.text),
            subtitle: Text('Sent by: ${message.name}'),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('ID: ${message.id}'),
                Text('Timestamp: ${message.timestamp}'),
              ],
            ),
          );
        },
      ),
    );
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
