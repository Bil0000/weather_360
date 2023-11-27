import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TemperatureUnit { celsius, fahrenheit }

class Settings extends StatefulWidget {
  final void Function(TemperatureUnit) onTemperatureUnitChanged;

  const Settings({
    Key? key,
    required this.onTemperatureUnitChanged,
  }) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TemperatureUnit _selectedTemperatureUnit = TemperatureUnit.celsius;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    TemperatureUnit? temperatureUnit =
        TemperatureUnit.values[prefs.getInt('temperatureUnit') ?? 0];
    setState(() {
      _selectedTemperatureUnit = temperatureUnit ?? TemperatureUnit.celsius;
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('temperatureUnit', _selectedTemperatureUnit.index);
    widget.onTemperatureUnitChanged(_selectedTemperatureUnit);
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(57, 26, 73, 1),
              Color.fromRGBO(48, 29, 92, 1),
              Color.fromRGBO(38, 33, 113, 1),
              Color.fromRGBO(48, 29, 92, 1),
              Color.fromRGBO(57, 26, 73, 1),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
              top: deviceHeight * 0.158, left: 16, right: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Choose a Temperature Unit:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 15),
              Center(
                child: DropdownButton<TemperatureUnit>(
                  value: _selectedTemperatureUnit,
                  onChanged: (TemperatureUnit? value) {
                    if (value != null) {
                      setState(() {
                        _selectedTemperatureUnit = value;
                        _saveSettings();
                      });
                    }
                  },
                  items: TemperatureUnit.values.map((TemperatureUnit unit) {
                    return DropdownMenuItem<TemperatureUnit>(
                      value: unit,
                      child: Text(
                        unit == TemperatureUnit.celsius
                            ? 'Celsius'
                            : 'Fahrenheit',
                        style: TextStyle(color: Colors.blue),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
