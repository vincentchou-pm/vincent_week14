# Weather Forecast Mobile App

A modern, clean Flutter weather application with dynamic backgrounds, real-time weather updates, and a beautiful UI.

## 🚀 Features

- **Dynamic Background Gradients**: Background colors change based on weather conditions
  - Sunny → Light to deep blue
  - Cloudy → Grey-blue gradient
  - Rainy → Dark blue gradient
  - Thunderstorm → Dark purple/blue
  - Night → Dark navy/black

- **Real-time Weather Data**: 
  - Current weather for any city
  - 7-day forecast
  - Weather details (humidity, wind speed, pressure, cloudiness)

- **Clean, Modern UI**:
  - Large temperature display with day name
  - Weather status descriptions
  - Large weather emoji illustrations
  - Horizontal scrollable 7-day forecast
  - Card-based weather details display

- **City Search**:
  - Search any city worldwide
  - Table-like card input form
  - Loading states and error handling

- **Error Handling**:
  - Invalid city name detection
  - Network error management
  - User-friendly error messages with retry option

- **Smooth Animations**:
  - Fade-in transitions when weather data loads
  - Smooth UI transitions between different cities

## 📦 Project Structure

```
lib/
├── main.dart                 # Main app entry point with home page
├── models/
│   └── weather_model.dart   # Weather and ForecastDay data models
├── services/
│   └── weather_service.dart # OpenWeatherMap API integration
├── providers/
│   └── weather_provider.dart # State management using Provider
└── widgets/
    └── weather_widgets.dart  # Reusable UI components
```

## 🎨 Key Components

### Models (`weather_model.dart`)
- **WeatherModel**: Main weather data model with UI utilities
- **ForecastDay**: Individual day forecast data

### Services (`weather_service.dart`)
- **WeatherService**: Handles API calls to OpenWeatherMap
  - `getWeatherByCity()`: Fetch weather by city name
  - `getWeatherByCoordinates()`: Fetch weather by latitude/longitude

### State Management (`weather_provider.dart`)
- **WeatherProvider**: ChangeNotifier for managing weather state
  - Handles loading, error, and success states
  - Provides weather data to the UI

### Widgets (`weather_widgets.dart`)
- **WeatherCard**: Displays current temperature and day
- **WeatherIconDisplay**: Large emoji-based weather illustration
- **WeatherDetailsCard**: Humidity, wind speed, pressure, cloudiness
- **ForecastItem**: Individual forecast day card
- **CitySearchCard**: Search input with button
- **ErrorMessageWidget**: Error display with retry option

## 🔑 API Key

**API Key**: `e244979f928d9493c8f14669e26cf61c`

The app uses OpenWeatherMap API for weather data. The API key is embedded in the service layer.

## 📱 How to Run

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

3. **Use the app:**
   - Enter a city name in the search box
   - Click "Search" to fetch weather data
   - View current weather, details, and 7-day forecast
   - Try different cities to see dynamic background changes

## 🎯 Default City

The app loads **London** weather on startup for demonstration purposes.

## 🛠️ Technologies Used

- **Flutter**: Latest stable version
- **Provider**: State management
- **HTTP**: API calls
- **Google Fonts**: Modern typography (Poppins)
- **Intl**: Date formatting

## 📊 Weather Conditions Supported

- Clear (Sunny)
- Clouds (Cloudy)
- Rain (Rainy)
- Thunderstorm
- Drizzle
- Snow
- Mist/Fog/Haze

## 🎨 Design Features

- Minimal and aesthetic layout
- Soft shadows and rounded corners
- Consistent padding and spacing
- Clean sans-serif fonts (Poppins)
- Semi-transparent cards for depth
- Smooth color transitions
- Loading spinners
- Error handling UI

## 💡 Usage Examples

### Search a City
1. Type city name (e.g., "Paris", "Tokyo", "New York")
2. Tap Search button or press Enter
3. Watch the background gradient change based on weather
4. Swipe through the 7-day forecast

### Retry After Error
- If city not found, tap the "Retry" button
- Try with corrected city name
- Or search a different city

## 🔄 Future Enhancements

- GPS location detection for automatic weather
- Weather alerts and notifications
- Favorite cities list
- Historical weather data
- Weather maps integration
- Multiple language support
- Dark/Light theme toggle
