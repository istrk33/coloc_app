import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class MyMap extends StatefulWidget {
//   @override
//   _MyMapState createState() => _MyMapState();
// }

// class _MyMapState extends State<MyMap> {
//   late GoogleMapController mapController;
//   late Position _position = Position(
//       longitude: -0.57918,
//       latitude: 44.837789,
//       timestamp: DateTime.now(),
//       accuracy: 0,
//       altitude: 0,
//       heading: 0,
//       speed: 0,
//       speedAccuracy: 0);
//   Set<Marker> _markers = Set<Marker>();
//   late bool _locationPermissionGranted=false;

//   @override
//   void initState() {
//     super.initState();
//     _getLocationPermission();
//   }

//   Future<void> _getLocationPermission() async {
//     bool permission = await Geolocator.isLocationServiceEnabled();
//     LocationPermission lpv;
//     if (permission) {
//       lpv = await Geolocator.checkPermission();
//       // ignore: unrelated_type_equality_checks
//       if (permission == LocationPermission.denied) {
//         lpv = await Geolocator.requestPermission();
//         // ignore: unrelated_type_equality_checks
//         if (permission == LocationPermission.denied) {
//           _locationPermissionGranted = false;
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         _locationPermissionGranted = false;
//         return;
//       }

//       _locationPermissionGranted = true;
//       _getCurrentLocation();
//     } else {
//       _locationPermissionGranted = false;
//     }
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition();
//       setState(() {
//         _position = position;
//         _markers.add(Marker(
//           markerId: MarkerId('user_location'),
//           position: LatLng(position.latitude, position.longitude),
//         ));
//       });
//     } catch (e) {
//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _locationPermissionGranted == true
//           ? GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: LatLng(_position.latitude, _position.longitude),
//                 zoom: 11.0,
//               ),
//               onMapCreated: (GoogleMapController controller) {
//                 mapController = controller;
//               },
//               // mapType: MapType.hybrid,
//               myLocationEnabled: true,
//               myLocationButtonEnabled: true,
//               markers: _markers,
//             )
//           : kIsWeb
//               ? GoogleMap(
//                   initialCameraPosition: CameraPosition(
//                     target: LatLng(_position.latitude, _position.longitude),
//                     zoom: 11.0,
//                   ),
//                   onMapCreated: (GoogleMapController controller) {
//                     mapController = controller;
//                   },
//                 )
//               : Center(
//                   child: Text('Location permission denied'),
//                 ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  Position _currentPosition = Position(
      longitude: -0.57918,
      latitude: 44.837789,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  _getCurrentLocation() async {
    final position = await _geolocatorPlatform.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        body: SafeArea(
          child: PlatformMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(44.837789, -0.57918),
              zoom: 15.0,
            ),
            mapType: MapType.normal,
            compassEnabled: true,
            trafficEnabled: false,
            // map
            // buildingsEnabled: true,
            // ind: true,
            myLocationEnabled: true,
            // showPointsOfInterest: false,
            onMapCreated: (controller) {
              if (_currentPosition != null) {
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(
                        _currentPosition.latitude,
                        _currentPosition.longitude,
                      ),
                      zoom: 15.0,
                    ),
                  ),
                );
              }
            },
          ),
        ),
      );
    } else {
      return Scaffold(
        body: SafeArea(
          child: PlatformMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(44.837789, -0.57918),
              zoom: 15.0,
            ),
            mapType: MapType.normal,
            compassEnabled: true,
            trafficEnabled: false,
            // map
            // buildingsEnabled: true,
            // ind: true,
            myLocationEnabled: true,
            // showPointsOfInterest: false,
            onMapCreated: (controller) {
              if (_currentPosition != null) {
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(
                        _currentPosition.latitude,
                        _currentPosition.longitude,
                      ),
                      zoom: 15.0,
                    ),
                  ),
                );
              }
            },
          ),
        ),
      );
    }
  }
}
