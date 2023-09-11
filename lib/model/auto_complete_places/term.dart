class Term {
  num? offset;
  String? value;

  Term({this.offset, this.value});

  factory Term.fromJson(Map<String, dynamic> json) => Term(
        offset: num.tryParse(json['offset'].toString()),
        value: json['value']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        if (offset != null) 'offset': offset,
        if (value != null) 'value': value,
      };
}
