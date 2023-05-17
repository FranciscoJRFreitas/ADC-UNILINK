class Group {
  final String DisplayName;
  final String description;
  //final String adminID;

  Group({
    required this.DisplayName,
    required this.description,
    // required this.adminID,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      DisplayName: json['DisplayName']['string'],
      description: json['description']['string'],
    );
  }

  String nullFormat(String? string) {
    String result = '';
    if (string != null) result = string;

    return result;
  }

  Map<String, Object> toMap(String token, String password) {
    return {
      'DisplayName': DisplayName,
      'description': description,
    };
  }
}
