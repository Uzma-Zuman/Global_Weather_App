// models/weather.dart

class Weather {
  final double temperature;
  final String description;
  final String city;
  final double lat;
  final double lon;
  final double feelsLike;
  final double minTemp;
  final double maxTemp;
  final int humidity;
  final double windSpeed;
  final int dt; // current weather timestamp

  // Optional: daily forecast
  final List<DailyForecast>? dailyForecast;

  Weather({
    required this.temperature,
    required this.description,
    required this.city,
    required this.lat,
    required this.lon,
    required this.feelsLike,
    required this.minTemp,
    required this.maxTemp,
    required this.humidity,
    required this.windSpeed,
    required this.dt,
    this.dailyForecast,
  });

  /// Parse current weather JSON
  factory Weather.fromCurrentJson(Map<String, dynamic> json) {
    return Weather(
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      city: json['name'] ?? "Unknown",
      lat: (json['coord']['lat'] as num).toDouble(),
      lon: (json['coord']['lon'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      minTemp: (json['main']['temp_min'] as num).toDouble(),
      maxTemp: (json['main']['temp_max'] as num).toDouble(),
      humidity: (json['main']['humidity'] as num).toInt(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      dt: json['dt'] as int,
      dailyForecast: null, // no forecast in current weather
    );
  }

  /// Parse forecast JSON (7-day) from One Call API
  factory Weather.fromForecastJson(Map<String, dynamic> json) {
    final dailyData = (json['daily'] as List<dynamic>?)
        ?.map((e) => DailyForecast.fromJson(e as Map<String, dynamic>))
        .toList() ??
        [];

    return Weather(
      temperature: 0,
      description: '',
      city: '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      feelsLike: 0,
      minTemp: 0,
      maxTemp: 0,
      humidity: 0,
      windSpeed: 0,
      dt: 0,
      dailyForecast: dailyData,
    );
  }
}

/// Model for a single day's forecast
class DailyForecast {
  final int dt; // timestamp
  final double tempDay;
  final double tempMin;
  final double tempMax;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;

  DailyForecast({
    required this.dt,
    required this.tempDay,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      dt: json['dt'] as int,
      tempDay: (json['temp']['day'] as num?)?.toDouble() ?? 0,
      tempMin: (json['temp']['min'] as num?)?.toDouble() ?? 0,
      tempMax: (json['temp']['max'] as num?)?.toDouble() ?? 0,
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 0,
    );
  }
}
