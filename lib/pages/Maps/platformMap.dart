import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyPlatformMap extends StatefulWidget {
  @override
  _MyPlatformMapState createState() => _MyPlatformMapState();
}

class _MyPlatformMapState extends State<MyPlatformMap> {
  Position? _currentPosition;
  PlatformMapController? _mapController;
  late BitmapDescriptor customIcon;
  Map<MarkerId, Marker> markers = <MarkerId , Marker>{};


  void initMarker(specify , specifyId) async {
    var markerIdVal = specifyId;
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(specify['position'].latitude, specify['position'].longitude),
      infoWindow: InfoWindow(title: specify['property_name'], snippet: specify['address']),
      icon: customIcon);
      setState(() {
        markers[markerId] = marker;
      });
  }


  getMarkerdata() async {
    FirebaseFirestore.instance.collection('property').get().then((MyMockData) {
      if(MyMockData.docs.isNotEmpty){
        for(int i = 0; i < MyMockData.docs.length; i++) {
            initMarker(MyMockData.docs[i].data(), MyMockData.docs[i].id);
        }
      }
    });
  }

  @override
  void initState() {
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(12, 12)), 'assets/images/house.png')
        .then((onValue) {
      customIcon = onValue;
    });

    _getCurrentLocation();
    getMarkerdata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PlatformMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(44.836151, 0.580816), // position par défaut
            zoom: 13.0,
          ),
          markers: Set<Marker>.of(markers.values),
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