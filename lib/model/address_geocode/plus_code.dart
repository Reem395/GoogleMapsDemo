class PlusCode {
  String? compoundCode;
  String? globalCode;

  PlusCode({this.compoundCode, this.globalCode});

  factory PlusCode.fromJson(Map<String, dynamic> json) => PlusCode(
        compoundCode: json['compound_code']?.toString(),
        globalCode: json['global_code']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        if (compoundCode != null) 'compound_code': compoundCode,
        if (globalCode != null) 'global_code': globalCode,
      };
}
