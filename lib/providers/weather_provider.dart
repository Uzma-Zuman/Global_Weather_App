import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/weather_api.dart' ;
import '../models/weather.dart';

enum WeatherState { idle, loading, ready, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherApi _api = WeatherApi();

  WeatherState state = WeatherState.idle;
  Weather? weather;
  String? errorMessage;
  List<DailyForecast> forecast = [];

  Future<void> fetchByCoords(double lat, double lon) async {
    try {
      state = WeatherState.loading;
      notifyListeners();

      weather = await _api.fetchWeatherByCoords(lat, lon);
      forecast = await _api.fetch5DayForecast(lat, lon); // ✅ no cast


      state = WeatherState.ready;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      state = WeatherState.error;
      notifyListeners();
    }
  }

  Future<void> fetchByDeviceLocation() async {
    try {
      state = WeatherState.loading;
      notifyListeners();

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await fetchByCoords(pos.latitude, pos.longitude);
    } catch (e) {
      errorMessage = e.toString();
      state = WeatherState.error;
      notifyListeners();
    }
  }

  // ✅ Search city
  Future<List<Map<String, dynamic>>> searchCity(String query) async {
    try {
      return await _api.searchCity(query);
    } catch (e) {
      throw Exception('Failed to search city: $e');
    }
  }
}
