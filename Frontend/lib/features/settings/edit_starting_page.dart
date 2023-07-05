import 'package:flutter/material.dart';
import 'package:unilink2023/data/cache_factory_provider.dart';
import 'package:unilink2023/widgets/LineComboBox.dart';
import 'package:unilink2023/widgets/my_text_button.dart';


class EditStartingPage extends StatefulWidget {
  final VoidCallback? onDialogClosed;
  final bool loggedIn;
  const EditStartingPage({Key? key, this.onDialogClosed, required this.loggedIn}) : super(key: key);

  @override
  _EditStartingPageState createState() => _EditStartingPageState(loggedIn);
}

class _EditStartingPageState extends State<EditStartingPage> {
  String _startingPage = "News";
  IconData icon = Icons.pages;
  bool _loggedIn = false;

  _EditStartingPageState(loggedIn){
    _loggedIn = loggedIn;
  }

  @override
  void initState() {
    super.initState();
    getSettings();
  }

  Future<void> getSettings() async {
    _startingPage = await cacheFactory.get('settings', 'index');
    setState(() {});
    if (!_loggedIn && (_startingPage != 'News' && _startingPage != 'Contacts' && _startingPage != 'Campus'))
      _startingPage = "News";
    updateIcon();
  }

  void updateIcon() {
    if (_startingPage == "News") icon = Icons.newspaper;
    if (_startingPage == "Profile") icon = Icons.person;
    if (_startingPage == "Schedule") icon = Icons.schedule;
    if (_startingPage == "Chat") icon = Icons.chat;
    if (_startingPage == "Contacts") icon = Icons.call;
    if (_startingPage == "Campus") icon = Icons.map;
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
                        items: itemList(),
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

  List<String> itemList(){
    if (_loggedIn) return [
      'News',
      'Profile',
      'Schedule',
      'Chat',
      'Contacts',
      'Campus',
    ];
    else return [
      'News',
      'Contacts',
      'Campus',
    ];
  }
}
