import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherApi {
  final String _key = dotenv.env['OWM_API_KEY'] ?? '';

  WeatherApi() {
    if (_key.isEmpty) {
      throw Exception("❌ Missing API Key: Please add OWM_API_KEY to your .env file");
    }
  }

  static const _baseCurrent = 'https://api.openweathermap.org/data/2.5/weather';
  static const _baseForecast = 'https://api.openweathermap.org/data/2.5/forecast';
  static const _geocodeDirect = 'https://api.openweathermap.org/geo/1.0/direct';
  static const _geocodeReverse = 'https://api.openweathermap.org/geo/1.0/reverse';

  // ✅ Current weather
  Future<Weather> fetchWeatherByCoords(double lat, double lon, {String units = 'metric'}) async {
    final uri = Uri.parse('$_baseCurrent?lat=$lat&lon=$lon&units=$units&appid=$_key');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to load weather: ${res.body}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return Weather.fromCurrentJson(json);
  }

  // ✅ 5-day forecast (aggregates 3-hour intervals to daily)
  Future<List<DailyForecast>> fetch5DayForecast(double lat, double lon) async {
    final uri = Uri.parse('$_baseForecast?lat=$lat&lon=$lon&units=metric&appid=$_key');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to load forecast: ${res.body}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final List<dynamic> list = json['list'];

    // Group 3-hour forecasts by day
    final Map<DateTime, List<dynamic>> dailyMap = {};
    for (var item in list) {
      final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final dayKey = DateTime(dt.year, dt.month, dt.day);
      dailyMap.putIfAbsent(dayKey, () => []).add(item);
    }

    final List<DailyForecast> forecast = [];

    dailyMap.forEach((date, items) {
      double minTemp = double.infinity;
      double maxTemp = -double.infinity;
      double tempSum = 0;
      double windSum = 0;
      int humiditySum = 0;
      int count = items.length;

      String icon = items.first['weather'][0]['icon'];
      String description = items.first['weather'][0]['description'];

      for (var i in items) {
        final temp = (i['main']['temp'] as num).toDouble();
        final wind = (i['wind']['speed'] as num).toDouble();
        final humidity = (i['main']['humidity'] as num).toInt();

        if (temp < minTemp) minTemp = temp;
        if (temp > maxTemp) maxTemp = temp;

        tempSum += temp;
        windSum += wind;
        humiditySum += humidity;
      }

      forecast.add(DailyForecast(
        dt: date.millisecondsSinceEpoch ~/ 1000,
        tempDay: tempSum / count,
        tempMin: minTemp,
        tempMax: maxTemp,
        icon: icon,
        description: description,
        windSpeed: windSum / count,
        humidity: (humiditySum / count).round(),
      ));
    });

    // Sort by date and return next 5 days
    forecast.sort((a, b) => a.dt.compareTo(b.dt));
    return forecast.take(5).toList();
  }

  // ✅ Search city
  Future<List<Map<String, dynamic>>> searchCity(String query, {int limit = 5}) async {
    final q = Uri.encodeComponent(query);
    final uri = Uri.parse('$_geocodeDirect?q=$q&limit=$limit&appid=$_key');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to search city: ${res.body}');
    }

    final arr = jsonDecode(res.body) as List<dynamic>;
    return arr.map((e) => e as Map<String, dynamic>).toList();
  }

  // ✅ Reverse geocode
  Future<Map<String, dynamic>?> reverseGeocode(double lat, double lon, {int limit = 1}) async {
    final uri = Uri.parse('$_geocodeReverse?lat=$lat&lon=$lon&limit=$limit&appid=$_key');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      return null;
    }

    final arr = jsonDecode(res.body) as List<dynamic>;
    if (arr.isEmpty) return null;
    return arr.first as Map<String, dynamic>;
  }
}
