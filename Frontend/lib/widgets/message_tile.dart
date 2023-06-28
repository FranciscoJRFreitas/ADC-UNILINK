import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageTile extends StatefulWidget {
  final String groupId;
  final String id;
  final String message;
  final String sender;
  final String senderDisplay;
  final int time;
  final bool isAdmin;
  final bool sentByMe;
  final bool isSystemMessage;

  const MessageTile({
    Key? key,
    required this.id,
    required this.groupId,
    required this.message,
    required this.sender,
    required this.senderDisplay,
    required this.time,
    required this.isAdmin,
    required this.sentByMe,
    this.isSystemMessage = false,
  }) : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
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
          child: Text('Delete', style: Theme.of(context).textTheme.bodyLarge),
          value: 'delete',
        ),
        PopupMenuItem(
          child: Text('Details', style: Theme.of(context).textTheme.bodyLarge),
          value: 'details',
        ),
      ];
    } else {
      menuItems = [
        PopupMenuItem(
          child: Text('Details', style: Theme.of(context).textTheme.bodyLarge),
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
          title: Text('Edit Message', style: Theme.of(context).textTheme.titleMedium),
          content: TextField(
            style: Theme.of(context).textTheme.bodyLarge,
            onChanged: (value) {
              editedText = value; // Update the edited text
            },
            controller:
                TextEditingController(text: editedText),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(0, 10, 20, 10),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(92, 161, 161, 161))),
              errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2.0)),
              focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2.0)),
            ),// Set initial value
          ),
          actions: [
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
          title: Text('Confirm Delete', style: Theme.of(context).textTheme.titleMedium),
          content: Text('Are you sure you want to delete this message?', style: Theme.of(context).textTheme.bodyLarge),
          actions: [
            TextButton(
              onPressed: () {
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
          title: Text('Details', style: Theme.of(context).textTheme.titleMedium),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Username: ${widget.sender}", style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(height: 12), // Add some spacing between lines
              Text( formatDateInMillis(widget.time) + ", " + formatTimeInMillis(widget.time), style: Theme.of(context).textTheme.bodyLarge),
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.isSystemMessage
            ? Container(
                padding: EdgeInsets.only(
                  top: 4,
                  bottom: 4,
                ),
                alignment: Alignment.center,
                child: SizedBox(
                  width: 250,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).hoverColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              )
            : GestureDetector(
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
                      right: widget.sentByMe ? 24 : 0),
                  alignment: widget.sentByMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: widget.sentByMe
                        ? const EdgeInsets.only(left: 30)
                        : const EdgeInsets.only(right: 30),
                    padding: const EdgeInsets.only(
                        top: 17, bottom: 17, left: 20, right: 20),
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
                            : Colors.grey[700]),
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
                              letterSpacing: -0.5),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Wrap(
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          children: [
                            Text(widget.message,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white)),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                formatTimeInMillis(widget.time),
                                style: TextStyle(
                                    fontSize: 10, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ],
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
