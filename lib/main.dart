import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_360/controllers/notification_controller.dart';
import 'package:weather_360/intro/onboarding_screen.dart';
import 'package:weather_360/screens/selectedcity_screen.dart';
import 'package:weather_360/screens/weather_screen.dart';
import 'package:weather_360/utils/preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await initializePreferences();

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('UTC'));

  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelGroupKey: "weather_channel_group",
      channelKey: "weather_channel",
      channelName: "Weather Notification",
      channelDescription: "Weather Notifications channel",
      importance: NotificationImportance.Max,
    )
  ], channelGroups: [
    NotificationChannelGroup(
      channelGroupKey: "weather_channel_group",
      channelGroupName: "Weather Group",
    )
  ]);
  bool isAllowedToSendNotification =
      await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowedToSendNotification) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  bool hasInternet = await checkInternetConnectivity();
  String? lastSelectedCity = await getLastSelectedCity();
  bool isFirstTime = await getIsFirstTime();

  runApp(MyApp(
    lastSelectedCity: lastSelectedCity,
    hasInternet: hasInternet,
    isFirstTime: isFirstTime,
  ));
}

Future<bool> checkInternetConnectivity() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

class MyApp extends StatefulWidget {
  final bool hasInternet;
  final String? lastSelectedCity;
  final bool isFirstTime;

  const MyApp({
    Key? key,
    this.lastSelectedCity,
    required this.hasInternet,
    required this.isFirstTime,
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      title: 'Weather 360',
      home: AnimatedSplashScreen(
        duration: 4000,
        splashTransition: SplashTransition.fadeTransition,
        animationDuration: const Duration(seconds: 2),
        splashIconSize: 800,
        centered: true,
        splash: Center(
          child: Lottie.asset('assets/splash.json'),
        ),
        nextScreen: widget.isFirstTime
            ? OnBoardingScreen(selectedCities: [])
            : (widget.hasInternet
                ? (widget.lastSelectedCity != null
                    ? WeatherPage(
                        selectedCity: widget.lastSelectedCity.toString())
                    : CitySelectionScreen(selectedCities: []))
                : NoInternetScreen()),
      ),
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/no_connection1.png",
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: 100,
            left: 30,
            child: ElevatedButton(
              onPressed: () async => retryButtonPressed(context),
              child: Text('Retry'),
            ),
          )
        ],
      ),
    );
  }

  void retryButtonPressed(BuildContext context) async {
    bool hasInternet = await checkInternetConnectivity();

    if (hasInternet) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyApp(
            hasInternet: hasInternet,
            isFirstTime: false,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Still no internet connection.'),
        ),
      );
    }
  }
}
