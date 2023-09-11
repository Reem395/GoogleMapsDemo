class MainTextMatchedSubstring {
  num? length;
  num? offset;

  MainTextMatchedSubstring({this.length, this.offset});

  factory MainTextMatchedSubstring.fromJson(Map<String, dynamic> json) {
    return MainTextMatchedSubstring(
      length: num.tryParse(json['length'].toString()),
      offset: num.tryParse(json['offset'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        if (length != null) 'length': length,
        if (offset != null) 'offset': offset,
      };
}
