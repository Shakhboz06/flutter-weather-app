import 'package:flutter/material.dart';

class additional_info_item extends StatelessWidget {
  final IconData icon;
  // final IconData color;
  // final Colors color;
  final String text;
  final String value;

  const additional_info_item({
    super.key,
    required this.icon,
    // required this.color,
    required this.text,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.orangeAccent,
          size: 32,
        ),
        Text(
          text,
          style: const TextStyle(fontFamily: 'LXGWWenKai', color: Colors.white),
        ),
        Text(
          value,
          style: const TextStyle(fontFamily: 'LXGWWenKai', color: Colors.white),
        ),
      ],
    );
  }
}

class additional_info extends StatelessWidget {
  late String image;
  late String text;
  late String value;

  additional_info({
    super.key,
    required this.image,
    required this.text,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          image,
          scale: 7,
        ),
        Text(
          text,
          style: const TextStyle(fontFamily: 'LXGWWenKai', color: Colors.white),
        ),
        Text(
          value,
          style: const TextStyle(fontFamily: 'LXGWWenKai', color: Colors.white),
        ),
      ],
    );
  }
}
