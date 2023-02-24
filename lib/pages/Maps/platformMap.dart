import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

class MyPlatformMap extends StatefulWidget {
  @override
  _MyPlatformMapState createState() => _MyPlatformMapState();
}

class _MyPlatformMapState extends State<MyPlatformMap> {
  Position? _currentPosition;
  PlatformMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PlatformMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(46.2276, 2.2137), // position par défaut
            zoom: 14.0,
          ),
          onMapCreated: (controller) {
            setState(() {
              _mapController = controller;
            });
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    await Geolocator.requestPermission();
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = position;
    });

    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      ));
    }
  }
}