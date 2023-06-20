import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unilink2023/widgets/news_box.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/Contact.dart';
import '../widgets/contacts_box.dart';
import 'package:alphabet_list_view/alphabet_list_view.dart';
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
  }

  void _fetchContacts() async {
    String jsonString =
        await rootBundle.loadString('assets/json/contacts.json');
    var contactsJson = json.decode(jsonString);

    var departmentsJson = contactsJson['departments'];
    var servicesJson = contactsJson['services'];
    var nucleosJson = contactsJson['nucleos'];
    var organsJson = contactsJson['orgaos'];

    var departments = departmentsJson != null
        ? (departmentsJson as List).map((i) => Contact.fromJson(i)).toList()
        : [];
    var services = servicesJson != null
        ? (servicesJson as List).map((i) => Contact.fromJson(i)).toList()
        : [];
    var nucleos = nucleosJson != null
        ? (nucleosJson as List).map((i) => Contact.fromJson(i)).toList()
        : [];
    var organs = organsJson != null
        ? (organsJson as List).map((i) => Contact.fromJson(i)).toList()
        : [];

    setState(() {
      _contacts = [
        ...departments,
        ...services,
        ...nucleos,
        ...organs,
      ]; // Combining both lists
    });
  }

  Widget build(BuildContext context) {
    // Create a map that associates each starting letter with a list of contacts.
    Map<String, List<Contact>> contactsByLetter = {};
    for (Contact contact in _contacts) {
      String startingLetter =
          (contact.contactName != null && contact.contactName.isNotEmpty)
              ? contact.contactName[0].toUpperCase()
              : '#';
      if (!contactsByLetter.containsKey(startingLetter)) {
        contactsByLetter[startingLetter] = [];
      }
      contactsByLetter[startingLetter]!.add(contact);
    }

    // Convert the map into a list of AlphabetListViewItemGroups.
    List<AlphabetListViewItemGroup> itemGroups = [];
    for (String letter in contactsByLetter.keys) {
      List<Contact> contactsForLetter = contactsByLetter[letter]!;
      itemGroups.add(
        AlphabetListViewItemGroup(
          tag: letter,
          children: contactsForLetter.map((contact) {
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _launchURL(contact.url ?? ''),
                child: ContactCard(
                  contact: contact,
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    final AlphabetListViewOptions options = AlphabetListViewOptions(
      listOptions: ListOptions(
        listHeaderBuilder: (context, symbol) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                symbol,
                style: TextStyle(color: Colors.black),
              ),
            ),
          );
        },
      ),
      scrollbarOptions: const ScrollbarOptions(
        backgroundColor: Color.fromARGB(255, 11, 76, 142),
      ),
      overlayOptions: const OverlayOptions(
        showOverlay: false,
      ),
    );

    return Scaffold(
      body: AlphabetListView(
        items: itemGroups,
        options: options,
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
