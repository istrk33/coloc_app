import 'package:coloc_app/themes/color.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeTenant extends StatelessWidget {
  const HomeTenant({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var locale = 'fr';
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    return Container(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: CupertinoSearchTextField(
              placeholder: 'Rechercher',
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection("announce").snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                final snap = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: snap.length,
                  itemBuilder: (context, index) {
                    String imgUrl = snap[index]['img_url'].toString();
                    return Container(
                      height: 160,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: MyTheme.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 0.5,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 100,
                              width: 120,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(imgUrl),
                                      fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(50, 10, 0, 0),
                            alignment: Alignment.topCenter,
                            child: Text(
                              snap[index]['title'],
                              style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(130, 0, 0, 0),
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${'-' + snap[index]['description'].substring(0, 200)}...',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              snap[index]['price'].toString() + "\u{20AC}",
                              style: TextStyle(
                                color: Colors.green.withOpacity(0.7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 0, 10, 5),
                            alignment: Alignment.bottomRight,
                            child: Text(
                              timeago
                                  .format(
                                      snap[index]['date_publication'].toDate(),
                                      locale: locale)
                                  .toString(),
                              style: const TextStyle(
                                color: Color.fromARGB(255, 24, 1, 1),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return const SizedBox();
              }
            },
          )
        ],
      ),
    );
  }
}
