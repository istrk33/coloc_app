import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'package:geolocator_web/geolocator_web.dart';
// import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Geolocator _geolocator = Geolocator();
  late Position _position = Position(
    latitude: 44.837789,
    longitude: -0.57918,
    speed: 0,
    altitude: 0,
    accuracy: 0,
    heading: 0,
    speedAccuracy: 0,
    timestamp: DateTime.now(),
  );
  late PlatformMapController _mapController;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Handle denied permission
      print('Permission denied');
    } else if (permission == LocationPermission.deniedForever) {
      // Handle permanently denied permission
      print('Permission permanently denied');
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final Position newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _position = newPosition;
      });
      _mapController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_position.latitude, _position.longitude),
        ),
      );
    } catch (e) {
      print('Could not get location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlatformMap(
        onMapCreated: (controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(37.422, -122.084),
          zoom: 15,
        ),
        markers: _position != null
            ? Set<Marker>.of([
                Marker(
                  markerId: MarkerId("currentPosition"),
                  position: LatLng(_position.latitude, _position.longitude),
                  infoWindow: InfoWindow(
                    title: "Current Position",
                    snippet:
                        "Lat: ${_position.latitude}, Long: ${_position.longitude}",
                  ),
                ),
              ])
            : Set<Marker>(),
      ),
    );
  }
}
