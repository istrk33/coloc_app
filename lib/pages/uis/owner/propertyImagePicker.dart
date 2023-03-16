import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PropertyImagePicker extends StatefulWidget {
  final Function(List<dynamic>) onImagesSelected;
  final List<dynamic>? defaultImages;

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
        ? widget.defaultImages!
            .map(
              (image) => image != null ? (image is String ? image : File(image)) : null,
            )
            .toList()
        : List.generate(3, (index) => null);
  }

  Future<void> _getImage(int index) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final newImage = File(pickedFile.path);

      setState(() {
        if (index < _images.length) {
          _images[index] = newImage;
        } else {
          _images.add(newImage);
        }
      });

      _handleSelection(_images.where((image) => image != null).toList());
    }
  }

  _handleSelection(List<dynamic> images) {
    widget.onImagesSelected(images);
  }

  void _removeImage(int index) {
    setState(() {
      _images[index] = null;
    });
    _getImage(index);
  }

  Widget _buildImageWidget(int index) {
    final dynamic image = (index < _images.length) ? _images[index] : null;

    if (image == null) {
      return Icon(
        Icons.camera_alt,
        color: Colors.grey,
      );
    }

    if (image is String) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        key: UniqueKey(),
      );
    }

    return Image.file(
      image,
      fit: BoxFit.cover,
      key: UniqueKey(),
    );
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
          onTap: () => _images.length < index && _images[index] != null ? _removeImage(index) : _getImage(index),
          child: Container(
            width: _imageSize,
            height: _imageSize,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildImageWidget(index),
          ),
        ),
      ),
    );
  }
}
