import 'package:coloc_app/themes/color.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart' as depLat;
import 'package:search_map_place_updated/search_map_place_updated.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart' as Lot;

FirebaseAuth auth = FirebaseAuth.instance;
final User? currentUser = auth.currentUser;

class MyNavigatorMap extends StatefulWidget {
  @override
  _MyNavigatorMapState createState() => _MyNavigatorMapState();
}

class _MyNavigatorMapState extends State<MyNavigatorMap> {
  final CollectionReference announceCollection =
      FirebaseFirestore.instance.collection('announce');
  final CollectionReference propertyCollection =
      FirebaseFirestore.instance.collection('property');

  String imgUrl = "";
  String announceTitle = "";
  String announceId = "";
  String rentValue = "";
  String roommatesNumber = "";
  String depositAmount = "";
  String description = "";

  Position? _currentPosition;
  GoogleMapController? _mapController;
  late BitmapDescriptor customIcon;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  void _showModalBottomSheet(BuildContext context, String id) async {
    await _loadAnnounceData(id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(30),
      )),
      builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.32,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              clipBehavior: Clip.none,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)),
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(imgUrl),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            Text('no url specified');
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                      announceTitle,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                        letterSpacing: 0.27,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                      rentValue.toString() + '\u{20AC}',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: MyTheme.blue3,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: <Widget>[
                        getTimeBoxUI(
                            roommatesNumber.toString(), 'Colocataires'),
                        getTimeBoxUI(
                            depositAmount.toString() + '\u{20AC}', 'Caution'),
                        getTimeBoxUI('3', 'Chambres'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                    child: Text(
                      description,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                        fontSize: 14,
                        letterSpacing: 0.27,
                        color: Color.fromARGB(255, 26, 26, 26),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _applicationBottomSheet(context);
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(180, 40),
                        primary: MyTheme.blue3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      child: Text(
                        'Candidater',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }

  void _applicationBottomSheet(BuildContext context) async {
    final _descriptionController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(30),
      )),
      builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.9,
          minChildSize: 0.32,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              clipBehavior: Clip.none,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(15, 15, 15, 30),
                    child: Container(
                      child: TextFormField(
                        controller: _descriptionController,
                        maxLines: null,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 0,
                  ),
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(180, 40),
                          backgroundColor: MyTheme.blue3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                        child: Text(
                          'Canditater',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                        onPressed: () async {
                          if (_descriptionController.text.isNotEmpty) {
                            // Submit form
                            final CollectionReference<Map<String, dynamic>>
                                users =
                                FirebaseFirestore.instance.collection('Users');
                            final DocumentReference<Map<String, dynamic>>
                                userRef =
                                users.doc(auth.currentUser!.uid.toString());

                            final collectionApplication = FirebaseFirestore
                                .instance
                                .collection('application');
                            await collectionApplication.add({
                              'id_candidate': userRef,
                              'id_announce': announceId,
                              'description': _descriptionController.text
                            });
                            Navigator.pop(context);
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Lot.Lottie.network(
                                      'https://assets1.lottiefiles.com/packages/lf20_Nd1IlGbdnB.json',
                                      repeat: false,
                                    ),
                                  );
                                });
                          } else {
                            if (_descriptionController.text.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Impossible de candidater'),
                                    content: Text(
                                        'La description ne peut pas être vide, présentez vous brievement.'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('Fermer'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        }),
                  )
                ],
              ),
            );
          }),
    );
  }

  void initMarker(String id, double latitude, double longitude) async {
    var markerIdVal = id.toString();
    final LatLng _latLng = LatLng(latitude, longitude);
    final MarkerId markerId = MarkerId(id);
    final Marker marker = Marker(
      markerId: markerId,
      position: _latLng,
      consumeTapEvents: false,
      // infoWindow: InfoWindow(
      //title: specify['property_name'], snippet: specify['address']),
      icon: customIcon,
      onTap: () {
        _showModalBottomSheet(context, id);
      },
    );
    setState(() {
      markers[markerId] = marker;
    });
  }

  Future<void> _loadAnnounceData(id) async {
    final propertyRef =
        FirebaseFirestore.instance.collection('property').doc(id);
    final propertySnapshot = await propertyRef.get();

    if (propertySnapshot.exists) {
      final announceData = await FirebaseFirestore.instance
          .collection('announce')
          .where('property_id', isEqualTo: propertyRef)
          .get();

      if (announceData.size == 1) {
        final announceSnapshot = announceData.docs[0];
        final data = announceSnapshot.data();
        final propertyData = propertySnapshot.data();
        announceTitle = propertyData!['property_name'];
        announceId = announceSnapshot.id;
        imgUrl = propertyData['imageUrl1'];
        rentValue = data['price'];
        roommatesNumber = data['max_roomates'];
        depositAmount = data['deposit_amount'];
        description = propertyData['description'];
      } else {
        throw Exception(
            'Aucune annonce trouvée pour l\'ID de propriété spécifié.');
      }
    } else {
      throw Exception('Aucune propriété trouvée pour l\'ID spécifié.');
    }
  }

  Future<void> initMarkersData() async {
    List<Map<String, dynamic>> propertyList = await getAnnounceWithProperty();
    print(propertyList);

    propertyList.forEach((property) {
      String id = property['id'];
      GeoPoint location = property['location'];

      initMarker(id, location.latitude, location.longitude);
    });
  }

  Future<List<Map<String, dynamic>>> getAnnounceWithProperty() async {
    QuerySnapshot<Object?> announceSnap = await announceCollection.get();
    List propertyIds =
        announceSnap.docs.map((doc) => doc['property_id']).toList();

    QuerySnapshot<Map<String, dynamic>> propertySnap = await propertyCollection
        .where(FieldPath.documentId, whereIn: propertyIds)
        .get() as QuerySnapshot<Map<String, dynamic>>;

    List<Map<String, dynamic>> propertyList = propertySnap.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      return {
        'id': doc.id,
        'location': data['position'],
      };
    }).toList();

    return propertyList;
  }

  @override
  void initState() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(12, 12)), 'assets/images/house.png')
        .then((onValue) {
      customIcon = onValue;
    });

    _getCurrentLocation();
    initMarkersData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(44.836151, 0.580816), // position par défaut
              zoom: 12.0,
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
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: SearchMapPlaceWidget(
                iconColor: MyTheme.blue3,
                bgColor: Colors.white.withOpacity(0.8),
                textColor: MyTheme.blue3,
                apiKey: 'AIzaSyC4svFwOreKsSB4vNYxgkRJXLd3WufLflc',
                placeholder: 'Rechercher une ville',
                language: 'fr',
                onSelected: (Place place) async {
                  final geolocation = await place.geolocation;
                  _mapController!.animateCamera(CameraUpdate.newLatLng(LatLng(
                      geolocation!.coordinates.latitude,
                      geolocation.coordinates.longitude)));
                },
              ),
            ),
          ),
        ],
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

  Widget getTimeBoxUI(String text1, String txt2) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                offset: const Offset(1.1, 1.1),
                blurRadius: 8.0),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 18.0, right: 18.0, top: 12.0, bottom: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                text1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.27,
                  color: MyTheme.blue3,
                ),
              ),
              Text(
                txt2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w200,
                  fontSize: 14,
                  letterSpacing: 0.27,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
