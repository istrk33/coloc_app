import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PropertyImagePicker extends StatefulWidget {
  final dynamic Function(List<dynamic>) onImagesSelected;
  final List<String>? defaultImages;

  PropertyImagePicker({required this.onImagesSelected, this.defaultImages});

  @override
  _PropertyImagePickerState createState() => _PropertyImagePickerState();
}

class _PropertyImagePickerState extends State<PropertyImagePicker> {
  List<dynamic> _images = [];
  final double _imageSize = 100;

  @override
  void initState() {
    super.initState();
    _images = widget.defaultImages != null
        ? widget.defaultImages!.map((image) => image != null ? (image is String ? image : File(image)) : null).toList()
        : List.generate(3, (index) => null);
  }

  Future<void> _getImage(int index) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final newImage = File(pickedFile.path);

      setState(() {
        _images[index] = newImage;
      });

      _handleSelection(_images.where((image) => image != null).map((image) => image!).toList());
    }
  }

  _handleSelection(List<dynamic> images) {
    // final nonNullableImages = images
    //     .where((image) => image != null && !(image is String))
    //     .cast<File>()
    //     .toList(); // filtrer les éléments null avant de les convertir en une liste de File

    // widget.onImagesSelected(nonNullableImages);
    widget.onImagesSelected(images);
  }

  void _removeImage(int index) {
    setState(() {
      _images[index] = null;
    });
    _getImage(index);
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.defaultImages);
    // print(_images);
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: List.generate(
        3,
        (index) => GestureDetector(
          onTap: () => _images[index] != null ? _removeImage(index) : _getImage(index),
          child: Container(
            width: _imageSize,
            height: _imageSize,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: widget.defaultImages != null && widget.defaultImages![index] != null && widget.defaultImages![index] == _images[index]
                ? Image.network(
                    widget.defaultImages![index],
                    fit: BoxFit.cover,
                    key: UniqueKey(),
                  )
                : _images[index] != null
                    ? Image.file(
                        _images[index]!,
                        fit: BoxFit.cover,
                        key: UniqueKey(), // Ajouter une clé unique
                      )
                    : Icon(
                        Icons.camera_alt,
                        color: Colors.grey,
                      ),
          ),
        ),
      ),
    );
  }
}
