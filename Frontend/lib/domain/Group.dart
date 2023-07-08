class Group {
  final String id;
  final String DisplayName;
  final String description;

  Group({
    required this.id,
    required this.DisplayName,
    required this.description,
  });
}
// void listenForGroups() async {
//   StreamController<List<Group>> streamController = StreamController();
//   List<Group> groups = await cacheFactory.getGroups();
//   streamController.add(groups);
//
//   groupsStream = streamController.stream;
//   DatabaseReference chatRef = FirebaseDatabase.instance
//       .ref()
//       .child('chat')
//       .child(widget.user.username)
//       .child('Groups');
//   DatabaseReference groupsRef =
//   FirebaseDatabase.instance.ref().child('groups');
//   DatabaseReference membersRef =
//   FirebaseDatabase.instance.ref().child('members');
//   DatabaseReference messagesRef =
//   FirebaseDatabase.instance.ref().child('messages');
//
//
//
//   // Listen for initial data and subsequent child additions
//   chatRef.onChildAdded.listen((event) async {
//     String groupId = event.snapshot.key as String;
//
//     messagesRef
//         .child(groupId)
//         .orderByKey()
//         .limitToLast(1)
//         .onChildAdded
//         .listen((event) async {
//       setState(() {
//         firstMessageOfGroups[groupId] = Message.fromSnapshot(event.snapshot);
//       });
//     });
//
//     // Fetch group details from groupsRef
//     DatabaseEvent groupSnapshot = await groupsRef.child(groupId).once();
//     Map<dynamic, dynamic>? groupData =
//     await groupSnapshot.snapshot.value as Map<dynamic, dynamic>?;
//
//     DatabaseEvent memberSnapshot = await membersRef.child(groupId).once();
//     Map<dynamic, dynamic>? memberData =
//     await memberSnapshot.snapshot.value as Map<dynamic, dynamic>?;
//
//     if (groupData != null && memberData != null) {
//       String displayName = groupData['DisplayName'];
//       String description = groupData['description'];
//       int numberOfMembers = memberData.length;
//       Group group = Group(
//         id: groupId,
//         DisplayName: displayName,
//         description: description,
//         numberOfMembers: numberOfMembers,
//       );
//       groups.add(group);
//       cacheFactory.addGroup(group);
//
//       setState(() {
//         allGroups.add(group);
//         filteredGroups.add(group);
//       });
//
//       streamController.add(groups);
//     }
//   });
//
//   // Listen for child removal using onChildRemoved
//   chatRef.onChildRemoved.listen((event) {
//     String groupId = event.snapshot.key as String;
//
//     setState(() {
//       groups.removeWhere((group) => group.id == groupId);
//     });
//   });
//
//   groupsStream = streamController.stream;
// }