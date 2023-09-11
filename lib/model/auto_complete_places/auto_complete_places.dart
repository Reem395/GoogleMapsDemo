import 'prediction.dart';

class AutoCompletePlaces {
  List<Prediction>? predictions;
  String? status;

  AutoCompletePlaces({this.predictions, this.status});

  factory AutoCompletePlaces.fromJson(Map<String, dynamic> json) {
    return AutoCompletePlaces(
      predictions: (json['predictions'] as List<dynamic>?)
          ?.map((e) => Prediction.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (predictions != null)
          'predictions': predictions?.map((e) => e.toJson()).toList(),
        if (status != null) 'status': status,
      };
}
