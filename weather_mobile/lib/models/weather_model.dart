import 'package:flutter/material.dart';

/// Weather model to represent weather data from OpenWeatherMap API
class WeatherModel {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final String description;
  final String mainCondition; // 'Clear', 'Clouds', 'Rain', 'Thunderstorm', etc.
  final int humidity;
  final double windSpeed;
  final double pressure;
  final int cloudiness;
  final DateTime dateTime;
  final int sunrise;
  final int sunset;
  final List<ForecastDay> forecast;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.mainCondition,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.cloudiness,
    required this.dateTime,
    required this.sunrise,
    required this.sunset,
    required this.forecast,
  });

  /// Factory constructor to parse JSON response from OpenWeatherMap
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? 'Unknown',
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      feelsLike: (json['main']['feels_like'] ?? 0).toDouble(),
      description: json['weather'][0]['description'] ?? 'N/A',
      mainCondition: json['weather'][0]['main'] ?? 'Clear',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      pressure: (json['main']['pressure'] ?? 0).toDouble(),
      cloudiness: json['clouds']['all'] ?? 0,
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] ?? 0) * 1000),
      sunrise: json['sys']['sunrise'] ?? 0,
      sunset: json['sys']['sunset'] ?? 0,
      forecast: [], // Will be populated from forecast API
    );
  }

  /// Get weather condition emoji/icon name
  String getWeatherIcon() {
    switch (mainCondition.toLowerCase()) {
      case 'clear':
        return '☀️ Sunny';
      case 'clouds':
        return '☁️ Cloudy';
      case 'rain':
        return '🌧️ Rainy';
      case 'thunderstorm':
        return '⛈️ Thunderstorm';
      case 'drizzle':
        return '🌦️ Drizzle';
      case 'snow':
        return '❄️ Snow';
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
      case 'sand':
      case 'ash':
      case 'squall':
      case 'tornado':
        return '🌫️ Misty';
      default:
        return '🌤️ Weather';
    }
  }

  /// Get gradient colors based on weather condition
  List<Color> getGradientColors() {
    switch (mainCondition.toLowerCase()) {
      case 'clear':
        // Sunny - light blue to deep blue
        return [
          const Color(0xFF87CEEB), // Sky blue
          const Color(0xFF1E90FF), // Dodger blue
        ];
      case 'clouds':
        // Cloudy - grey-blue gradient
        return [
          const Color(0xFFB0C4DE), // Light slate grey
          const Color(0xFF708090), // Slate grey
        ];
      case 'rain':
        // Rainy - dark blue gradient
        return [
          const Color(0xFF4A617B), // Dark blue-grey
          const Color(0xFF1C3A47), // Very dark blue
        ];
      case 'thunderstorm':
        // Thunderstorm - dark purple/blue
        return [
          const Color(0xFF2F1B56), // Dark purple
          const Color(0xFF1A1A2E), // Very dark blue
        ];
      default:
        // Night or other - dark navy
        return [
          const Color(0xFF0F3460), // Dark navy
          const Color(0xFF16213E), // Very dark blue
        ];
    }
  }
}

/// Model for individual forecast days
class ForecastDay {
  final DateTime dateTime;
  final double temperature;
  final double tempMin;
  final double tempMax;
  final String mainCondition;
  final String description;
  final int humidity;
  final double windSpeed;
  final double pressure;

  ForecastDay({
    required this.dateTime,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    required this.mainCondition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] ?? 0) * 1000),
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      tempMin: (json['main']['temp_min'] ?? 0).toDouble(),
      tempMax: (json['main']['temp_max'] ?? 0).toDouble(),
      mainCondition: json['weather'][0]['main'] ?? 'Clear',
      description: json['weather'][0]['description'] ?? 'N/A',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      pressure: (json['main']['pressure'] ?? 0).toDouble(),
    );
  }

  /// Get emoji for forecast item
  String getWeatherEmoji() {
    switch (mainCondition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'thunderstorm':
        return '⛈️';
      case 'drizzle':
        return '🌦️';
      case 'snow':
        return '❄️';
      default:
        return '🌤️';
    }
  }
}
