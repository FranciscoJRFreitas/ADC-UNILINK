import 'package:flutter/material.dart';
import '../data/cache_factory_provider.dart';
import '../widgets/LineComboBox.dart';
import '../widgets/my_text_button.dart';

class EditStartingPage extends StatefulWidget {
  final VoidCallback? onDialogClosed;

  const EditStartingPage({Key? key, this.onDialogClosed}) : super(key: key);

  @override
  _EditStartingPageState createState() => _EditStartingPageState();
}

class _EditStartingPageState extends State<EditStartingPage> {
  String _startingPage = "News";
  IconData icon = Icons.pages;

  @override
  void initState() {
    super.initState();
    getSettings();
  }

  Future<void> getSettings() async {
    _startingPage = await cacheFactory.get('settings', 'index');
    setState(() {});
    updateIcon();
  }

  void updateIcon() {
    if (_startingPage == "News") icon = Icons.newspaper;
    if (_startingPage == "Profile") icon = Icons.person;
    if (_startingPage == "Schedule") icon = Icons.schedule;
    if (_startingPage == "Chat") icon = Icons.chat;
    if (_startingPage == "Contacts") icon = Icons.call;
  }

  @override
  Widget build(BuildContext context) {
    double offset = MediaQuery.of(context).size.width * 0.08;
    return Dialog(
      insetPadding: EdgeInsets.fromLTRB(offset, 80, offset, 50),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 300, // Set the maximum width for the Dialog
              ),
              //child: Padding(
              //padding: EdgeInsets.only(
              //  top: 20), // Provide space for the image at the top
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 5.0),
                    child: Text("Starting Page",
                        style: Theme.of(context).textTheme.bodyLarge),
                  ),
                  Divider(
                    thickness: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 15),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LineComboBox(
                        selectedValue: _startingPage,
                        items: [
                          'News',
                          'Profile',
                          'Schedule',
                          'Chat',
                          'Contacts'
                        ],
                        onChanged: (dynamic newValue) {
                          setState(() {
                            _startingPage = newValue;
                            updateIcon();
                          });
                        },
                        icon: icon,
                      )),
                  SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: MyTextButton(
                      alignment: Alignment.center,
                      buttonName: 'Save Changes',
                      onTap: () {
                        cacheFactory.set('index', _startingPage);
                        Navigator.pop(context);
                        widget.onDialogClosed?.call();
                      },
                      bgColor: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      height: 45,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // ),
          Positioned(
            top: 1,
            right: 1,
            child: IconButton(
              hoverColor:
                  Theme.of(context).secondaryHeaderColor.withOpacity(0.6),
              splashRadius: 20.0,
              icon: Container(
                height: 25,
                width: 25,
                child: Icon(
                  Icons.close,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
