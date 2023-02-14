import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
  }

  Future<void> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Afficher un message d'erreur et demander à l'utilisateur d'autoriser manuellement les autorisations de localisation.
      }
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      getCurrentLocation();
    }
  }

  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _markers.add(
        Marker(
          markerId: MarkerId('Ma position'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: 'Ma position'),
        ),
      );
    });
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 16,
        ),
      ));
    }
    // _mapController!.animateCamera(CameraUpdate.newCameraPosition(
    //   CameraPosition(
    //     target: LatLng(position.latitude, position.longitude),
    //     zoom: 16,
    //   ),
    // ));
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return Container();
    }

    CameraPosition initialCameraPosition = CameraPosition(
        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: 15);

    return GoogleMap(
      markers: _markers,
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      // mapType: MapType.satellite,
      initialCameraPosition: CameraPosition(
        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: 13,
      ),
    );
  }
}
