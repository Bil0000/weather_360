import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CitySearchDelegate extends SearchDelegate<String> {
  final String apiKey =
      dotenv.get('API_KEY', fallback: 'Could not connect to the api!');

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildCityResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildCityResults(context, isSuggestion: true);
  }

  Widget _buildCityResults(BuildContext context, {bool isSuggestion = false}) {
    if (query.isEmpty) {
      return Container();
    }

    final apiUrl =
        "http://api.openweathermap.org/data/2.5/find?q=$query&type=like&mode=json&appid=$apiKey";

    return FutureBuilder(
      future: http.get(Uri.parse(apiUrl)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.statusCode != 200) {
          return Center(child: Text("No data available"));
        } else {
          final response = json.decode(snapshot.data!.body);
          final cities = response['list'] as List<dynamic>;

          final uniqueCities = Set<String>();
          final filteredCities = cities.where((city) {
            final cityName = city['name'] as String;
            final country = city['sys']['country'] as String;
            final cityString = "$cityName, $country";
            return uniqueCities.add(cityString);
          }).toList();

          return SuggestionOverlay(
            query: query,
            isSuggestion: isSuggestion,
            suggestions: filteredCities.map<String>((city) {
              final cityName = city['name'] as String;
              final country = city['sys']['country'] as String;
              return "$cityName, $country";
            }).toList(),
            onSelected: (String suggestion) {
              close(context, suggestion);
            },
          );
        }
      },
    );
  }
}

class SuggestionOverlay extends StatelessWidget {
  final String query;
  final bool isSuggestion;
  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  SuggestionOverlay({
    required this.query,
    required this.isSuggestion,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,
      child: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];

          return ListTile(
            title: Text(
              suggestion,
              style: const TextStyle(color: Colors.black),
            ),
            onTap: () {
              onSelected(suggestion);
            },
          );
        },
      ),
    );
  }
}
