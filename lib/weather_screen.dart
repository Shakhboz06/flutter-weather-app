import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weatherapp/CoordinateScreen.dart';
import 'package:weatherapp/additional_info_item.dart';
import 'package:weatherapp/countrycode.dart';
import 'package:weatherapp/hourly_forcast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/secrets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late String searchCity = '';
  late Future<List<Map<String, dynamic>>> _futureData;

  final TextEditingController textEditingController = TextEditingController();
  late Timer _timer;
  String currentTime = DateFormat.jm().format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _futureData = fetchData();
    _timer = Timer.periodic(Duration(minutes: 1), (Timer t) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      currentTime = DateFormat.jm().format(DateTime.now());
    });
  }

  void search() {
    String searchCity = textEditingController.text;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoordinateScreen(cityName: searchCity),
      ),
    );
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    String location;
    Position? position;

    PermissionStatus permission = await Permission.locationWhenInUse.request();

    if (permission.isGranted) {
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        throw Exception('Failed to get location: $e');
      }
    } else {
      throw Exception('Location permission denied');
    }

    if (position == null) {
      throw Exception('Failed to get position');
    }

    location = 'Lat: ${position.latitude} , Long: ${position.longitude}';
    String lat = position.latitude.toString();
    String lon = position.longitude.toString();

    try {
      final result = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=minutely&appid=$openWeatherMapApiKey&units=metric'),
      );
      final data = jsonDecode(result.body);
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getCityLocation() async {
    String location;
    Position? position;

    PermissionStatus permission = await Permission.locationWhenInUse.request();

    if (permission.isGranted) {
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        throw Exception('Failed to get location: $e');
      }
    } else {
      throw Exception('Location permission denied');
    }

    if (position == null) {
      throw Exception('Failed to get position');
    }

    location = 'Lat: ${position.latitude} , Long: ${position.longitude}';
    String lat = position.latitude.toString();
    String lon = position.longitude.toString();

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&exclude=minutely&appid=$openWeatherMapApiKey&units=metric'),
      );
      if (response.statusCode == 200) {
        final data2 = jsonDecode(response.body);
        return data2;
      } else {
        throw Exception('Failed to load other API data');
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    final weatherData = getCurrentWeather();
    final otherData = getCityLocation();
    return await Future.wait([weatherData, otherData]);
  }

  void _refreshData() {
    setState(() {
      _futureData = fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Center(
        child: Scaffold(
          // resizeToAvoidBottomInset: true,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.blueGrey.shade800,
            elevation: 0,
            title: const Text(
              "Stormy App",
              style: TextStyle(
                fontFamily: 'GreatVibes',
                fontSize: 30,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blueGrey.shade800, Colors.black87],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child:
                                      FutureBuilder<List<Map<String, dynamic>>>(
                                    future: _futureData,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ));
                                      }
                                      if (snapshot.hasError) {
                                        return Center(
                                            child: Text('${snapshot.error}'));
                                      }

                                      final weatherData = snapshot.data![0];
                                      final locationData = snapshot.data![1];

                                      final areaName = locationData['name'];
                                      final countryCode =
                                          locationData['sys']['country'];
                                      final countryName =
                                          countryNames[countryCode] ??
                                              countryCode;
                                      final currentTemp = weatherData['current']
                                              ['temp']
                                          .round();
                                      final currentSky = weatherData['current']
                                          ['weather'][0]['main'];
                                      final humidity =
                                          weatherData['hourly'][0]['humidity'];
                                      final windSpeed = weatherData['hourly'][0]
                                              ['wind_speed']
                                          .toString();

                                      return Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                currentTime,
                                                style: const TextStyle(
                                                  fontSize: 24.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange,
                                                ),
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
                                                margin:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 10, 0, 0),
                                                color: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  child: BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                        sigmaX: 10.0,
                                                        sigmaY: 10.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Colors.blue
                                                                .withOpacity(
                                                                    0.4),
                                                            Colors.purple
                                                                .withOpacity(
                                                                    0.4)
                                                          ],
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.0),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color:
                                                                Colors.black26,
                                                            blurRadius: 10,
                                                            offset:
                                                                const Offset(
                                                                    0, 5),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              '$currentTemp °C',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 28.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .orange,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Image.asset(
                                                              getImageForWeather(
                                                                weatherData['current']
                                                                        [
                                                                        'weather']
                                                                    [0]['icon'],
                                                              ),
                                                              scale: 7.0,
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Text(
                                                              currentSky,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 20,
                                                                fontFamily:
                                                                    'LXGWWenKai',
                                                                color: Colors
                                                                    .white,
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
                                            const SizedBox(
                                              height: 10,
                                            ),
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
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: [
                                                  for (int i = 0; i < 20; i++)
                                                    hourly_forcast_item(
                                                        time: getFormattedTime(
                                                            weatherData['hourly']
                                                                [i + 1]['dt']),
                                                        temp:
                                                            weatherData['hourly']
                                                                    [i]['temp']
                                                                .round()
                                                                .toString(),
                                                        image: getImageForWeather(
                                                            weatherData['hourly']
                                                                        [i]
                                                                    ['weather']
                                                                [0]['icon'])),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                additional_info_item(
                                                  icon: (Icons.water_drop),
                                                  text: 'Humidity',
                                                  value: humidity.toString(),
                                                ),
                                                additional_info_item(
                                                  icon: Icons.wind_power,
                                                  text: 'Wind Speed',
                                                  value: windSpeed + 'km/h',
                                                ),
                                                const additional_info_item(
                                                  icon:
                                                      Icons.light_mode_outlined,
                                                  text: 'UV Index',
                                                  value: 'low',
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                additional_info(
                                                  image: 'images/11.png',
                                                  value: getSunFormattedTime(
                                                          weatherData['current']
                                                              ['sunrise'])
                                                      .toString(),
                                                  text: 'SunRise',
                                                ),
                                                additional_info(
                                                  image: 'images/12.png',
                                                  value: getSunFormattedTime(
                                                          weatherData['current']
                                                              ['sunset'])
                                                      .toString(),
                                                  text: 'SunSet',
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                            ElevatedButton(
                                              onPressed: _launchURL,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                            const SizedBox(height: 20),
                                            ElevatedButton(
                                              onPressed: _launchURL2,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 15.0,
                                                  horizontal: 20.0,
                                                ),
                                                elevation: 3,
                                              ),
                                              child: const Text(
                                                '',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _refreshData,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.refresh),
          ),
        ),
      ),
    );
  }
}

String getFormattedTime(int timestamp) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return DateFormat('MMMM-dd \n HH:00').format(dateTime);
}

String getSunFormattedTime(int timestamp) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return DateFormat('HH:mm').format(dateTime);
}

final Uri _url =
    Uri.parse('https://weather-app-experimental.vercel.app/index.html');

_launchURL() async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}

_launchURL2() async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}
