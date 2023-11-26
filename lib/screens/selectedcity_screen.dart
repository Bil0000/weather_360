import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_360/screens/search_screen.dart';
import 'package:weather_360/screens/weather_screen.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather/weather.dart';
import 'package:http/http.dart' as http;

class CitySelectionScreen extends StatefulWidget {
  const CitySelectionScreen({Key? key, required List<String> selectedCities})
      : super(key: key);

  @override
  _CitySelectionScreenState createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  WeatherFactory wf = WeatherFactory(
    dotenv.get('API_KEY', fallback: 'Could not connect to the api!'),
  );
  int maxCities = 10000;

  List<String> selectedCities = [];
  Map<String, Weather?> cityWeatherMap = {};

  void removeCity(String cityToRemove) {
    setState(() {
      if (selectedCity == cityToRemove) {
        if (selectedCities.length == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You need to have at least 1 city selected.',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (selectedCities.isNotEmpty) {
          final random = Random();
          selectedCity = selectedCities[random.nextInt(selectedCities.length)];
          setLastSelectedCity(selectedCity!);

          fetchWeatherForCity(selectedCity!);
          fetchFiveDayForecast();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Now $selectedCity is selected as a random city from your saved cities because you deleted the last selected city.',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              backgroundColor: Colors.blue,
            ),
          );
        } else {
          selectedCity = null;
        }
      }

      selectedCities.remove(cityToRemove);
      saveSelectedCities(selectedCities);
    });
  }

  void saveSelectedCities(List<String> cities) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('selectedCities', cities);
  }

  Future<List<String>> getSelectedCities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('selectedCities') ?? [];
  }

  String? selectedCity;

  Weather? currentWeather;

  List<Weather> fiveDayForecast = [];

  @override
  void initState() {
    super.initState();
    getSelectedCities().then((cities) async {
      setState(() {
        selectedCities = cities;
      });

      if (selectedCities.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        selectedCity = prefs.getString('lastSelectedCity') ?? selectedCities[0];

        for (var city in selectedCities) {
          fetchWeatherForCity(city);
        }

        if (selectedCity != null) {
          fetchFiveDayForecast();
        }
      } else {
        selectedCity = null;
      }

      if (selectedCities.isEmpty) {
        final cityName = await fetchCityNameFromURL();

        if (cityName != null) {
          setState(() {
            selectedCities.add(cityName);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '$cityName is Your current location.',
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                ),
                backgroundColor: Colors.blue,
              ),
            );
          });

          saveSelectedCities(selectedCities);

          fetchWeatherForCity(cityName);
        }
      }
    });
  }

  Future<String?> fetchCityNameFromURL() async {
    try {
      final response =
          await http.get(Uri.parse('https://bilal.bakkr.com/geo.php'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final String? cityName = data['city'];

        return cityName;
      } else {
        print('Failed to fetch city name. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching city name: $e');
      return null;
    }
  }

  Future<void> fetchWeatherForCity(String? city) async {
    if (city != null && city.isNotEmpty) {
      try {
        Weather weather = await wf.currentWeatherByCityName(city);

        setState(() {
          cityWeatherMap[city] = weather;
        });
      } catch (e) {
        print("Error fetching weather for $city: $e");
      }
    }
  }

  Future<void> fetchFiveDayForecast() async {
    if (selectedCity != null) {
      try {
        List<Weather> forecast =
            await wf.fiveDayForecastByCityName(selectedCity!);

        setState(() {
          fiveDayForecast = forecast;
        });
      } catch (e) {
        print("Error fetching forecast for $selectedCity: $e");
      }
    }
  }

  String? getWeatherIconUrl(Weather weather) {
    if (weather.weatherIcon != null) {
      return 'http://openweathermap.org/img/w/${weather.weatherIcon}.png';
    }
    return null;
  }

  void setLastSelectedCity(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastSelectedCity', city);
  }

  void reorderCity(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final city = selectedCities.removeAt(oldIndex);
      selectedCities.insert(newIndex, city);
      saveSelectedCities(selectedCities);
    });
  }

  Future<bool?> showConfirmDismissDialog(
      BuildContext context, String city) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to remove $city?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                removeCity(city);
              },
              child: Text(
                'Confirm',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateAllCities() async {
    for (var city in selectedCities) {
      await fetchWeatherForCity(city);
      await fetchFiveDayForecastForCity(city);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Refreshed all weather data for all cities'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> fetchFiveDayForecastForCity(String city) async {
    try {
      List<Weather> forecast = await wf.fiveDayForecastByCityName(city);

      setState(() {
        cityWeatherMap[city] = forecast.isNotEmpty ? forecast.first : null;
      });
    } catch (e) {
      print("Error fetching forecast for $city: $e");
    }
  }

  Future<void> _handleRefresh() async {
    await updateAllCities();
  }

  Color getBackgroundColor(String? city) {
    if (city != null && cityWeatherMap[city] != null) {
      double temperature = cityWeatherMap[city]!.temperature!.celsius ?? 0.0;
      final double minTemperature = -40;
      final double maxTemperature = 30;
      final double mappedValue =
          (temperature - minTemperature) / (maxTemperature - minTemperature);
      final int redComponent = (255 * mappedValue).toInt();
      final int blueComponent = (255 * (1 - mappedValue)).toInt();

      return Color.fromRGBO(redComponent, 0, blueComponent, 1);
    }
    return Color.fromRGBO(57, 26, 73, 1);
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text('Saved Locations'),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 25),
            child: Icon(Icons.search),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              getBackgroundColor(selectedCity),
              Color.fromRGBO(57, 26, 73, 1),
              Color.fromRGBO(48, 29, 92, 1),
              Color.fromRGBO(38, 33, 113, 1),
              Color.fromRGBO(48, 29, 92, 1),
              Color.fromRGBO(57, 26, 73, 1),
              getBackgroundColor(selectedCity),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: deviceHeight * 0.14),
          child: Column(
            children: [
              if (selectedCities.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: deviceHeight * 0.15),
                  child: const Text(
                    'Please select a city.',
                    style: TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                ),
              Expanded(
                child: LiquidPullToRefresh(
                  color: Color.fromRGBO(57, 26, 73, 1),
                  backgroundColor: Colors.deepPurple[200],
                  height: 200,
                  onRefresh: _handleRefresh,
                  child: ReorderableListView.builder(
                    itemCount: selectedCities.isNotEmpty
                        ? selectedCities.length + 1
                        : 1,
                    itemBuilder: (context, index) {
                      if (index == selectedCities.length) {
                        return Dismissible(
                          key: ValueKey("add_new"),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 15, bottom: 50),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                          170, 165, 165, 0.7),
                                      borderRadius: BorderRadius.circular(30)),
                                  child: ListTile(
                                    title: const Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_circle_outline,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            'Add New',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () async {
                                      if (selectedCities.length < maxCities) {
                                        final selectedCity = await showSearch(
                                          context: context,
                                          delegate: CitySearchDelegate(),
                                        );
                                        if (selectedCity != null) {
                                          setState(() {
                                            if (!selectedCities
                                                .contains(selectedCity)) {
                                              saveSelectedCities(
                                                  selectedCities);
                                              selectedCities.add(selectedCity);
                                              fetchWeatherForCity(selectedCity);
                                              fetchFiveDayForecast();

                                              setLastSelectedCity(selectedCity);

                                              fetchFiveDayForecast();
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '$selectedCity is already in the list.',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 17),
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          });
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'You have reached the maximum limit of $maxCities cities. Remove one or choose a different city.',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: TextButton(
                                  onPressed: () {
                                    launchUrl(
                                      Uri.parse(
                                        'https://docs.google.com/document/d/1b0KkCUpEP7qoyiw0bf-AJKPJ-Dkb9PeomYUEUwk4VyY/edit?usp=sharing',
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 15, bottom: 15),
                                    child: Text(
                                      'Privacy Policy',
                                      style: TextStyle(
                                        color: Colors.blue[300],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onDismissed: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              await showConfirmDismissDialog(
                                  context, "Add New");
                            }
                          },
                          background: Container(),
                        );
                      } else {
                        final city = selectedCities[index];
                        return Dismissible(
                          key: Key(city),
                          child: GestureDetector(
                            onTap: () {
                              fetchWeatherForCity(city);
                              setLastSelectedCity(city);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WeatherPage(
                                    selectedCity: city,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                key: Key(city),
                                width: double.infinity,
                                padding: const EdgeInsets.all(18.0),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromRGBO(170, 165, 165, 0.7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          city,
                                          style: const TextStyle(
                                              fontSize: 25.0,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        if (cityWeatherMap[city] != null)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  cityWeatherMap[city]!
                                                      .weatherDescription
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                                const SizedBox(height: 25),
                                                Text(
                                                  'Humidity ${cityWeatherMap[city]!.humidity!.toStringAsFixed(0)}%',
                                                  style: const TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  'Wind ${(cityWeatherMap[city]!.windSpeed! * 3.6).toStringAsFixed(0)} km/h',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (cityWeatherMap[city] != null)
                                      Column(
                                        children: [
                                          Image.network(
                                            getWeatherIconUrl(
                                                    cityWeatherMap[city]!) ??
                                                '',
                                            scale: 0.8,
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            '${cityWeatherMap[city]!.temperature!.celsius!.toStringAsFixed(0)}°C',
                                            style: const TextStyle(
                                              fontSize: 40.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              removeCity(city);
                            }
                          },
                          background: Container(
                            color: Colors.red,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (selectedCities.length > 1) {
                              return await showConfirmDismissDialog(
                                  context, city);
                            } else {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'You need to have at least 1 city selected.',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return false;
                            }
                          },
                        );
                      }
                    },
                    onReorder: (int oldIndex, int newIndex) {
                      reorderCity(oldIndex, newIndex);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
