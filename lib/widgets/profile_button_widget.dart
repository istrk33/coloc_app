import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final Icon icon;
  final VoidCallback onClicked;
  final Color bgcolor;

  const ButtonWidget({
    Key? key,
    required this.text,
    required this.onClicked,
    required this.icon,
    required this.bgcolor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          shape: StadiumBorder(),
          backgroundColor: this.bgcolor,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        label: Text(this.text),
        onPressed: this.onClicked,
        icon: this.icon,
      );
}
