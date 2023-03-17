import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PropertyImagePicker extends StatefulWidget {
  final Function(dynamic) onImagesSelected;
  final dynamic defaultImage;

  PropertyImagePicker({required this.onImagesSelected, this.defaultImage});

  @override
  _PropertyImagePickerState createState() => _PropertyImagePickerState();
}

class _PropertyImagePickerState extends State<PropertyImagePicker> {
  dynamic _image;
  final double _imageSize = 100;

  @override
  void initState() {
    super.initState();
    _image = widget.defaultImage != null ? widget.defaultImage: null;
  }

  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final newImage = File(pickedFile.path);

      setState(() {
        _image = newImage;
      });

      _handleSelection(_image);
    }
  }

  _handleSelection(dynamic image) {
    print(image);
    widget.onImagesSelected(image);
  }

  Widget _buildImageWidget() {
    print("======================================================================");
    print(_image);
    print("======================================================================");
    if (_image == null) {
      return Icon(
        Icons.camera_alt,
        color: Colors.grey,
      );
    }

    if (_image is String) {
      return Image.network(
        _image,
        fit: BoxFit.cover,
        key: UniqueKey(),
      );
    }

    return Image.file(
      _image,
      fit: BoxFit.cover,
      key: UniqueKey(),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("======================================================================");
    print("BUILDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
    print("======================================================================");
    return GestureDetector(
      onTap: _getImage,
      child: Container(
        width: _imageSize,
        height: _imageSize,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _buildImageWidget(),
      ),
    );
  }
}
