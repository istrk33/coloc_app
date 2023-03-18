import 'package:coloc_app/pages/uis/common/profile.dart';
import 'package:coloc_app/pages/uis/common/announce_page.dart';
import 'package:coloc_app/themes/color.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeTenant extends StatelessWidget {
  final CollectionReference announceCollection =
      FirebaseFirestore.instance.collection('announce');
  final CollectionReference propertyCollection =
      FirebaseFirestore.instance.collection('property');
  List<Map<String, dynamic>> propertyList = [];

  HomeTenant({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var locale = 'fr';
    timeago.setLocaleMessages('fr', timeago.FrMessages());

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getAnnounceWithProperty(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          //print(snapshot.data![0]);
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> property = snapshot.data![index];
              String imgUrl = property['propertyImgUrl1'];
              Timestamp date = property['announceDate'];
              return InkWell(
                child: Container(
                  height: 225,
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    0,
                  ),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(
                      255,
                      255,
                      255,
                      255,
                    ),
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(
                          0.5,
                        ),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(
                          0,
                          3,
                        ), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(
                          0,
                          0,
                          0,
                          0,
                        ),
                        alignment: Alignment.topCenter,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          child: Container(
                            height: 125,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(imgUrl),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(
                          0,
                          40,
                          0,
                          0,
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          property['propertyName'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 120, 0, 0),
                        alignment: Alignment.center,
                        child: Text(
                          property['propertyDescription'].length > 200
                              ? '${'-' + property['propertyDescription'].substring(0, 200)}...'
                              : property['propertyDescription'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          bottom: 5,
                        ),
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          property['announcePrice'].toString() + "\u{20AC}",
                          style: TextStyle(
                            color: Colors.green.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(
                          0,
                          0,
                          10,
                          5,
                        ),
                        alignment: Alignment.bottomRight,
                        child: Text(
                          timeago
                              .format(date.toDate(), locale: locale)
                              .toString(),
                          style: const TextStyle(
                            color: Color.fromARGB(
                              255,
                              24,
                              1,
                              1,
                            ),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AnnouncePage(
                        announceId: snapshot.data![index]['announceId'],
                        announceTitle:
                            snapshot.data![index]['propertyName'].toString(),
                      ),
                    ),
                  );
                },
              );
            },
          );
        } else {
          return Text("Aucunes annonces disponible");
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAnnounceWithProperty() async {
    QuerySnapshot<Object?> announceSnap = await announceCollection.get();
    List propertyIds =
        announceSnap.docs.map((doc) => doc['property_id']).toList();

    QuerySnapshot<Map<String, dynamic>> propertySnap = await propertyCollection
        .where(FieldPath.documentId, whereIn: propertyIds)
        .get() as QuerySnapshot<Map<String, dynamic>>;

    List<Map<String, dynamic>> combinedData = [];

    for (var i = 0; i < announceSnap.docs.length; i++) {
      Map<String, dynamic> announceData =
          announceSnap.docs[i].data() as Map<String, dynamic>;
      var propertyData = propertySnap.docs[i].data();

      combinedData.add({
        'announceId': announceSnap.docs[i].id,
        'announcePrice': announceData!['price'],
        'announceDate': announceData!['date_publication'],
        'propertyId': propertySnap.docs[i].id,
        'propertyName': propertyData['property_name'],
        'propertyDescription': propertyData['description'],
        'propertyImgUrl1': propertyData['imageUrl1'],
      });
    }

    print(combinedData);
    return combinedData;
  }
}
