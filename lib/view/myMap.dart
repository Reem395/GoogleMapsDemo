import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart' as poly;
import 'package:geocoding/geocoding.dart' as geocod;
import 'package:geolocator/geolocator.dart' as geolocator;
// import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location/location.dart' as loc;
import 'package:sizer/sizer.dart';
import 'package:uber_clone/utils/constants.dart';

import '../controller/autoComplete cubit/google_maps_cubit.dart';
import '../model/address_geocode/location.dart';

class MyMaps extends StatefulWidget {
  const MyMaps({super.key});

  @override
  State<MyMaps> createState() => _MyMapsState();
}

class _MyMapsState extends State<MyMaps> {
  GoogleMapController? mapController;
  LatLng? _initialPostion;
  LatLng? _destination;
  loc.LocationData? locData;
  loc.Location location = loc.Location();
  double currentZoom = 17;
  List<LatLng> polyLineCoordinates = [];
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  late geolocator.Position position;
  @override
  void initState() {
    super.initState();
    setCustomMarkerIcon();
    getCurrentLocation();
  }

  Future getBytesFromAsset(String path, int width) async {
    try {
      ByteData data = await rootBundle.load(path);
      ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
          targetWidth: width);
      ui.FrameInfo fi = await codec.getNextFrame();
      return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
          .buffer
          .asUint8List();
    } catch (e) {
      print("error from getBytes :$e");
    }
  }

  void setCustomMarkerIcon() async {
    // BitmapDescriptor.fromAssetImage(
    //   ImageConfiguration(
    //     devicePixelRatio: 0.1,
    //     platform: TargetPlatform.iOS,
    //     size: Size(0.02.w, 0.02.h),
    //   ),
    //   "assets/images/car.png",
    // ).then((icon) {
    //   currentLocationIcon = icon;
    // });
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/car.png', 25.w.toInt());
    currentLocationIcon = BitmapDescriptor.fromBytes(markerIcon);
  }

  getLiveLocation() async {
    try {
      geolocator.Geolocator.getPositionStream()
          .listen((geolocator.Position? position) {
        print(position == null
            ? 'Unknown'
            : 'from stream ${position.latitude.toString()}, ${position.longitude.toString()}');
        if (position != null) {
          _initialPostion = LatLng(position.latitude, position.longitude);
          mapController
              ?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: currentZoom,
          )));
          Timer(const Duration(seconds: 2), () {
            getPolyPoints(lat: position.latitude, long: position.longitude);
          });

          setState(() {});
        }
      });
    } catch (e) {
      print("error from getPositionStream $e");
    }
  }

  getCurrentLocation() async {
    try {
      // var serviceEnabled = await location.serviceEnabled();
      // if (!serviceEnabled) {
      //   print("service not enabled");
      //   serviceEnabled = await location.requestService();
      //   if (!serviceEnabled) {
      //     // return;
      //     print("service not enabled 2");
      //   }
      // }
      await geolocator.Geolocator.requestPermission();
      position = await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high,
      );
      List<geocod.Placemark> placemark = await geocod.placemarkFromCoordinates(
          position.latitude, position.longitude);
      _initialPostion = LatLng(position.latitude, position.longitude);
      _locationController.text = placemark[0].name!;
    } catch (e) {
      print("error from placemark :$e");
    }
    setState(() {});
    getLiveLocation();
  }

  @override
  Widget build(BuildContext context) {
    GoogleMapsCubit googleCubit = BlocProvider.of<GoogleMapsCubit>(context);
    return Scaffold(
        body: _initialPostion == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  GoogleMap(
                    zoomControlsEnabled: true,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    compassEnabled: true,
                    zoomGesturesEnabled: true,
                    markers: _markers,
                    initialCameraPosition: CameraPosition(
                        target: LatLng(_initialPostion!.latitude,
                            _initialPostion!.longitude),
                        zoom: currentZoom),
                    polylines: _polyLines,
                    onTap: _onMapTapped,
                    onMapCreated: onCreated,
                    onCameraMove: onCameraMove,
                  ),
                  Positioned(
                    top: 50.0,
                    right: 15.0,
                    left: 15.0,
                    child: Container(
                      height: 50.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              offset: Offset(1.0, 5.0),
                              blurRadius: 10,
                              spreadRadius: 3)
                        ],
                      ),
                      child: TextField(
                        cursorColor: Colors.black,
                        controller: _locationController,
                        decoration: InputDecoration(
                          icon: Container(
                            margin: const EdgeInsets.only(left: 20, top: 5),
                            width: 10,
                            height: 10,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.black,
                            ),
                          ),
                          hintText: "pick up",
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.only(left: 15.0, top: 16.0),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 105.0,
                    right: 15.0,
                    left: 15.0,
                    child: Container(
                      height: 50.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              offset: Offset(1.0, 5.0),
                              blurRadius: 10,
                              spreadRadius: 3)
                        ],
                      ),
                      child: TextField(
                        cursorColor: Colors.black,
                        controller: _destinationController,
                        textInputAction: TextInputAction.go,
                        onChanged: (value) async {
                          await googleCubit.placesAutocomplete(place: value);
                          setState(() {});
                          if (googleCubit.predictedPlacesDes!.isNotEmpty) {
                            googleCubit.showSuggestionList = true;
                          } else {
                            googleCubit.showSuggestionList = false;
                          }
                        },
                        onSubmitted: (value) {
                          googleCubit.showSuggestionList = false;
                          setState(() {
                            getPolyPoints(intendedLocation: value);
                          });
                        },
                        decoration: InputDecoration(
                          icon: Container(
                            margin: const EdgeInsets.only(left: 20, top: 5),
                            width: 10,
                            height: 10,
                            child: const Icon(
                              Icons.local_taxi,
                              color: Colors.black,
                            ),
                          ),
                          hintText: "destination?",
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: () {
                              _destinationController.clear();
                              setState(() {
                                googleCubit.predictedPlacesDes?.clear();
                                googleCubit.showSuggestionList = false;
                                _destination = null;
                                _markers.clear();
                                _polyLines.clear();
                                polyLineCoordinates.clear();
                              });
                            },
                          ),
                          contentPadding:
                              const EdgeInsets.only(left: 15.0, top: 16.0),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: googleCubit.showSuggestionList,
                    child: Positioned(
                      top: 170,
                      right: 15,
                      left: 15,
                      child: Container(
                          height: 350,
                          color: Colors.white.withOpacity(0.8),
                          child: ListView.builder(
                              itemCount: googleCubit.predictedPlacesDes?.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  onTap: () {
                                    print(
                                        "pressed :${googleCubit.predictedPlacesDes![index]}");
                                    _destinationController.text =
                                        googleCubit.predictedPlacesDes![index];
                                    setState(() {
                                      googleCubit.showSuggestionList = false;
                                    });
                                  },
                                  leading: const Icon(Icons.location_pin),
                                  title: Text(
                                      googleCubit.predictedPlacesDes![index]),
                                );
                              })),
                    ),
                  )
                ],
              ));
  }

  getPolyPoints({String? intendedLocation, double? lat, double? long}) async {
    polyLineCoordinates.clear();
    _polyLines.clear();
    double latitude;
    double longitude;
    try {
      if (intendedLocation != null) {
        if (intendedLocation.isNotEmpty) {
          Location addressLatLng =
              await BlocProvider.of<GoogleMapsCubit>(context)
                  .getAddressLatLng(address: intendedLocation);
          latitude = (addressLatLng.lat as double?)!;
          longitude = (addressLatLng.lng as double?)!;
          _destination = LatLng(latitude, longitude);

          // List<geocod.Location> placemark = await geocod
          //     .locationFromAddress(intendedLocation, localeIdentifier: "en_EG");
          // print("placemark len ${placemark.length}");
          // latitude = placemark[0].latitude;
          // longitude = placemark[0].longitude;
          // _destination = LatLng(latitude, longitude);
        }
      } else {
        _initialPostion = LatLng(lat!, long!);
      }
      poly.PolylinePoints polylinePoints = poly.PolylinePoints();
      poly.PolylineResult result =
          await polylinePoints.getRouteBetweenCoordinates(
              API,
              poly.PointLatLng(
                  _initialPostion!.latitude, _initialPostion!.longitude),
              poly.PointLatLng(
                  _destination!.latitude, _destination!.longitude));
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polyLineCoordinates.add(LatLng(point.latitude, point.longitude));
          _polyLines.add(Polyline(
              polylineId: PolylineId(_destination.toString()),
              points: polyLineCoordinates,
              color: Colors.black,
              width: 5));
        }
        _addMarker(destination: _destination!);

        setState(() {});
      }
    } catch (e) {
      print("error from getPoly $e");
    }
  }

  void _addMarker({required LatLng destination, String? address}) async {
    // _markers.clear();
    _markers.add(Marker(
        markerId: const MarkerId("Current Location"),
        position: LatLng(_initialPostion!.latitude, _initialPostion!.longitude),
        icon: currentLocationIcon
        //  await BitmapDescriptor.fromAssetImage(
        //     const ImageConfiguration(), 'assets/images/car.png')

        ));
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(_destination.toString()),
          position: destination,
          infoWindow: InfoWindow(title: address, snippet: "go here"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueMagenta)));
    });
  }

  void _onMapTapped(LatLng latLng) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(latLng.toString()),
          position: latLng,
          infoWindow:
              const InfoWindow(title: "Remember here", snippet: "good place"),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }

  void onCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void onCameraMove(CameraPosition position) {
    setState(() {
      currentZoom = position.zoom;
    });
  }

  // void _onDestinationTextFieldTapped() async {
  //   try {
  //     Prediction? p = await PlacesAutocomplete.show(
  //       offset: 0,
  //       radius: 1000,
  //       strictbounds: false,
  //       region: "eg",
  //       language: "en",
  //       context: context,
  //       mode: Mode.overlay,
  //       apiKey: API,
  //       components: [Component(Component.country, "eg")],
  //       types: ["(address)"],
  //       hint: "Search City",
  //     );

  //     if (p != null) {
  //       _destinationController.text = p.description!;
  //       print("p.description ${p.description}");
  //       getPolyPoints(p.description!);
  //     }
  //   } catch (e) {
  //     print("error $e");
  //   }
  // }
}
