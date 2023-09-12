import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uber_clone/model/address_geocode/location.dart';
import 'package:uber_clone/utils/constants.dart';
import 'package:http/http.dart' as http;

import '../../model/address_geocode/address_geocode.dart';
import '../../model/auto_complete_places/auto_complete_places.dart';
import '../../model/auto_complete_places/prediction.dart';
import 'google_maps_state.dart';

class GoogleMapsCubit extends Cubit<GoogleMapsState> {
  GoogleMapsCubit() : super(GoogleMapsInitial());
  List<Prediction>? predictedPlaces = [];
  List<String>? predictedPlacesDes = [];
  bool showSuggestionList = false;

  Future placesAutocomplete({required String place}) async {
    emit(GoogleMapsInitial());

    Uri uri = Uri.https(
        "maps.googleapis.com",
        "maps/api/place/autocomplete/json",
        {"input": place, "components": "country:eg", "key": API});
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        print("placesAutocomplete response :${response.statusCode}");
        final decodedData = json.decode(response.body);
        AutoCompletePlaces autoCompletePlaces =
            AutoCompletePlaces.fromJson(decodedData);
        if (autoCompletePlaces.predictions != null) {
          predictedPlaces?.clear();
          predictedPlacesDes?.clear();
          predictedPlaces = [...?autoCompletePlaces.predictions];
          for (var element in predictedPlaces!) {
            predictedPlacesDes?.add(element.description!);
          }
          print("placesAutocomplete predictedPlacesDes :$predictedPlacesDes");

          emit(AutoCompleteSuccess());
        }
      }
    } catch (e) {
      emit(AutoCompleteFailed());
      print("error from get Auto $e");
    }
  }

  Future getAddressLatLng({required String address}) async {
    emit(GoogleMapsInitial());

    Uri uri = Uri.https("maps.googleapis.com", "maps/api/geocode/json",
        {"address": address, "key": API});
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        AddressGeocode addressGeocode = AddressGeocode.fromJson(decodedData);
        if (addressGeocode.results != null) {
          Location? addressLatLng =
              addressGeocode.results?[0].geometry?.location;
          emit(GetAddressLatLngSuccess());
          return addressLatLng;
        }
      }
    } catch (e) {
      print("error from getAddress LatLng: $e");
      emit(GetAddressLatLngFailed());
    }
  }
}
