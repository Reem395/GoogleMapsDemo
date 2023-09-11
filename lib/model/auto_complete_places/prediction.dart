import 'matched_substring.dart';
import 'structured_formatting.dart';
import 'term.dart';

class Prediction {
  String? description;
  List<MatchedSubstring>? matchedSubstrings;
  String? placeId;
  String? reference;
  StructuredFormatting? structuredFormatting;
  List<Term>? terms;
  List<String>? types;

  Prediction({
    this.description,
    this.matchedSubstrings,
    this.placeId,
    this.reference,
    this.structuredFormatting,
    this.terms,
    this.types,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) => Prediction(
        description: json['description']?.toString(),
        matchedSubstrings: (json['matched_substrings'] as List<dynamic>?)
            ?.map(
                (e) => MatchedSubstring.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        placeId: json['place_id']?.toString(),
        reference: json['reference']?.toString(),
        structuredFormatting: json['structured_formatting'] == null
            ? null
            : StructuredFormatting.fromJson(
                Map<String, dynamic>.from(json['structured_formatting'])),
        terms: (json['terms'] as List<dynamic>?)
            ?.map((e) => Term.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        types: List<String>.from(json['types'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        if (description != null) 'description': description,
        if (matchedSubstrings != null)
          'matched_substrings':
              matchedSubstrings?.map((e) => e.toJson()).toList(),
        if (placeId != null) 'place_id': placeId,
        if (reference != null) 'reference': reference,
        if (structuredFormatting != null)
          'structured_formatting': structuredFormatting?.toJson(),
        if (terms != null) 'terms': terms?.map((e) => e.toJson()).toList(),
        if (types != null) 'types': types,
      };
}
