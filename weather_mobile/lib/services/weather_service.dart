import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/weather_model.dart';

/// Service class to handle weather API calls using OpenWeatherMap 2.5 onecall API
/// Combines current weather + 7-day forecast in a single efficient call
class WeatherService {
  // API credentials
  static const String _apiKey = '5f4d1daf7bce9490b82d49456973e5b1';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _geoUrl = 'https://api.openweathermap.org/geo/1.0';

  /// Geocode city name to get latitude and longitude
  Future<Map<String, dynamic>> _geocodeCity(String cityName) async {
    try {
      final geoUrl = '$_geoUrl/direct?q=$cityName&limit=1&appid=$_apiKey';
      final response = await http
          .get(Uri.parse(geoUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Geocoding failed');
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      if (data.isEmpty) {
        throw Exception('City not found');
      }

      final cityData = data[0] as Map<String, dynamic>;
      return {
        'lat': (cityData['lat'] as num).toDouble(),
        'lon': (cityData['lon'] as num).toDouble(),
        'name': cityData['name'] ?? 'Unknown',
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch current weather and 5-day forecast
  Future<WeatherModel> getWeatherByCity(String cityName) async {
    try {
      // First, geocode the city name to get coordinates
      final coords = await _geocodeCity(cityName);
      final lat = coords['lat'] as double;
      final lon = coords['lon'] as double;
      final displayName = coords['name'] as String;

      return await getWeatherByCoordinates(lat, lon, displayName);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch weather by coordinates using weather + forecast endpoints
  Future<WeatherModel> getWeatherByCoordinates(
    double latitude,
    double longitude, [
    String? cityName,
  ]) async {
    try {
      // Fetch current weather
      final weatherUrl =
          '$_baseUrl/weather?lat=$latitude&lon=$longitude&units=metric&appid=$_apiKey';
      final weatherResponse = await http
          .get(Uri.parse(weatherUrl))
          .timeout(const Duration(seconds: 10));

      if (weatherResponse.statusCode == 401 ||
          weatherResponse.statusCode == 403) {
        throw Exception('Invalid API key');
      }

      if (weatherResponse.statusCode != 200) {
        throw Exception('API Error: ${weatherResponse.statusCode}');
      }

      final weatherData =
          jsonDecode(weatherResponse.body) as Map<String, dynamic>;

      // Fetch 5-day forecast
      final forecastUrl =
          '$_baseUrl/forecast?lat=$latitude&lon=$longitude&units=metric&appid=$_apiKey';
      final forecastResponse = await http
          .get(Uri.parse(forecastUrl))
          .timeout(const Duration(seconds: 10));

      List<dynamic> forecastList = [];
      if (forecastResponse.statusCode == 200) {
        final forecastData =
            jsonDecode(forecastResponse.body) as Map<String, dynamic>;
        forecastList = (forecastData['list'] as List<dynamic>?) ?? [];
      }

      return _parseWeatherResponse(weatherData, forecastList, cityName);
    } catch (e) {
      rethrow;
    }
  }

  /// Parse weather + forecast API response
  WeatherModel _parseWeatherResponse(
    Map<String, dynamic> weatherData,
    List<dynamic> forecastList,
    String? cityName,
  ) {
    // Parse current weather
    final weatherList = weatherData['weather'] as List<dynamic>;
    final weather = weatherList.first as Map<String, dynamic>;
    final main = weatherData['main'] as Map<String, dynamic>;
    final wind = weatherData['wind'] as Map<String, dynamic>;
    final sys = weatherData['sys'] as Map<String, dynamic>;

    // Parse 5-day forecast - group by day and take first forecast of each day
    final Map<int, Map<String, dynamic>> forecastByDay = {};
    for (final item in forecastList) {
      final itemMap = item as Map<String, dynamic>;
      final dateTime = DateTime.parse(itemMap['dt_txt'] as String);
      final dayKey = dateTime.day;

      // Only keep first forecast of each day
      if (!forecastByDay.containsKey(dayKey)) {
        forecastByDay[dayKey] = itemMap;
      }
    }

    // Convert to list of ForecastDay objects (max 7 days)
    final forecast = forecastByDay.values.take(7).map((dayData) {
      final dayWeatherList = dayData['weather'] as List<dynamic>;
      final dayWeather = dayWeatherList.first as Map<String, dynamic>;
      final temp = dayData['main'] as Map<String, dynamic>;
      final wind = dayData['wind'] as Map<String, dynamic>;

      return ForecastDay(
        dateTime: DateTime.parse(dayData['dt_txt'] as String),
        temperature: (temp['temp'] as num).toDouble(),
        tempMin: (temp['temp_min'] as num).toDouble(),
        tempMax: (temp['temp_max'] as num).toDouble(),
        mainCondition: dayWeather['main'] as String,
        description: dayWeather['description'] as String,
        humidity: temp['humidity'] as int,
        windSpeed: (wind['speed'] as num).toDouble(),
        pressure: (temp['pressure'] as num).toDouble(),
      );
    }).toList();

    return WeatherModel(
      cityName: cityName ?? weatherData['name'] as String? ?? 'Unknown',
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      description: weather['description'] as String,
      mainCondition: weather['main'] as String,
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num).toDouble(),
      pressure: (main['pressure'] as num).toDouble(),
      cloudiness: weatherData['clouds']['all'] as int,
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (weatherData['dt'] as int) * 1000,
      ),
      sunrise: sys['sunrise'] as int,
      sunset: sys['sunset'] as int,
      forecast: forecast,
    );
  }
}
