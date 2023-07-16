import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unilink2023/features/contacts/domain/Contact.dart';
import 'package:unilink2023/widgets/contacts_box.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:alphabet_list_view/alphabet_list_view.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> _contacts = [];

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
      String startingLetter = (contact.contactName.isNotEmpty)
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
            return ContactCard(
              contact: contact,
            );
          }).toList(),
        ),
      );
    }

    final AlphabetListViewOptions options = AlphabetListViewOptions(
      listOptions: ListOptions(
        listHeaderBuilder: (context, symbol) {
          return Padding(
            padding: const EdgeInsets.only(right: 18, top: 4, bottom: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(100),
                  ),
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    top: 8,
                    right: 16,
                    bottom: 8,
                  ),
                  child: Text(
                    symbol,
                    textScaleFactor: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      scrollbarOptions: ScrollbarOptions(
        backgroundColor: Color.fromARGB(255, 11, 76, 142),
        symbolBuilder: (context, symbol, state) {
          Color color;
          bool hasContacts = checkForContacts(symbol);
          if (hasContacts) {
            color = Colors.white; // letters that have contacts will be white
          } else {
            color = Colors.black.withOpacity(
                0.3); // letters that don't have any contacts will be black
          }

          return Container(
            padding: const EdgeInsets.only(left: 4, top: 2, bottom: 2),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(100),
              ),
              color: state == AlphabetScrollbarItemState.active
                  ? Colors.blue
                  : null,
            ),
            child: Center(
              child: FittedBox(
                child: Text(
                  symbol,
                  style: TextStyle(color: color, fontSize: 20),
                ),
              ),
            ),
          );
        },
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

  bool checkForContacts(String symbol) {
    // contacts is your list of contact names
    for (Contact contact in _contacts) {
      if (contact.contactName.startsWith(symbol)) {
        return true;
      }
    }
    return false;
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
