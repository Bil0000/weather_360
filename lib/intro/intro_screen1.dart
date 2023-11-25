import 'package:flutter/material.dart';

class IntroScreen1 extends StatefulWidget {
  const IntroScreen1({super.key});

  @override
  State<IntroScreen1> createState() => _IntroScreen1State();
}

class _IntroScreen1State extends State<IntroScreen1> {
  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidht = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.blue,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: deviceHeight * 0.11),
                child: Text(
                  'Main app features',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: deviceHeight * 0.03),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Container(
                    width: deviceWidht * 0.9,
                    child: Text(
                        '1. No data will be collected, every thing is stored locally on your device.'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Container(
                    width: deviceWidht * 0.9,
                    child: Text(
                        '2. Auto city selection based on location with no data collection.'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Container(
                    width: deviceWidht * 0.9,
                    child: Text(
                        '3. You could add new cities from all over the world and it will be saved to your saved locations, you can save locations up to 10,000 city.'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Container(
                    width: deviceWidht * 0.9,
                    child: Text(
                        '4. You could also remove unwanted saved locations, and reorder your saved location by your most loved or most used city or whatever you like.'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Container(
                    width: deviceWidht * 0.9,
                    child: Text(
                        '5. If you want you could change the temp unit to fahrenheit instead of the default which is celsius.'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Container(
                    width: deviceWidht * 0.9,
                    child:
                        Text('6. Up to 5 days of accurate weather forecast.'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Container(
                    width: deviceWidht * 0.9,
                    child: Text(
                        '7. Modern and user friendly design with animations and animated background based on weather.'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Container(
                    width: deviceWidht * 0.9,
                    child: Text(
                        '8. Very good and fast performance for all kind of devices.'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Container(
                    width: deviceWidht * 0.9,
                    child: Text(
                        '9. Our app is cross platfrom so you could access it from any device you want.'),
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
