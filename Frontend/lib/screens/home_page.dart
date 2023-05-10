import 'package:flutter/material.dart';
import '../constants.dart';
import '../util/Token.dart';
import '../util/User.dart';

class HomePage extends StatefulWidget {
  final User user;
  final Color roleColor;
  const HomePage({required Key key, required this.user, required this.roleColor}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Welcome, ",
                    style: kBodyText1.copyWith(
                      fontSize: 30,
                    ),
                  ),
                  TextSpan(
                    text: widget.user.displayName,
                    style: kBodyText2.copyWith(
                      color: widget.roleColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Card(
              color: kWhiteBackgroundColor,
              child: Column(
                children: [
                  ListTile(
                    title: Text("Role"),
                    trailing: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: widget.user.role,
                              style: TextStyle(
                                color: widget.roleColor,
                              )),
                        ],
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Username"),
                    trailing: Text(widget.user.username),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Email"),
                    trailing: Text(widget.user.email),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Profile Visibility"),
                    trailing: Text(widget.user.profileVisibility ?? 'N/A'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Activity State"),
                    trailing: Text(widget.user.state ?? 'N/A'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Landline Phone"),
                    trailing: Text(widget.user.landlinePhone ?? 'N/A'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Mobile Phone"),
                    trailing: Text(widget.user.mobilePhone ?? 'N/A'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Occupation"),
                    trailing: Text(widget.user.occupation ?? 'N/A'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Workplace"),
                    trailing: Text(widget.user.workplace ?? 'N/A'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Address"),
                    trailing: Text(widget.user.address ?? 'N/A'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Additional Address"),
                    trailing: Text(widget.user.additionalAddress ?? 'N/A'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Locality"),
                    trailing: Text(widget.user.locality ?? 'N/A'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Postal Code"),
                    trailing: Text(widget.user.postalCode ?? 'N/A'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("NIF"),
                    trailing: Text(widget.user.nif ?? 'N/A'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Photo URL"),
                    trailing: Text(widget.user.photoUrl ?? 'N/A'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
