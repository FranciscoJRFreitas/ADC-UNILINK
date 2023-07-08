class Group {
  final String id;
  final String DisplayName;
  final String description;
  final int numberOfMembers;

  Group({
    required this.id,
    required this.DisplayName,
    required this.description,
    required this.numberOfMembers,
  });

  static Group fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      DisplayName: map['displayName'],
      description: map['description'],
      numberOfMembers: map['numberOfMembers'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': DisplayName,
      'description': description,
      'numberOfMembers': numberOfMembers,
    };
  }
}
