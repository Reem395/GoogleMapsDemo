import 'location.dart';
import 'viewport.dart';

class Geometry {
  Location? location;
  String? locationType;
  Viewport? viewport;

  Geometry({this.location, this.locationType, this.viewport});

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        location: json['location'] == null
            ? null
            : Location.fromJson(Map<String, dynamic>.from(json['location'])),
        locationType: json['location_type']?.toString(),
        viewport: json['viewport'] == null
            ? null
            : Viewport.fromJson(Map<String, dynamic>.from(json['viewport'])),
      );

  Map<String, dynamic> toJson() => {
        if (location != null) 'location': location?.toJson(),
        if (locationType != null) 'location_type': locationType,
        if (viewport != null) 'viewport': viewport?.toJson(),
      };
}
