import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

/// Provider class for managing weather state
class WeatherProvider with ChangeNotifier {
  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  final WeatherService _weatherService = WeatherService();

  // Getters
  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Fetch weather by city name
  Future<void> fetchWeatherByCity(String cityName) async {
    if (cityName.trim().isEmpty) {
      _errorMessage = 'Please enter a city name';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _weatherService.getWeatherByCity(cityName.trim());
      _weather = result;
      _errorMessage = null;
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('City not found')) {
        _errorMessage = 'City not found. Please check the spelling.';
      } else if (errorStr.contains('Invalid API key')) {
        _errorMessage = 'API configuration error. Please try again.';
      } else if (errorStr.contains('Connection')) {
        _errorMessage = 'No internet connection. Check your network.';
      } else if (errorStr.contains('timeout')) {
        _errorMessage = 'Request timeout. Please try again.';
      } else {
        _errorMessage = 'Failed to load weather. Please try again.';
      }
      _weather = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch weather by coordinates
  Future<void> fetchWeatherByCoordinates(double lat, double lon) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _weatherService.getWeatherByCoordinates(lat, lon);
      _weather = result;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load weather. Check your internet connection.';
      _weather = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
