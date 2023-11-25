import 'package:flutter/material.dart';

class IntroScreen2 extends StatefulWidget {
  const IntroScreen2({super.key});

  @override
  State<IntroScreen2> createState() => _IntroScreen2State();
}

class _IntroScreen2State extends State<IntroScreen2> {
  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidht = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.purple[100],
      child: Column(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: deviceHeight * 0.12),
              child: Text(
                'How to delete a city',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/delete_city.png',
                height: 200,
                width: 200,
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: deviceWidht * 0.9,
                child: Text(
                    'In order to delete a city you will swipe the city to the left or right then confirm the deletion process so your city gets deleted.'),
              )
            ],
          ),
        ],
      ),
    );
  }
}
