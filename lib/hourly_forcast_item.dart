import 'package:flutter/material.dart';

class hourly_forcast_item extends StatelessWidget {
  final String time, temp, image;

  const hourly_forcast_item({
    super.key,
    required this.time,
    required this.temp,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 115,
      child: Card(
        elevation: 6,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'LXGWWenKai',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Image.asset(image),
              const SizedBox(
                height: 5,
              ),
              Text(
                '$temp°C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String getImageForWeather(String iconCode) {
  switch (iconCode) {
    case '01d':
      return 'images/6.png';
    case '01n':
      return 'images/18.png';
    case '02d':
      return 'images/7.png';
    case '02n':
      return 'images/19.png';
    case '03d':
    case '03n':
      return 'images/8.png';
    case '04d':
    case '04n':
      return 'images/8.png';
    case '09d':
    case '09n':
      return 'images/2.png';
    case '10d':
      return 'images/3.png';
    case '10n':
      return 'images/3.png';
    case '11d':
    case '11n':
      return 'images/1.png';
    case '13d':
    case '13n':
      return 'images/4.png';
    case '50d':
    case '50n':
      return 'images/5.png';
    default:
      return 'images/7.png';
  }
}
