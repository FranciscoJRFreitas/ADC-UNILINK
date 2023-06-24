import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'context_menu_stub.dart';
import 'package:flutter/scheduler.dart';

class MessageTile extends StatefulWidget {
  final String groupId;
  final String id;
  final String message;
  final String sender;
  final String time;
  final bool isAdmin;
  final bool sentByMe;
  final bool isSystemMessage;

  const MessageTile({
    Key? key,
    required this.id,
    required this.groupId,
    required this.message,
    required this.sender,
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
  bool _isContextMenuVisible = false;

  void _showContextMenu(BuildContext context) {
    setState(() {
      _isContextMenuVisible = true;
    });

    final List<PopupMenuEntry<dynamic>> menuItems;
    if (widget.sentByMe) {
      menuItems = [
        PopupMenuItem(
          child: Text('Edit'),
          value: 'edit',
        ),
        PopupMenuItem(
          child: Text('Delete'),
          value: 'delete',
        ),
      ];
    } else {
      menuItems = [
        PopupMenuItem(
          child: Text('Delete'),
          value: 'delete',
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
      }

      setState(() {
        _isContextMenuVisible = false;
      });
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
          ],
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final contextMenu = ContextMenu();
    contextMenu.onContextMenu();
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
                onSecondaryTapDown: (TapDownDetails details) {
                  _tapPosition = details.globalPosition;
                  if (widget.sentByMe || widget.isAdmin) {
                    _showContextMenu(context);
                  }
                },
                onLongPress: () {
                  if (!kIsWeb && (widget.sentByMe || widget.isAdmin)) {
                    _showContextMenu(context);
                  }
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
                          widget.sender.toUpperCase(),
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
                                widget.time,
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
}
