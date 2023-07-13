import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:unilink2023/constants.dart';
import 'package:unilink2023/data/cache_factory_provider.dart';
import 'package:unilink2023/domain/Token.dart';


Future<void> deleteGroup(
    BuildContext context,
    String groupId,
    String userId,
    void Function(String, bool) showErrorSnackbar,
    ) async {
  cacheFactory.removeGroup(groupId);
  cacheFactory.deleteMessage(
      groupId, '-1'); //Deleting group messages from cache
  final url = kBaseUrl + "rest/chat/delete/${groupId}";
  final tokenID = await cacheFactory.get('users', 'token');
  Token token = new Token(tokenID: tokenID, username: userId);

  final response = await http.delete(Uri.parse(url), headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${json.encode(token.toJson())}'
  });

  if (response.statusCode == 200) {
    deleteFolder("GroupAttachements/${groupId}");

    final imageRef = FirebaseStorage.instance.ref('GroupPictures/$groupId');
    await imageRef.delete();

    showErrorSnackbar('deleted group!', false);
  } else {
    showErrorSnackbar('Error deleting group!', true);
  }
}

Future<void> deleteFolder(String folderPath) async {
  final storage = FirebaseStorage.instance;
  final ListResult result = await storage.ref(folderPath).listAll();

  // Delete each file within the folder
  for (final Reference ref in result.items) {
    await ref.delete();
  }

  // Delete the empty folder
  await storage.ref(folderPath).delete();
}

