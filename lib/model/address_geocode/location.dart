class Location {
  num? lat;
  num? lng;

  Location({this.lat, this.lng});

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        lat: num.tryParse(json['lat'].toString()),
        lng: num.tryParse(json['lng'].toString()),
      );

  Map<String, dynamic> toJson() => {
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      };
}
