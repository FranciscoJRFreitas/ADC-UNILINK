import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:unilink2023/data/cache_factory_provider.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../domain/Token.dart';

class ReportAnomalyPage extends StatefulWidget {
  @override
  State<ReportAnomalyPage> createState() => ReportAnomalyPageState();
}

class ReportAnomalyPageState extends State<ReportAnomalyPage> {
  final TextEditingController anomalyController = TextEditingController();

  void sendAnomaly(BuildContext context) {
    final anomalyText = anomalyController.text;
    sendAnomalytoServer(context, anomalyText, _showErrorSnackbar);
    print('Anomaly Report: $anomalyText');
    // You can perform further actions here, such as sending the anomaly report to a server or displaying a confirmation dialog.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: anomalyController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Anomaly Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => sendAnomaly(context),
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message, bool Error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Error ? Colors.red : Colors.blue.shade900,
      ),
    );
  }

  Future<void> sendAnomalytoServer(
    BuildContext context,
    String description,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    final url = kBaseUrl + "rest/anomaly/send";
    final tokenID = await cacheFactory.get('users', 'token');
    final storedUsername = await cacheFactory.get('users', 'username');
    Token token = new Token(tokenID: tokenID, username: storedUsername);

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${json.encode(token.toJson())}'
      },
      body: jsonEncode({
        'Description': description,
      }),
    );

    if (response.statusCode == 200) {
      showErrorSnackbar('Sent Anomaly successfully!', false);
      print('Anomaly Report: $description');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Anomaly Reported'),
            content: Text('Thank you for reporting the anomaly.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      anomalyController.clear();
    } else {
      showErrorSnackbar('Failed to send Anomaly: ${response.body}', true);
    }
  }
}
