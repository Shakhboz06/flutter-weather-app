import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weatherapp/additional_info_item.dart';
import 'package:weatherapp/countrycode.dart';
import 'package:weatherapp/hourly_forcast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/secrets.dart';
import 'package:url_launcher/url_launcher.dart';

class Weatherscreen2 extends StatefulWidget {
  final String cityName;
  final double latitude;
  final double longitude;

  const Weatherscreen2({
    Key? key,
    required this.cityName,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<Weatherscreen2> createState() => _Weatherscreen2State();
}

class _Weatherscreen2State extends State<Weatherscreen2> {
  late Future<List<Map<String, dynamic>>> _futureData;
  final TextEditingController textEditingController = TextEditingController();

  void search() async {
    try {
      final coordinates = await getCityCoordinates(textEditingController.text);
      setState(() {
        _futureData = fetchData(coordinates['cityName'],
            coordinates['latitude'], coordinates['longitude']);
      });
    } catch (e) {
      print('Error fetching city coordinates: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _futureData = fetchData(widget.cityName, widget.latitude, widget.longitude);
  }

  Future<Map<String, dynamic>> getCurrentWeather(
      double latitude, double longitude) async {
    try {
      final result = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/3.0/onecall?lat=$latitude&lon=$longitude&exclude=minutely&appid=$openWeatherMapApiKey&units=metric'),
      );
      final data = jsonDecode(result.body);
      return data;
    } catch (e) {
      throw Exception('Error fetching current weather: $e');
    }
  }

  Future<Map<String, dynamic>> getCityLocation(
      double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$openWeatherMapApiKey&units=metric'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to load city data');
      }
    } catch (e) {
      throw Exception('Error fetching city location: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchData(
      String cityName, double latitude, double longitude) async {
    final weatherData = getCurrentWeather(latitude, longitude);
    final otherData = getCityLocation(latitude, longitude);
    return await Future.wait([weatherData, otherData]);
  }

  Future<Map<String, dynamic>> getCityCoordinates(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=1&appid=$openWeatherMapApiKey'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return {
            'cityName': data[0]['name'],
            'latitude': data[0]['lat'],
            'longitude': data[0]['lon'],
          };
        } else {
          throw Exception('City not found');
        }
      } else {
        throw Exception('Failed to load city coordinates');
      }
    } catch (e) {
      throw Exception('Error fetching city coordinates: $e');
    }
  }

  void _refreshData() {
    setState(() {
      _futureData =
          fetchData(widget.cityName, widget.latitude, widget.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(
            "Stormy App",
            style: TextStyle(
                fontFamily: 'GreatVibes', fontSize: 30, color: Colors.white),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey.shade800, Colors.black87],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                child: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    hintText: 'City, country',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                    prefixIcon: const Icon(Icons.location_city),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        textEditingController.clear();
                      },
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: search,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 20.0,
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _futureData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('${snapshot.error}'));
                    }

                    final weatherData = snapshot.data![0];
                    final locationData = snapshot.data![1];

                    final areaName = locationData['name'];
                    final countryCode = locationData['sys']['country'];
                    final countryName =
                        countryNames[countryCode] ?? countryCode;
                    final currentTemp = weatherData['current']['temp'].round();
                    final currentSky =
                        weatherData['current']['weather'][0]['main'];
                    final humidity = weatherData['hourly'][0]['humidity'];
                    final windSpeed =
                        weatherData['hourly'][0]['wind_speed'].toString();

                    final currentcitytime = weatherData['current']['dt'];

                    // Extract timezone offset
                    final timezoneOffset = weatherData['timezone_offset'];

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                getcurrentFormattedTime(
                                    currentcitytime - 7200 + timezoneOffset),
                                style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '$areaName, $countryName',
                                style: const TextStyle(
                                  fontSize: 28.0,
                                  fontFamily: 'LXGWWenKai',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 200.0,
                              height: 220.0,
                              child: Card(
                                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.0),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 10.0, sigmaY: 10.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.withOpacity(0.4),
                                            Colors.purple.withOpacity(0.4)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$currentTemp °C',
                                              style: const TextStyle(
                                                fontSize: 28.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Image.asset(
                                              getImageForWeather(
                                                weatherData['current']
                                                    ['weather'][0]['icon'],
                                              ),
                                              scale: 7.0,
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              currentSky,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontFamily: 'LXGWWenKai',
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Hourly Forecast',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: 'LXGWWenKai',
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(
                                  20,
                                  (index) => hourly_forcast_item(
                                    time: getFormattedTime(
                                      weatherData['hourly'][index + 1]['dt'] -
                                          7200 +
                                          timezoneOffset,
                                    ),
                                    temp: weatherData['hourly'][index]['temp']
                                        .round()
                                        .toString(),
                                    image: getImageForWeather(
                                      weatherData['hourly'][index]['weather'][0]
                                          ['icon'],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Additional Information',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: 'LXGWWenKai',
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                additional_info_item(
                                  icon: Icons.water_drop,
                                  text: 'Humidity',
                                  value: humidity.toString(),
                                ),
                                additional_info_item(
                                  icon: Icons.wind_power,
                                  text: 'Wind Speed',
                                  value: '$windSpeed km/h',
                                ),
                                additional_info_item(
                                  icon: Icons.light_mode_outlined,
                                  text: 'UV Index',
                                  value: 'low',
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                additional_info(
                                  image: 'images/11.png',
                                  value: getSunFormattedTime(
                                          weatherData['current']['sunrise'])
                                      .toString(),
                                  text: 'SunRise',
                                ),
                                additional_info(
                                  image: 'images/12.png',
                                  value: getSunFormattedTime(
                                          weatherData['current']['sunset'])
                                      .toString(),
                                  text: 'SunSet',
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => _launchURL(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15.0,
                                  horizontal: 20.0,
                                ),
                                elevation: 3,
                              ),
                              child: const Text(
                                'More Details',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _refreshData,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}

final Uri _url =
    Uri.parse('https://weather-app-experimental.vercel.app/index.html');

_launchURL() async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}

//   void _launchUrl() async {
//   if (!await launchUrl(_url)) {
//     throw Exception('Could not launch $_url');
//   }
// }

String getFormattedTime(int timestamp) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return DateFormat('MMMM-dd HH:00').format(dateTime);
}

String getcurrentFormattedTime(int timestamp) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return DateFormat('HH:mm').format(dateTime);
}

String getSunFormattedTime(int timestamp) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return DateFormat('HH:mm').format(dateTime);
}



// void main() {
//   runApp(const MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: Weatherscreen2(
//       cityName: 'London', // Replace with your default city
//       latitude: 51.5074, // Replace with your default latitude
//       longitude: -0.1278, // Replace with your default longitude
//     ),
//   ));
// }
