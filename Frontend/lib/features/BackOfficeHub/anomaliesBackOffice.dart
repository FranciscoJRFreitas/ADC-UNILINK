import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../constants.dart';
import '../anomaly/Domain/Anomaly.dart';

class AnomaliesPage extends StatefulWidget {
  @override
  _AnomaliesPageState createState() => _AnomaliesPageState();
}

class _AnomaliesPageState extends State<AnomaliesPage> {
  List<Anomaly> _anomalies = [];
  late DatabaseReference _anomaliesRef;

  @override
  void initState() {
    super.initState();
    _anomaliesRef = FirebaseDatabase.instance.ref('anomaly');

    _anomaliesRef.onChildAdded.listen((event) {
      var anomaly = Anomaly.fromSnapshot(event.snapshot);
      setState(() {
        _anomalies.add(anomaly);
      });
    });

    _anomaliesRef.onChildRemoved.listen((event) {
      setState(() {
        _anomalies
            .removeWhere((anomaly) => anomaly.anomalyId == event.snapshot.key);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Anomalies",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView.builder(
        itemCount: _anomalies.length,
        itemBuilder: (BuildContext context, int index) {
          final anomaly = _anomalies[index];
          return ListTile(
            title: Text(anomaly.anomalyId!),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.type_specimen, size: 20, color: Style.lightBlue),
                    SizedBox(width: 5),
                    Row(
                      children: [
                        Text(
                          'Title: ',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontSize: 14),
                        ),
                        Text(
                          anomaly.title,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.description, size: 20, color: Style.lightBlue),
                    SizedBox(width: 5),
                    Text(
                      'Description: ',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontSize: 14),
                    ),
                    Flexible(
                      child: Text(
                        anomaly.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.place, size: 20, color: Style.lightBlue),
                    SizedBox(width: 5),
                    Text(
                      'Coordinates: ',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontSize: 14),
                    ),
                    Flexible(
                      child: Text(
                        anomaly.coordinates,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
              ],
            ),
            trailing: Icon(Icons.check, color: Colors.green),
          );
        },
      ),
    );
  }
}
