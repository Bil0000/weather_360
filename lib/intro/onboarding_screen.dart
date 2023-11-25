import 'package:flutter/material.dart';
import 'package:weather_360/intro/intro_screen1.dart';
import 'package:weather_360/intro/intro_screen2.dart';
import 'package:weather_360/intro/intro_screen3.dart';
import 'package:weather_360/intro/intro_screen4.dart';
import 'package:weather_360/screens/selectedcity_screen.dart';
import 'package:weather_360/utils/preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  final List<String> selectedCities;
  const OnBoardingScreen({Key? key, required this.selectedCities})
      : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  PageController _controller = PageController();

  bool onLastPage = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 3);
              });
            },
            children: [
              IntroScreen1(),
              IntroScreen2(),
              IntroScreen3(),
              IntroScreen4(),
            ],
          ),
          Center(
            child: Container(
              alignment: Alignment(0, 0.87),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 25),
                    child: GestureDetector(
                      onTap: () async {
                        await setIsFirstTime(false);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return CitySelectionScreen(
                                  selectedCities: widget.selectedCities);
                            },
                          ),
                        );
                      },
                      child: Text('Skip'),
                    ),
                  ),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 4,
                    onDotClicked: (index) {
                      _controller.animateToPage(
                        index,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  onLastPage
                      ? Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: GestureDetector(
                            onTap: () async {
                              await setIsFirstTime(false);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return CitySelectionScreen(
                                        selectedCities: widget.selectedCities);
                                  },
                                ),
                              );
                            },
                            child: Text('Done'),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: GestureDetector(
                            onTap: () async {
                              _controller.nextPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeIn,
                              );
                            },
                            child: Text('Next'),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
