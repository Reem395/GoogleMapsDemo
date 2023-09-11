import 'main_text_matched_substring.dart';

class StructuredFormatting {
  String? mainText;
  List<MainTextMatchedSubstring>? mainTextMatchedSubstrings;
  String? secondaryText;

  StructuredFormatting({
    this.mainText,
    this.mainTextMatchedSubstrings,
    this.secondaryText,
  });

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) {
    return StructuredFormatting(
      mainText: json['main_text']?.toString(),
      mainTextMatchedSubstrings: (json['main_text_matched_substrings']
              as List<dynamic>?)
          ?.map((e) =>
              MainTextMatchedSubstring.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      secondaryText: json['secondary_text']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (mainText != null) 'main_text': mainText,
        if (mainTextMatchedSubstrings != null)
          'main_text_matched_substrings':
              mainTextMatchedSubstrings?.map((e) => e.toJson()).toList(),
        if (secondaryText != null) 'secondary_text': secondaryText,
      };
}
