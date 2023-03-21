import 'package:coloc_app/themes/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
final User? currentUser = auth.currentUser;

class TaskManagement extends StatefulWidget {
  final String idAnnounce;

  const TaskManagement({Key? key, required this.idAnnounce}) : super(key: key);

  @override
  _TaskManagementState createState() => _TaskManagementState();
}

class _TaskManagementState extends State<TaskManagement> {
  late DateTime _endDate;
  late String _selectedCandidateName;
  late List<String> _candidateNames;
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDescriptionController =
      TextEditingController();
  final DateFormat formatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _selectedCandidateName = "";
    _candidateNames = [];
    _getCandidateNames();
    _endDate = DateTime.now();
  }

  Future<void> _getCandidateNames() async {
    final acceptedCandidatesSnapshot = await FirebaseFirestore.instance
        .collection('application')
        .where('id_announce',
            isEqualTo: FirebaseFirestore.instance
                .doc('/announce/' + widget.idAnnounce))
        .where('state', isEqualTo: 'accepted')
        .get();

    final candidateIds = acceptedCandidatesSnapshot.docs
        .map((doc) => doc['id_candidate'].id as String)
        .toList();

    final candidateNamesSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where(FieldPath.documentId, whereIn: candidateIds)
        .get();

    final candidateNames = candidateNamesSnapshot.docs
        .map((doc) => doc['first_last_name'] as String)
        .toList();

    setState(() {
      _candidateNames = candidateNames;
      _selectedCandidateName =
          _candidateNames.isNotEmpty ? _candidateNames[0] : "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: _taskNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: 'Nom de la tâche',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _taskDescriptionController,
                maxLines: 8,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: 'Description de la tâche',
                ),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedCandidateName,
                items: _candidateNames
                    .map((candidateName) => DropdownMenuItem(
                        child: Text(candidateName), value: candidateName))
                    .toList(),
                onChanged: (newCandidateName) {
                  setState(() {
                    _selectedCandidateName = newCandidateName!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  labelText: 'Attribué à',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Date de fin : ${formatter.format(_endDate).toString()}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: MyTheme.blue3,
                  decoration: TextDecoration.none,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? newEndDate = await showDatePicker(
                    context: context,
                    initialDate: _endDate,
                    firstDate: DateTime.now().subtract(Duration(days: 365)),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (newEndDate != null) {
                    setState(() {
                      _endDate = newEndDate;
                    });
                  }
                },
                child: Text('Modifier la date écheante'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_taskNameController.text.isNotEmpty) {
                    // Submit form
                    final CollectionReference<Map<String, dynamic>> Users =
                        FirebaseFirestore.instance.collection('Users');
                    final DocumentReference<Map<String, dynamic>>
                        creatorUserRef =
                        Users.doc(auth.currentUser!.uid.toString());

                    final userRef = FirebaseFirestore.instance
                        .collection('Users')
                        .where('first_last_name',
                            isEqualTo: _selectedCandidateName)
                        .limit(1);

                    final querySnapshot = await userRef.get();
                    final assignedUserDocRef =
                        querySnapshot.docs.first.reference;

                    final CollectionReference<Map<String, dynamic>> announces =
                        FirebaseFirestore.instance.collection('announce');
                    final DocumentReference<Map<String, dynamic>> announceRef =
                        announces.doc(widget.idAnnounce);

                    final collectionApplication =
                        FirebaseFirestore.instance.collection('task');
                    await collectionApplication.add({
                      'id_announce': announceRef,
                      'id_creator': creatorUserRef,
                      'id_assigned': assignedUserDocRef,
                      'task_name': _taskNameController.text,
                      'task_description': _taskDescriptionController.text,
                      'task_start_date': DateTime.now(),
                      'task_end_date': _endDate,
                      'state': "ongoing",
                    });
                    Fluttertoast.showToast(
                      msg: "tâche ajoutée",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: MyTheme.blue2,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else {
                    if (_taskNameController.text.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Impossible de créer la tâche'),
                            content: Text(
                                'Le nom de la tâche ne peut pas être vide.'),
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
                },
                child: Text('Ajouter la tâche'),
              ),
            ])));
  }
}
