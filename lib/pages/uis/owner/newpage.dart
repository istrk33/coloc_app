import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseListWidget extends StatefulWidget {
  FirebaseListWidget({Key? key}) : super(key: key);

  @override
  _FirebaseListWidgetState createState() => _FirebaseListWidgetState();
}

class _FirebaseListWidgetState extends State<FirebaseListWidget> {
  late TextEditingController _searchController;
  List<DocumentSnapshot> _searchResult = [];
  List<DocumentSnapshot> _documentList = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('property').get();
    setState(() {
      _documentList = snapshot.docs;
    });
  }

  void _onSearchTextChanged(String searchText) {
    _searchResult.clear();
    if (searchText.isEmpty) {
      setState(() {});
      return;
    }

    _documentList.forEach((document) {
      if (document['title'].toLowerCase().contains(searchText.toLowerCase())) {
        _searchResult.add(document);
      }
    });

    setState(() {});
  }

  void _onEditButtonPressed(DocumentSnapshot document) {
    // TODO: Implement editing functionality
  }

  void _onDeleteButtonPressed(DocumentSnapshot document) {
    // TODO: Implement deletion functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
              ),
              onChanged: _onSearchTextChanged,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResult.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = _searchResult[index];
                return ListTile(
                  title: Text(document['property_name']),
                  subtitle: Text(document['description']),
                  onTap: () {
                    // TODO: Implement item tapping functionality
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _onEditButtonPressed(document),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _onDeleteButtonPressed(document),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
