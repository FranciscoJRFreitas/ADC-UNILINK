class Contact {
  final String name;
  final String contactName;
  final String phoneNumber;
  final String email;
  final String url;
  final String facebook;
  final String instagram;

  Contact(
      {required this.name,
      required this.contactName,
      required this.phoneNumber,
      required this.email,
      required this.url,
      required this.facebook,
      required this.instagram});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'] ?? '',
      contactName: json['contactName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      url: json['url'] ?? '',
      facebook: json['facebook'] ?? '',
      instagram: json['instagram'] ?? '',
    );
  }
}