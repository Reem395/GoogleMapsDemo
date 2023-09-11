class AddressComponent {
  String? longName;
  String? shortName;
  List<String>? types;

  AddressComponent({this.longName, this.shortName, this.types});

  factory AddressComponent.fromJson(Map<String, dynamic> json) {
    return AddressComponent(
      longName: json['long_name']?.toString(),
      shortName: json['short_name']?.toString(),
      types: List<String>.from(json['types'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        if (longName != null) 'long_name': longName,
        if (shortName != null) 'short_name': shortName,
        if (types != null) 'types': types,
      };
}
