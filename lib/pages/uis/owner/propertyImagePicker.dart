import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PropertyImagePicker extends StatefulWidget {
  // final dynamic Function(File) onImagesSelected;
  final dynamic Function(List<File>) onImagesSelected;

  PropertyImagePicker({required this.onImagesSelected});

  @override
  _PropertyImagePickerState createState() => _PropertyImagePickerState();
}

class _PropertyImagePickerState extends State<PropertyImagePicker> {
  List<File?> _images = [null, null, null];
  final double _imageSize = 100;

  Future<void> _getImage(int index) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    // if (mounted) {
    if (pickedFile != null && mounted) {
      setState(() {
        _images[index] = File(pickedFile.path);
      });
      _handleSelection(_images.where((image) => image != null).toList());
      if (_images[index] == null) {
        print('Erreur: _images[$index] est nul');
      }
    }
  }

  _handleSelection(List<File?> images) {
// _handleSelection(File image) {
    // Faire quelque chose avec les images sélectionnées ici
    final nonNullableImages = images.whereType<File>().toList();
    widget.onImagesSelected(
        nonNullableImages); // Appeler la fonction fournie par le parent avec les images sélectionnées
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: List.generate(
        3,
        (index) => GestureDetector(
          onTap: () => _getImage(index),
          child: Container(
            width: _imageSize,
            height: _imageSize,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _images[index] != null
                ? Image.file(
                    _images[index]!,
                    fit: BoxFit.cover,
                    key: UniqueKey(),
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
