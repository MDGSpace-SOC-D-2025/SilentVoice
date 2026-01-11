class TrustedContact {
  final String name;
  final String phone;

  TrustedContact({required this.name, required this.phone});

  Map<String, dynamic> toJson() {
    return {'name': name, 'phone': phone};
  }

  factory TrustedContact.fromJson(Map<String, dynamic> json) {
    return TrustedContact(name: json['name'], phone: json['phone']);
  }
}
