import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:unilink2023/data/cache_factory_provider.dart';
import 'package:http/http.dart' as http;
import 'package:unilink2023/widgets/LocationPopUp.dart';

import '../../constants.dart';
import '../../domain/Token.dart';
import '../../widgets/LineComboBox.dart';
import '../userManagement/domain/User.dart';

class ReportAnomalyTab extends StatefulWidget {
  User user;

  ReportAnomalyTab({required this.user});

  @override
  State<ReportAnomalyTab> createState() => ReportAnomalyTabState();
}

class ReportAnomalyTabState extends State<ReportAnomalyTab> {
  final TextEditingController _anomalyTitleController = TextEditingController();
  final TextEditingController _anomalyController = TextEditingController();
  LatLng? _selectedLocation = null;
  String selectLocationText = "Select Location";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildAnomalyTitleField(),
                SizedBox(height: 16.0),
                _buildAnomalyDescriptionField(),
                SizedBox(height: 16.0),
                _buildLocationField(),
                SizedBox(height: 16.0),
                _buildSendButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _buildAnomalyTitleField() {
    return TextFormField(
      controller: _anomalyTitleController,
      decoration: InputDecoration(
        labelText: 'Anomaly Title',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a title for the anomaly';
        }
        return null;
      },
    );
  }

  TextFormField _buildAnomalyDescriptionField() {
    return TextFormField(
      controller: _anomalyController,
      maxLines: 5,
      style: Theme.of(context)
          .textTheme
          .bodyLarge!
          .copyWith(color: Theme.of(context).secondaryHeaderColor),
      decoration: InputDecoration(
        labelText: 'Anomaly Description',
        labelStyle: TextStyle(fontSize: 25),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a description for the anomaly';
        }
        return null;
      },
    );
  }

  Widget _buildLocationField() {
    return LineComboBox(
      deleteIcon: Icons.clear,
      onPressed: () {
        setState(() {
          selectLocationText = "Select Location";
          _selectedLocation = null;
        });
      },
      selectedValue: selectLocationText,
      items: [selectLocationText, "From FCT place", "From maps"],
      icon: Icons.place,
      onChanged: (newValue) async {
        if (newValue == "From FCT place" || newValue == "From maps") {
          LatLng? selectedLocation = await showDialog<LatLng>(
            context: context,
            builder: (context) => EventLocationPopUp(
              context: context,
              isMapSelected: newValue == "From maps",
              location: _selectedLocation,
            ),
          );
          if (selectedLocation != null) {
            setState(() {
              selectLocationText = "1 Location Selected";
              _selectedLocation = selectedLocation;
            });
          }
        }
      },
    );
  }

  Widget _buildSendButton() {
    return Container(
      alignment: Alignment.center,
      width: 100,
      child: ElevatedButton.icon(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _sendAnomaly(context);
          }
        },
        icon: Icon(Icons.send),
        label: Text('Send'),
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

  void _sendAnomaly(BuildContext context) {
    final anomalytitle = _anomalyTitleController.text;
    final anomalydesc = _anomalyController.text;
    String coordinates = _selectedLocation != null
        ? "${_selectedLocation!.latitude},${_selectedLocation!.longitude}"
        : "0";
    sendAnomalytoServer(
        context, anomalytitle, anomalydesc, coordinates, _showErrorSnackbar);
  }

  Future<void> sendAnomalytoServer(
    BuildContext context,
    String title,
    String description,
    String coord,
    void Function(String, bool) showErrorSnackbar,
  ) async {
    final url = kBaseUrl + "rest/anomaly/send";
    final tokenID = await cacheFactory.get('users', 'token');
    final storedUsername = await cacheFactory.get('users', 'username');
    Token token = new Token(tokenID: tokenID, username: storedUsername);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                Text("Sending Anomaly..."),
              ],
            ),
          ),
        );
      },
    );

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${json.encode(token.toJson())}'
      },
      body: jsonEncode(
          {'title': title, 'description': description, 'coordinates': coord, 'sender': widget.user.username}),
    );
    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Anomaly Reported'),
            content: Text(
                'Thank you for reporting this anomaly. We are working on the issue.'),
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
      setState(() {
        _anomalyTitleController.clear();
        _anomalyController.clear();
        _selectedLocation = null;
        selectLocationText = "Select Location";
      });
    } else {
      Navigator.of(context).pop();
      showErrorSnackbar('Failed to send anomaly: ${response.body}', true);
    }
  }
}
