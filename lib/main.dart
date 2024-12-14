import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      home: WeatherTabs(),
    );
  }
}

class WeatherTabs extends StatelessWidget {
  final List<String> cities = ["Київ", "Львів", "Одеса", "Харків"];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: cities.length + 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Weather App', style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            tabs: [
              ...cities.map((city) => Tab(text: city)),
              Tab(text: 'Пошук'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ...cities.map((city) => WeatherScreen(city: city)),
            SearchScreen(),
          ],
        ),
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  final String city;

  WeatherScreen({required this.city});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String temperature = "";
  String condition = "";
  String iconUrl = "";
  bool isLoading = true;

  final Map<String, String> weatherDescriptions = {
    "clear sky": "чисте небо",
    "few clouds": "мало хмар",
    "scattered clouds": "розсіяні хмари",
    "broken clouds": "хмарно з проясненнями",
    "overcast clouds": "похмуро",
    "shower rain": "зливовий дощ",
    "rain": "дощ",
    "thunderstorm": "гроза",
    "snow": "сніг",
    "light snow": "невеликий сніг",
    "mist": "туман",
  };

  @override
  void initState() {
    super.initState();
    fetchWeather(widget.city);
  }

  Future<void> fetchWeather(String city) async {
    final response = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=c2dd06cba2dc02b8bbfa71e579b3de5d&units=metric'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        temperature = "${data['main']['temp']}°C";
        condition = weatherDescriptions[data['weather'][0]['description']] ??
            data['weather'][0]['description'];
        iconUrl = "http://openweathermap.org/img/wn/${data['weather'][0]['icon']}@2x.png";
        isLoading = false;
      });
    } else {
      setState(() {
        temperature = "Не вдалося отримати погоду";
        condition = "";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade300, Colors.blue.shade900],
        ),
      ),
      child: Center(
        child: isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (iconUrl.isNotEmpty)
                    Image.network(iconUrl, width: 100, height: 100),
                  SizedBox(height: 20),
                  Text(
                    temperature,
                    style: GoogleFonts.roboto(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    condition,
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String city = "";
  String temperature = "";
  String condition = "";
  String iconUrl = "";
  bool isLoading = false;

  final Map<String, String> weatherDescriptions = {
    "clear sky": "чисте небо",
    "few clouds": "мало хмар",
    "scattered clouds": "розсіяні хмари",
    "broken clouds": "хмарно з проясненнями",
    "overcast clouds": "похмуро",
    "shower rain": "зливовий дощ",
    "rain": "дощ",
    "thunderstorm": "гроза",
    "snow": "сніг",
    "light snow": "невеликий сніг",
    "mist": "туман",
  };

  Future<void> fetchWeather(String city) async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=c2dd06cba2dc02b8bbfa71e579b3de5d&units=metric'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        temperature = "${data['main']['temp']}°C";
        condition = weatherDescriptions[data['weather'][0]['description']] ??
            data['weather'][0]['description'];
        iconUrl = "http://openweathermap.org/img/wn/${data['weather'][0]['icon']}@2x.png";
        isLoading = false;
      });
    } else {
      setState(() {
        temperature = "Не вдалося отримати погоду";
        condition = "";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade300, Colors.blue.shade900],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Введіть місто',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                fetchWeather(_controller.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
              ),
              child: Text('Показати погоду'),
            ),
            SizedBox(height: 20),
            if (isLoading)
              CircularProgressIndicator(color: Colors.white)
            else
              Column(
                children: [
                  if (iconUrl.isNotEmpty)
                    Image.network(iconUrl, width: 100, height: 100),
                  SizedBox(height: 20),
                  Text(
                    temperature,
                    style: GoogleFonts.roboto(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    condition,
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}