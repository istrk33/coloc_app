import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyNavigatorMap extends StatefulWidget {
  @override
  _MyNavigatorMapState createState() => _MyNavigatorMapState();
}

class _MyNavigatorMapState extends State<MyNavigatorMap> {
  late GoogleMapController _mapController;
  late LatLng _defaultLocation;
  late LatLng _currentLocation;

  @override
  void initState() {
    super.initState();
    _defaultLocation = LatLng(46.2276, 2.2137);
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _defaultLocation,
          zoom: 14.0,
        ),
        onMapCreated: (controller) {
          setState(() {
            _mapController = controller;
          });
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    await Geolocator.requestPermission();
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    if (_mapController != null && _currentLocation != null) {
      _mapController.animateCamera(CameraUpdate.newLatLng(_currentLocation));
    }
  }
}
