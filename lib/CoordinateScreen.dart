import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/secrets.dart';
import 'package:weatherapp/weatherscreen2.dart';

class CoordinateScreen extends StatefulWidget {
  final String cityName;

  const CoordinateScreen({Key? key, required this.cityName}) : super(key: key);

  @override
  _CoordinateScreenState createState() => _CoordinateScreenState();
}

class _CoordinateScreenState extends State<CoordinateScreen> {
  late Future<Map<String, dynamic>> _futureData;
  final TextEditingController latController = TextEditingController();
  final TextEditingController lonController = TextEditingController();
  late String cityName;
  double? latitude;
  double? longitude;
  late Timer _timer;
  String currentTime = DateFormat.jm().format(DateTime.now());

  @override
  void initState() {
    super.initState();
    cityName = widget.cityName;
    _futureData = fetchData(cityName);
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

  Future<Map<String, dynamic>> fetchData(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$openWeatherMapApiKey&units=metric'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw e.toString();
    }
  }

  void updateLatLon() {
    setState(() {
      latitude = double.tryParse(latController.text);
      longitude = double.tryParse(lonController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          backgroundColor: Colors.blueGrey.shade800,
          title: const Text(
            "Stormy App",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'GreatVibes',
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: _futureData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('${snapshot.error}'));
                        }

                        final weatherData = snapshot.data!;
                        latitude ??= weatherData['coord']['lat'];
                        longitude ??= weatherData['coord']['lon'];

                        latController.text = latitude.toString();
                        lonController.text = longitude.toString();

                        return Card(
                          elevation: 6,
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: ClipRRect(
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cityName,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontFamily: 'LXGWWenKai',
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: latController,
                                            decoration: InputDecoration(
                                              hintText: 'Latitude',
                                              hintStyle: TextStyle(
                                                  color: Colors.white70),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
                                                borderSide: BorderSide.none,
                                              ),
                                              filled: true,
                                              fillColor:
                                                  Colors.black.withOpacity(0.3),
                                            ),
                                            style:
                                                TextStyle(color: Colors.white),
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: TextField(
                                            controller: lonController,
                                            decoration: InputDecoration(
                                              hintText: 'Longitude',
                                              hintStyle: TextStyle(
                                                  color: Colors.white70),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
                                                borderSide: BorderSide.none,
                                              ),
                                              filled: true,
                                              fillColor:
                                                  Colors.black.withOpacity(0.3),
                                            ),
                                            style:
                                                TextStyle(color: Colors.white),
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: updateLatLon,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                      ),
                                      child: Text('Update Coordinates'),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Lat: ${latitude!.toStringAsFixed(2)}, Lon: ${longitude!.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                Weatherscreen2(
                                              latitude: latitude!,
                                              longitude: longitude!,
                                              cityName: '',
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                      ),
                                      child: Text('Check Weather'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                color: Colors.blueGrey.shade800,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Developed by @Bibhushan , @Mouna , @Batool @Shakhboz @Juan @Pouya',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
