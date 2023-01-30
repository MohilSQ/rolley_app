import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';

class MapView extends StatefulWidget {
  String address;
  String lat;
  String lon;
  MapView({
    this.address = "",
    this.lat = "",
    this.lon = "",
  });
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  GoogleMapController mapController;

  Position _currentPosition;
  String _currentAddress = '';

  String _startAddress = '';
  String _destinationAddress = '';
  String _placeDistance;

  Set<Marker> markers = {};

  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  String apiKey = Platform.isAndroid ? Constants.androidPlacesApi : Constants.iosPlacesApi;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) async {
      setState(() {
        _currentPosition = position;
        debugPrint('CURRENT POS: --------------->>> $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      debugPrint(e);
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(_currentPosition.latitude, _currentPosition.longitude);
      Placemark place = p[0];
      _currentAddress = "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
      debugPrint('Current Address POS: --------------->>> $_currentAddress');
      _startAddress = _currentAddress;
      debugPrint('Start Address: --------------->>> $_startAddress');
      _destinationAddress = widget.address;
      debugPrint('Destination Address: --------------->>> $_destinationAddress');
      setState(() {});
      await _createRout();
    } catch (e) {
      debugPrint(e);
    }
  }

  _createRout() async {
    setState(() {
      if (markers.isNotEmpty) markers.clear();
      if (polylines.isNotEmpty) polylines.clear();
      if (polylineCoordinates.isNotEmpty) polylineCoordinates.clear();
      _placeDistance = null;
    });

    _calculateDistance().then((isCalculated) {
      if (isCalculated) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Distance Calculated Successfully')));
      }
    });
  }

  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    try {
      // Retrieving placemarks from addresses
      List<Location> startPlacemark = await locationFromAddress(_startAddress);
      List<Location> destinationPlacemark = await locationFromAddress(_destinationAddress);

      // Use the retrieved coordinates of the current position,
      // instead of the address if the start position is user's
      // current position, as it results in better accuracy.
      double startLatitude = _startAddress == _currentAddress ? _currentPosition.latitude : startPlacemark[0].latitude;

      double startLongitude = _startAddress == _currentAddress ? _currentPosition.longitude : startPlacemark[0].longitude;

      double destinationLatitude = destinationPlacemark[0].latitude;
      double destinationLongitude = destinationPlacemark[0].longitude;

      String startCoordinatesString = '($startLatitude, $startLongitude)';
      String destinationCoordinatesString = '($destinationLatitude, $destinationLongitude)';

      // Start Location Marker
      Marker startMarker = Marker(
        markerId: MarkerId(startCoordinatesString),
        position: LatLng(startLatitude, startLongitude),
        infoWindow: InfoWindow(
          title: 'Start $startCoordinatesString',
          snippet: _startAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Destination Location Marker
      Marker destinationMarker = Marker(
        markerId: MarkerId(destinationCoordinatesString),
        position: LatLng(destinationLatitude, destinationLongitude),
        infoWindow: InfoWindow(
          title: 'Destination $destinationCoordinatesString',
          snippet: _destinationAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Adding the markers to the list
      markers.add(startMarker);
      markers.add(destinationMarker);

      debugPrint('START COORDINATES:  --------------->>> ($startLatitude, $startLongitude)');
      debugPrint('DESTINATION COORDINATES:  --------------->>> ($destinationLatitude, $destinationLongitude)');

      // Calculating to check that the position relative
      // to the frame, and pan & zoom the camera accordingly.
      double miny = (startLatitude <= destinationLatitude) ? startLatitude : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude) ? startLongitude : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude) ? destinationLatitude : startLatitude;
      double maxx = (startLongitude <= destinationLongitude) ? destinationLongitude : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      // Accommodate the two locations within the
      // camera view of the map
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );

      await _createPolyLines(startLatitude, startLongitude, destinationLatitude, destinationLongitude);

      double totalDistance = 0.0;

      // Calculating the total distance by adding the distance
      // between small segments
      for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        totalDistance += _coordinateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude,
        );
      }

      setState(() {
        _placeDistance = totalDistance.toStringAsFixed(2);
        debugPrint('DISTANCE:  --------------->>> $_placeDistance km');
      });
      return true;
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  // Formula for calculating distance between two coordinates
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Create the polylines for showing the route between two places
  _createPolyLines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints
        .getRouteBetweenCoordinates(
      apiKey,
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
    )
        .then((value) async {
      debugPrint('Result Points: --------------->> ${value.errorMessage}');
      return value;
    });

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () => _getCurrentLocation());
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: AppTheme.gray,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leadingWidth: SV.setWidth(200),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              color: Colors.transparent,
              child: Row(
                children: [
                  SizedBox(width: SV.setWidth(20)),
                  Image.asset(
                    'assets/images/ic_back.png',
                    height: SV.setWidth(70),
                    width: SV.setWidth(60),
                  ),
                  SizedBox(width: SV.setWidth(20)),
                  Image.asset(
                    'assets/images/ic_logo_appbar.png',
                    height: SV.setWidth(70),
                    width: SV.setWidth(70),
                  ),
                ],
              ),
            ),
          ),
          title: Center(
            child: Text(
              'Map View',
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: SV.setSP(60),
                color: AppTheme.black,
              ),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: SV.setWidth(180),
                color: Colors.transparent,
              ),
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            // Map View
            GoogleMap(
              markers: Set<Marker>.from(markers),
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
            // Show zoom buttons
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipOval(
                      child: Material(
                        color: Colors.blue.shade100, // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.add),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ClipOval(
                      child: Material(
                        color: Colors.blue.shade100, // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.remove),
                          ),
                          onTap: () {
                            mapController.animateCamera(CameraUpdate.zoomOut());
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Show the place input fields & button for
            // showing the route
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: SV.setHeight(20)),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  width: width * 0.95,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(SV.setHeight(25))),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Places',
                        style: TextStyle(
                          fontSize: SV.setWidth(60),
                          fontWeight: FontWeight.w600,
                          color: AppTheme.orange,
                        ),
                      ),
                      SizedBox(height: SV.setHeight(15)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Address: ',
                            style: TextStyle(
                              fontSize: SV.setWidth(40),
                              fontWeight: FontWeight.w500,
                              color: AppTheme.lightGray,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.address,
                              style: TextStyle(
                                fontSize: SV.setWidth(40),
                                fontWeight: FontWeight.w400,
                                color: AppTheme.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: SV.setHeight(15)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Distance: ',
                            style: TextStyle(
                              fontSize: SV.setWidth(40),
                              fontWeight: FontWeight.w500,
                              color: AppTheme.lightGray,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${_placeDistance ?? "00"} km',
                              style: TextStyle(
                                fontSize: SV.setWidth(45),
                                fontWeight: FontWeight.w500,
                                color: AppTheme.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.my_location),
          backgroundColor: AppTheme.orange,
          onPressed: () {
            mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  zoom: 18.0,
                  target: LatLng(
                    _currentPosition.latitude,
                    _currentPosition.longitude,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
