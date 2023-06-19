import 'dart:convert';
import 'package:flutter/services.dart';

Future<List<String>> extractFromFile(String filename) async {
    String jsonString = await rootBundle.loadString('assets/json/'+ filename + '.json');
    return List<String>.from(jsonDecode(jsonString)[filename]);
}

