import 'result.dart';

class AddressGeocode {
  List<Result>? results;
  String? status;

  AddressGeocode({this.results, this.status});

  factory AddressGeocode.fromJson(Map<String, dynamic> json) {
    return AddressGeocode(
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => Result.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (results != null)
          'results': results?.map((e) => e.toJson()).toList(),
        if (status != null) 'status': status,
      };
}
