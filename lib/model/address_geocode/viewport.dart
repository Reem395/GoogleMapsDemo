import 'northeast.dart';
import 'southwest.dart';

class Viewport {
  Northeast? northeast;
  Southwest? southwest;

  Viewport({this.northeast, this.southwest});

  factory Viewport.fromJson(Map<String, dynamic> json) => Viewport(
        northeast: json['northeast'] == null
            ? null
            : Northeast.fromJson(Map<String, dynamic>.from(json['northeast'])),
        southwest: json['southwest'] == null
            ? null
            : Southwest.fromJson(Map<String, dynamic>.from(json['southwest'])),
      );

  Map<String, dynamic> toJson() => {
        if (northeast != null) 'northeast': northeast?.toJson(),
        if (southwest != null) 'southwest': southwest?.toJson(),
      };
}
