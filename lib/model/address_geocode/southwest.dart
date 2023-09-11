class Southwest {
  num? lat;
  num? lng;

  Southwest({this.lat, this.lng});

  factory Southwest.fromJson(Map<String, dynamic> json) => Southwest(
        lat: num.tryParse(json['lat'].toString()),
        lng: num.tryParse(json['lng'].toString()),
      );

  Map<String, dynamic> toJson() => {
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      };
}
