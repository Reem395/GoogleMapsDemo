class Northeast {
  num? lat;
  num? lng;

  Northeast({this.lat, this.lng});

  factory Northeast.fromJson(Map<String, dynamic> json) => Northeast(
        lat: num.tryParse(json['lat'].toString()),
        lng: num.tryParse(json['lng'].toString()),
      );

  Map<String, dynamic> toJson() => {
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      };
}
