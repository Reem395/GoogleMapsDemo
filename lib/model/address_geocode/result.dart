import 'address_component.dart';
import 'geometry.dart';
import 'plus_code.dart';

class Result {
  List<AddressComponent>? addressComponents;
  String? formattedAddress;
  Geometry? geometry;
  String? placeId;
  PlusCode? plusCode;
  List<String>? types;

  Result({
    this.addressComponents,
    this.formattedAddress,
    this.geometry,
    this.placeId,
    this.plusCode,
    this.types,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        addressComponents: (json['address_components'] as List<dynamic>?)
            ?.map(
                (e) => AddressComponent.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        formattedAddress: json['formatted_address']?.toString(),
        geometry: json['geometry'] == null
            ? null
            : Geometry.fromJson(Map<String, dynamic>.from(json['geometry'])),
        placeId: json['place_id']?.toString(),
        plusCode: json['plus_code'] == null
            ? null
            : PlusCode.fromJson(Map<String, dynamic>.from(json['plus_code'])),
        types: List<String>.from(json['types'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        if (addressComponents != null)
          'address_components':
              addressComponents?.map((e) => e.toJson()).toList(),
        if (formattedAddress != null) 'formatted_address': formattedAddress,
        if (geometry != null) 'geometry': geometry?.toJson(),
        if (placeId != null) 'place_id': placeId,
        if (plusCode != null) 'plus_code': plusCode?.toJson(),
        if (types != null) 'types': types,
      };
}
