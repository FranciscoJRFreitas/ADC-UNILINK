import 'package:flutter/material.dart';
import '../../constants.dart';
import '../userManagement/domain/User.dart';
import 'reportAnomalyPage.dart';
import 'myReportedAnomalies.dart';

// ignore: must_be_immutable
class ReportAnomalyPage extends StatefulWidget {
  User user;

  ReportAnomalyPage({required this.user});

  @override
  State<ReportAnomalyPage> createState() => ReportAnomalyPageState();
}

class ReportAnomalyPageState extends State<ReportAnomalyPage> {
  int _currentIndex = 0;
  late List<Widget> _pages = [ReportAnomalyTab(user: widget.user), MyReportedAnomaliesTab(user: widget.user)];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // Replace AppBar with a custom bar
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              indicatorColor:
                  _currentIndex == 0 ? Colors.orange : Style.darkBlue,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              tabs: [
                Tab(
                  icon: Icon(Icons.bug_report),
                  text: 'Report Anomaly',
                ),
                Tab(
                  icon: Icon(Icons.list),
                  text: 'My Reported Anomalies',
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: _pages,
        ),
      ),
    );
  }
}
