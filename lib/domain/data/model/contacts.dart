class Contacts {
  const Contacts({
    this.id,
    this.name,
    this.phones,
    this.emails,
    this.lastModifiedDate,
    this.conflict = false,
  });
  factory Contacts.fromJson(Map<String, dynamic> json) {
    return Contacts(
      id: json['id'] as String?,
      name: json['name'] as String?,
      phones: (json['phones'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      emails: (json['emails'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      lastModifiedDate: json['lastModifiedDate'] == null
          ? null
          : DateTime.tryParse(json['lastModifiedDate'] as String),
    );
  }
  final String? id;
  final String? name;
  final List<String>? phones;
  final List<String>? emails;
  final DateTime? lastModifiedDate;
  final bool conflict;
}
