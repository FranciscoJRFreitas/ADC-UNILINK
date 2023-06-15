import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import '../domain/Contact.dart';

Future<Map<String, List<Contact>>> fetchContacts() async {
  final response =
      await http.get(Uri.parse('https://www.fct.unl.pt/faculdade/contactos'));

  if (response.statusCode == 200) {
    var document = parser.parse(response.body);

    // Fetching Main Contacts
    var mainContactsElement =
        document.querySelector('.row.clearfix div.col-tn-12.col-xs-6.col-sm-6');
    var mainContacts = mainContactsElement?.querySelectorAll('p') ?? [];

    List<Contact> mainContactList = [];

    for (var i = 0; i < mainContacts.length; i += 2) {
      var contactName = mainContacts[i].text;
      var contactPhone =
          (i + 1 < mainContacts.length) ? mainContacts[i + 1].text : '';

      mainContactList.add(Contact(
        name: contactName,
        url: '',
        phoneNumber: contactPhone,
      ));
    }

    // Fetching Departments Contacts
    var departmentsElement =
        document.querySelector('.row.clearfix .col-tn-12.col-xs-6.col-sm-6 ul');
    var departmentsContacts = departmentsElement?.querySelectorAll('li') ?? [];

    List<Contact> departmentsContactList = [];

    for (var department in departmentsContacts) {
      var linkElement = department.querySelector('a');
      var departmentName = linkElement?.text;
      var departmentUrl = linkElement?.attributes['href'];
      var departmentPhone = department.innerHtml.split('<br>')[1].trim();

      departmentsContactList.add(Contact(
        name: departmentName ?? '',
        url: departmentUrl ?? '',
        phoneNumber: departmentPhone,
      ));
    }

    return {
      'mainContacts': mainContactList,
      'departmentsContacts': departmentsContactList,
    };
  } else {
    throw Exception('Failed to load contacts...');
  }
}
