import 'package:flutter/material.dart';

class IntroScreen4 extends StatefulWidget {
  const IntroScreen4({super.key});

  @override
  State<IntroScreen4> createState() => _IntroScreen4State();
}

class _IntroScreen4State extends State<IntroScreen4> {
  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidht = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.deepPurple[100],
      child: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: deviceHeight * 0.11),
                child: Text(
                  'How to change the temp unit',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: deviceHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/change_unit1.png',
                  height: 200,
                  width: 200,
                ),
              ],
            ),
            SizedBox(height: deviceHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: deviceWidht * 0.9,
                  child: Text(
                      'In order to chnage the temp unit you will tap on the menu icon which will open a a list that has your saved locations and settings you will need to open settings.'),
                )
              ],
            ),
            SizedBox(height: deviceHeight * 0.0001),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/change_unit2.png',
                  height: 200,
                  width: 200,
                ),
              ],
            ),
            SizedBox(height: deviceHeight * 0.001),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: deviceWidht * 0.9,
                  child: Text(
                      'After you open settings you are going to change the temp unit to whatever you want, by default the temp unit is celsius.'),
                )
              ],
            ),
            SizedBox(height: deviceHeight * 0.02),
            SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Container(
                      width: deviceWidht * 0.9,
                      child: Text(
                        'Thanks for using my app, enjoy the all new exprience of seeing weather data.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
