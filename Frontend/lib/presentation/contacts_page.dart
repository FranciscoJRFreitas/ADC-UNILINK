import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unilink2023/widgets/news_box.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/Contact.dart';
import '../widgets/contacts_box.dart';
import '../application/fetchContacts.dart';
import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:searchfield/searchfield.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  ScrollController _scrollController = ScrollController();
  List<Contact> _contacts = [];
  bool _hasMore = true;
  bool _isLoading = false;
  TextEditingController _searchController = TextEditingController();
  List<Contact> _searchContacts = [];
  @override
  void initState() {
    super.initState();
    _fetchContacts();
    //_searchContacts = _contacts;
  }

  void _fetchContacts() async {
    String jsonString =
        await rootBundle.loadString('assets/json/contacts.json');
    var contactsJson = json.decode(jsonString);

    var departmentsJson = contactsJson['departments'];
    var servicesJson = contactsJson['servicos'];
    var nucleosJson = contactsJson['nucleos'];

    var departments = departmentsJson != null
        ? (departmentsJson as List).map((i) => Contact.fromJson(i)).toList()
        : [];
    var services = servicesJson != null
        ? (servicesJson as List).map((i) => Contact.fromJson(i)).toList()
        : [];
    var nucleos = nucleosJson != null
        ? (nucleosJson as List).map((i) => Contact.fromJson(i)).toList()
        : [];

    setState(() {
      _contacts = [
        ...departments,
        ...services,
        ...nucleos
      ]; // Combining both lists
    });
  }

  /*Widget build(BuildContext context) {
    return Scaffold(
      body: AlphabetListScrollView(
        strList: _contacts
            .map((contact) => contact.name)
            .toList(), // Assuming contact has a 'name' property
        highlightTextStyle: TextStyle(color: Colors.white),
        normalTextStyle: TextStyle(color: Colors.green),
        showPreview: true,

        itemBuilder: (context, index) {
          final item = _contacts[index];

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _launchURL(item.url ?? ''),
              child: ContactCard(
                contact: item,
              ),
            ),
          );
        },
        indexedHeight: (index) => 150, // Set your item height
      ),
    );
  }*/
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: AlphabetListScrollView(
              strList: _contacts
                  .map((contact) => contact.name)
                  .toList(), // Assuming contact has a 'name' property
              highlightTextStyle: TextStyle(color: Colors.white),
              normalTextStyle: TextStyle(color: Colors.green),
              showPreview: true,

              itemBuilder: (context, index) {
                final item = _contacts[index];

                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _launchURL(item.url ?? ''),
                    child: ContactCard(
                      contact: item,
                    ),
                  ),
                );
              },
              indexedHeight: (index) => 150, // Set your item height
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // can't launch url, there is some error
      throw "Could not launch $url";
    }
  }
}

class _ActionsRow extends StatelessWidget {
  final Contact item;
  const _ActionsRow({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          iconTheme: const IconThemeData(color: Colors.white, size: 18),
          textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.white),
          ))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(CupertinoIcons.share_up),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}
