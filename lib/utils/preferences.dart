import 'package:shared_preferences/shared_preferences.dart';

Future<void> initializePreferences() async {
  await SharedPreferences.getInstance();
}

Future<void> saveSelectedCities(List<String> cities) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList('selectedCities', cities);
}

Future<bool> getIsFirstTime() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isFirstTime') ?? true;
}

Future<void> setIsFirstTime(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isFirstTime', value);
}

List<String> getSelectedCities() {
  SharedPreferences prefs;
  List<String> selectedCities = [];

  prefs = SharedPreferences.getInstance() as SharedPreferences;
  selectedCities = prefs.getStringList('selectedCities') ?? [];

  return selectedCities;
}

Future<String?> getLastSelectedCity() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('lastSelectedCity');
}

Future<void> setLastSelectedCity(String city) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('lastSelectedCity', city);
}
