import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:weather_360/screens/activity_screen.dart';
import 'package:weather_360/screens/cloth_screen.dart';
import 'package:weather_360/screens/selectedcity_screen.dart';
import 'package:weather_360/screens/settings_screen.dart';
import 'package:weather_360/widgets/updatedialog.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/weather.dart';
import 'package:timezone/timezone.dart' as tz;

class WeatherPage extends StatefulWidget {
  String selectedCity;
  TemperatureUnit? temperatureUnit;
  WeatherPage({
    Key? key,
    required this.selectedCity,
    this.temperatureUnit = TemperatureUnit.celsius,
  }) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isMounted = false;
  WeatherFactory wf = WeatherFactory(
    dotenv.get('API_KEY', fallback: 'Could not connect to the api!'),
  );
  List<String> cities = [
    'London',
    'New York',
    'Paris',
    'Tokyo',
    'Istanbul',
    'Rome',
    'Dubai',
    'Krakow'
  ];
  String? selectedCity;

  List<Weather> fiveDayForecast = [];

  tz.TZDateTime _convertUtcToLocal(tz.TZDateTime utcDateTime) {
    return utcDateTime.toLocal();
  }

  @override
  @override
  void initState() {
    super.initState();
    _isMounted = true;

    WidgetsBinding.instance.addObserver(this);

    Future.delayed(const Duration(seconds: 2), () {
      if (_isMounted) {
        _loadTemperatureUnit();
        fetchFiveDayForecast();
        _loadNotificationStatus();
      }
    });
    AwesomeNotifications().resetGlobalBadge();
    final newVersion = NewVersionPlus(
      androidId: 'com.halaltek.weatherapp',
    );

    Timer(const Duration(milliseconds: 800), () {
      checkNewVersion(newVersion);
    });
  }

  Future<void> _loadNotificationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    setState(() {
      areNotificationsEnabled = notificationsEnabled;
    });
  }

  Future<void> _saveNotificationStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', status);
  }

  void checkNewVersion(NewVersionPlus newVersion) async {
    final status = await newVersion.getVersionStatus();
    if (status != null) {
      if (status.canUpdate) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return UpdateDialog(
              allowDismissal: true,
              description: status.releaseNotes ?? 'No release notes.',
              version: status.storeVersion,
              appLink: status.appStoreLink,
            );
          },
        );
      }
    }
  }

  Future<void> _loadTemperatureUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    TemperatureUnit? temperatureUnit =
        TemperatureUnit.values[prefs.getInt('temperatureUnit') ?? 0];
    setState(() {
      widget.temperatureUnit = temperatureUnit;
    });
  }

  void _handleTemperatureUnitChanged(TemperatureUnit newTemperatureUnit) {
    setState(() {
      widget.temperatureUnit = newTemperatureUnit;
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AwesomeNotifications().resetGlobalBadge();
    }
  }

  Future<void> fetchFiveDayForecast() async {
    List<Weather> forecast =
        await wf.fiveDayForecastByCityName(widget.selectedCity);

    setState(() {
      fiveDayForecast = forecast;
    });
  }

  String formatDateToDayName(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    }

    return DateFormat.E().format(date);
  }

  List<List<Weather>?> _groupByDay(List<Weather> data) {
    final groupedData = <String, List<Weather>>{};

    int tomorrowIndex = data.indexWhere((forecast) {
      final tomorrow = DateTime.now().add(Duration(days: 1));
      return forecast.date!.day == tomorrow.day &&
          forecast.date!.month == tomorrow.month &&
          forecast.date!.year == tomorrow.year;
    });

    final todayKey = 'Today';
    groupedData[todayKey] = [data.first];

    for (int i = tomorrowIndex + 1; i < data.length; i++) {
      final dateKey = formatDateToDayName(data[i].date!);

      if (!groupedData.containsKey(dateKey)) {
        groupedData[dateKey] = [];
      }

      groupedData[dateKey]!.add(data[i]);
    }

    return groupedData.values.toList();
  }

  String? getWeatherIconUrl(Weather weather) {
    if (weather.weatherIcon != null) {
      return 'http://openweathermap.org/img/w/${weather.weatherIcon}.png';
    }
    return null;
  }

  String formatNumber(double number) {
    return number.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
  }

  bool hasRain(Weather weather) {
    final weatherCondition = weather.weatherMain?.toLowerCase();
    return weatherCondition!.contains('rain');
  }

  bool hasCloud(Weather weather) {
    final weatherCondition = weather.weatherMain?.toLowerCase();
    return weatherCondition!.contains('cloud');
  }

  bool hasStorm(Weather weather) {
    final weatherCondition = weather.weatherMain?.toLowerCase();
    return weatherCondition!.contains('thunderstorm');
  }

  bool hasSnow(Weather weather) {
    final weatherCondition = weather.weatherMain?.toLowerCase();
    return weatherCondition!.contains('snow');
  }

  bool hasClear(Weather weather) {
    final weatherCondition = weather.weatherMain?.toLowerCase();
    return weatherCondition!.contains('clear');
  }

  bool hasSun(Weather weather) {
    final weatherCondition = weather.weatherMain?.toLowerCase();
    return weatherCondition!.contains('sunny');
  }

  String _getBackgroundImage(Weather weather) {
    if (hasRain(weather)) {
      return 'assets/rain.json';
    } else if (hasSun(weather)) {
      return 'assets/clear.json';
    } else if (hasCloud(weather)) {
      return 'assets/cloud.json';
    } else if (hasStorm(weather)) {
      return 'assets/storm.json';
    } else if (hasSnow(weather)) {
      return 'assets/snow.json';
    } else if (hasClear(weather)) {
      return 'assets/clear.json';
    }

    return 'assets/loading.png';
  }

  double convertTemperature(double temperature) {
    final unit = widget.temperatureUnit ?? TemperatureUnit.celsius;
    if (unit == TemperatureUnit.fahrenheit) {
      return (temperature * 9 / 5) + 32;
    } else {
      return temperature;
    }
  }

  bool areNotificationsEnabled = true;

  Future<void> _showTimePicker() async {
    if (areNotificationsEnabled) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        String localTimeZone =
            await AwesomeNotifications().getLocalTimeZoneIdentifier();

        await _saveNotificationStatus(false);
        int hour = selectedTime.hour;
        int minute = selectedTime.minute;

        DateTime now = DateTime.now();
        Weather currentForecast = fiveDayForecast.firstWhere(
          (forecast) =>
              forecast.date!.day == now.day &&
              forecast.date!.month == now.month &&
              forecast.date!.year == now.year,
          orElse: () => fiveDayForecast.first,
        );

        AwesomeNotifications().createNotification(
          content: NotificationContent(
            badge: 1,
            id: 1,
            channelKey: "weather_channel",
            title: "Weather 360",
            body:
                'Today the weather will be ${currentForecast.weatherDescription.toString()} with a temperature of ${convertTemperature(currentForecast.temperature!.celsius!).toStringAsFixed(2)}°${widget.temperatureUnit == TemperatureUnit.fahrenheit ? 'F' : 'C'} in ${widget.selectedCity}, open the app for the full report.',
          ),
          schedule: NotificationCalendar(
            timeZone: localTimeZone,
            hour: hour,
            minute: minute,
            allowWhileIdle: true,
            repeats: true,
          ),
        );
      }
    } else {
      AwesomeNotifications().cancelAllSchedules();

      await _saveNotificationStatus(true);
    }

    setState(() {
      areNotificationsEnabled = !areNotificationsEnabled;
    });
  }

  Future<void> _showUnsubscribeConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unsubscribe from Notifications?'),
          content:
              Text('Are you sure you want to unsubscribe from notifications?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                AwesomeNotifications().cancelAllSchedules();

                await _saveNotificationStatus(true);

                setState(() {
                  areNotificationsEnabled = true;
                });

                Navigator.of(context).pop();
              },
              child: Text(
                'Unsubscribe',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareWeatherConditions() async {
    if (fiveDayForecast.isNotEmpty) {
      final Weather currentWeather = fiveDayForecast[0];

      final String appLink =
          'Android:\n https://play.google.com/store/apps/details?id=com.halaltek.weatherapp\n IOS: Comming soon!!';

      final String message = 'Weather in ${widget.selectedCity}:\n'
          '${currentWeather.weatherDescription}\n'
          'Temperature: ${convertTemperature(currentWeather.temperature!.celsius!).toStringAsFixed(2)}°${widget.temperatureUnit == TemperatureUnit.fahrenheit ? 'F' : 'C'}\n'
          'Humidity: ${formatNumber(currentWeather.humidity!.toDouble())}%\n'
          'Wind: ${formatNumber(currentWeather.windSpeed! * 3.6)} km/h\n\n'
          'Did you know? Our app provides personalized weather recommendations! 🌦️\n'
          'Discover what to wear, what activities to plan, and more! Install now.\n'
          'App Link: $appLink';

      await Share.share(message);
    } else {
      final snackBar = SnackBar(
        content: Text('Weather data is not available.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;

    return Builder(
      builder: (context) => Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async {
                await _shareWeatherConditions();
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () async {
                  _scaffoldKey.currentState!.openDrawer();
                },
              ),
            ),
          ],
          title: Row(
            children: [
              InkWell(
                child: Row(
                  children: [
                    Image.asset('assets/location.png', height: 35),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Text(widget.selectedCity.toString()),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        body: SizedBox.expand(
          child: Stack(
            children: [
              if (fiveDayForecast.isNotEmpty)
                Container(
                  child: Lottie.asset(
                    _getBackgroundImage(fiveDayForecast[0]),
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(top: deviceHeight * 0.13),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (fiveDayForecast.isNotEmpty)
                              Column(
                                children: [
                                  const Text(
                                    'Today',
                                    style: TextStyle(
                                        fontSize: 35, color: Colors.white),
                                  ),
                                  SizedBox(
                                    height: deviceHeight * 0.12,
                                  ),
                                  Center(
                                    child: Image.network(
                                      getWeatherIconUrl(fiveDayForecast[0])
                                          .toString(),
                                      height: 130,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Text(
                                    fiveDayForecast[0]
                                        .weatherDescription
                                        .toString(),
                                    style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    '${convertTemperature(fiveDayForecast[0].temperature!.celsius!).toStringAsFixed(2)}°${widget.temperatureUnit == TemperatureUnit.fahrenheit ? 'F' : 'C'}',
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    height: deviceHeight * 0.116,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          const Icon(
                                            Icons.water_drop_outlined,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: Text(
                                              'Humidity \n${formatNumber(fiveDayForecast[0].humidity!.toDouble())}%',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Icon(
                                            CupertinoIcons.wind,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            'Wind Power \n${formatNumber(fiveDayForecast[0].windSpeed! * 3.6)} km/h',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Lottie.asset(
                                            'assets/therm.json',
                                            repeat: true,
                                            height: 40,
                                            width: 40,
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            'Feels Like',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            '${convertTemperature(fiveDayForecast[0].tempFeelsLike!.celsius!).toStringAsFixed(2)}°${widget.temperatureUnit == TemperatureUnit.fahrenheit ? 'F' : 'C'}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      bottom: 20,
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: Colors.black.withOpacity(0.4),
                                      ),
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 15,
                                        bottom: 15,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: _groupByDay(fiveDayForecast)
                                            .skip(1)
                                            .map((dayForecast) {
                                          Weather firstForecast =
                                              dayForecast![0];
                                          return Column(
                                            children: [
                                              Text(
                                                formatDateToDayName(
                                                    firstForecast.date!),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Image.network(
                                                getWeatherIconUrl(firstForecast)
                                                    .toString(),
                                                height: 44,
                                                width: 44,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${convertTemperature(firstForecast.temperature!.celsius!).toStringAsFixed(2)}°${widget.temperatureUnit == TemperatureUnit.fahrenheit ? 'F' : 'C'}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${formatNumber(firstForecast.windSpeed! * 3.6)}\n km/h',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (fiveDayForecast.isEmpty)
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Lottie.asset('assets/loader.json'),
                                    const Text('Loading...'),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                child: Column(
                  children: [
                    Image.asset('assets/icon.png', height: 80),
                    const SizedBox(height: 10),
                    const Text('Weather 360'),
                    SizedBox(height: 3),
                    Text(
                      'Version: 5.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Saved Locations'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CitySelectionScreen(selectedCities: cities),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.wb_sunny),
                title: const Text('What to Wear'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClothScreen(
                        weatherCondition: fiveDayForecast.isNotEmpty
                            ? fiveDayForecast[0].weatherDescription ?? ''
                            : 'Unknown',
                        temperature: fiveDayForecast.isNotEmpty
                            ? fiveDayForecast[0].temperature?.celsius ?? 0.0
                            : 0.0,
                      ),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.run_circle),
                title: const Text('What to Do'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivityScreen(
                        weatherCondition: fiveDayForecast.isNotEmpty
                            ? fiveDayForecast[0].weatherDescription ?? ''
                            : 'Unknown',
                        temperature: fiveDayForecast.isNotEmpty
                            ? fiveDayForecast[0].temperature?.celsius ?? 0.0
                            : 0.0,
                      ),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(areNotificationsEnabled
                    ? Icons.notification_add
                    : Icons.notifications_off),
                title: Text(areNotificationsEnabled
                    ? 'Notifications'
                    : 'Unsubscribe notifications'),
                onTap: () async {
                  if (areNotificationsEnabled) {
                    await _showTimePicker();
                  } else {
                    await _showUnsubscribeConfirmationDialog();
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Settings(
                        onTemperatureUnitChanged: _handleTemperatureUnitChanged,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
