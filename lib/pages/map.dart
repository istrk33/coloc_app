import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const LatLng supDeVinciLocation =
    LatLng(44.854830739597155, -0.5724543809643035);

class Map extends StatelessWidget {
  const Map({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Material App
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        // Scaffold Widget
        home: Scaffold(
            body: GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: supDeVinciLocation, zoom: 13))));
  }
}
