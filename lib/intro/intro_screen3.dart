import 'package:flutter/material.dart';

class IntroScreen3 extends StatefulWidget {
  const IntroScreen3({super.key});

  @override
  State<IntroScreen3> createState() => _IntroScreen3State();
}

class _IntroScreen3State extends State<IntroScreen3> {
  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidht = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.amber[300],
      child: Column(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: deviceHeight * 0.12),
              child: Text(
                'How to reorder your cities',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/reorder_city.png',
                height: 200,
                width: 200,
              ),
            ],
          ),
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: deviceWidht * 0.9,
                child: Text(
                    'In order to reorder your cities you will tap and hold on the city you want to reorder and then swip up or down and release your finger when you put your city in the place you want and the city will be reordered.'),
              )
            ],
          ),
        ],
      ),
    );
  }
}
