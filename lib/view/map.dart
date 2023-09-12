import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

import '../controller/remote/goggle_maps_request.dart';

class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  late GoogleMapController mapController;
  // LatLng _initialPostion = const LatLng(30.033333, 31.233334);
  // LatLng _initialPostion = const LatLng(30.033333, 31.233334);
  dynamic _initialPostion;
  // static const _finalPostion = LatLng(29.947925664695937, 30.97014583647251);
  // GoogleMapsServices googleMapsServices = GoogleMapsServices();
  LatLng _finalPostion = const LatLng(30.033333, 31.233334);
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  late geolocator.Position position;
  loc.LocationData? currentLocation;
  final GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  getCurrentLocation() async {
    //method 1 to get current location
    // loc.Location location = loc.Location();
    // await location.getLocation().then((value) => currentLocation = value);
    // method 2 to get current location
    position = await geolocator.Geolocator.getCurrentPosition(
      desiredAccuracy: geolocator.LocationAccuracy.high,
    );
    List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _initialPostion = LatLng(position.latitude, position.longitude);
      _locationController.text = placemark[0].name!;
      for (var element in placemark) {
        print("place marker name ${element.name}");
        print("place marker street ${element.street}");
        print("place marker subLocality ${element.subLocality}");
        print("place marker country ${element.country}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  markers: _markers,
                  polylines: _polyLines,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(
                          _initialPostion.latitude, _initialPostion.longitude),
                      zoom: 16),
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
                      onSubmitted: (value) {
                        sendRequest(value);
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
                        contentPadding:
                            const EdgeInsets.only(left: 15.0, top: 16.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  //  TO CREATE ROUTE
  void createRoute(String encondedPoly) {
    _polyLines.add(Polyline(
        polylineId: PolylineId(_finalPostion.toString()),
        width: 5,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: Colors.red));
  }

  // DECODE POLY
  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    List lList = [];
    int index = 0;
    int len = poly.length;
    int c = 0;
// repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

/*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) {
      lList[i] += lList[i - 2];
    }

    print(lList.toString());

    return lList;
  }

  //CREATE LAGLNG LIST
  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  void _addMarker(LatLng destination, String address) {
    print("marker");
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(_finalPostion.toString()),
          position: destination,
          infoWindow: InfoWindow(title: address, snippet: "go here"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueMagenta)));
      print("markers ${_markers.length}");
    });
  }

  void _onMapTapped(LatLng latLng) {
    setState(() {
      _finalPostion = latLng;
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

  //  SEND REQUEST
  void sendRequest(String intendedLocation) async {
    // List<Placemark> placemark =
    //     await Geolocator().placemarkFromAddress(intendedLocation);

    try {
      List<Location> placemark = await locationFromAddress(intendedLocation);
      double latitude = placemark[0].latitude;
      double longitude = placemark[0].longitude;
      LatLng destination = LatLng(latitude, longitude);
      _addMarker(destination, intendedLocation);
      print("des lat $latitude dis lon $longitude");
      String route = await _googleMapsServices.getRouteCoordinates(
          _initialPostion, destination);
      createRoute(route);
      setState(() {});
    } catch (e) {
      print("from error catch get route $e");
    }
  }

  void onCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void onCameraMove(CameraPosition position) {
    setState(() {
      _finalPostion = position.target;
      print("_final $_finalPostion");
    });
  }
}
