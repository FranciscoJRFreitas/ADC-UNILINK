import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'MapPage.dart';

class MapPage extends StatefulWidget {
  final String username;

  MapPage({required this.username});
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final loc.Location location = loc.Location();
  StreamSubscription<DatabaseEvent>? _locationSubscription;
  late DatabaseReference _locationRef;
  List<DataSnapshot> _locationSnapshots = [];

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _locationRef = FirebaseDatabase.instance.ref().child('location');
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(
            onPressed: _getLocation,
            child: Text('Add My Location'),
          ),
          TextButton(
            onPressed: _listenLocation,
            child: Text('Enable Live Location'),
          ),
          TextButton(
            onPressed: _stopListening,
            child: Text('Stop Live Location'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _locationSnapshots.length,
              itemBuilder: (context, index) {
                final locationSnapshot = _locationSnapshots[index];
                final username = locationSnapshot.key;
                final Map<dynamic, dynamic>? locationData =
                    locationSnapshot.value as Map<dynamic, dynamic>?;

                final latitude = locationData?['latitude'];
                final longitude = locationData?['longitude'];

                return ListTile(
                  title: Text(username ?? ''),
                  subtitle: Row(
                    children: [
                      Text(latitude?.toString() ?? ''),
                      SizedBox(width: 20),
                      Text(longitude?.toString() ?? ''),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.directions),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MyMap(username ?? ''),
                      ));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  _getLocation() async {
    try {
      final loc.LocationData _locationResult = await location.getLocation();
      final DatabaseReference locationRef =
          FirebaseDatabase.instance.ref("location").child(widget.username);
      locationRef.child("latitude").set(_locationResult.latitude);
      locationRef.child("longitude").set(_locationResult.longitude);
    } catch (e) {
      print(e);
    }
  }

  void _listenLocation() {
    _locationSubscription ??= _locationRef.onChildAdded.listen(
      (DatabaseEvent event) {
        if (event.snapshot.value != null) {
          setState(() {
            // Assuming _locationSnapshots is a List<DatabaseReference>
            _locationSnapshots.add(event.snapshot);
          });
        }
      },
    );
  }

  void _stopListening() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  Future<void> _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('Permission granted');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}
