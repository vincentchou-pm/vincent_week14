import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/weather_provider.dart';
import 'models/weather_model.dart';
import 'widgets/weather_widgets.dart';

void main() {
  runApp(const MyApp());
}

/// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: MaterialApp(
        title: 'Weather Forecast',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        home: const WeatherHomePage(),
      ),
    );
  }
}

/// Main weather home page
class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  @override
  void initState() {
    super.initState();
    // Fetch initial weather for London
    Future.microtask(() {
      context.read<WeatherProvider>().fetchWeatherByCity('London');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, _) {
        // Get gradient colors based on weather condition
        final gradientColors =
            weatherProvider.weather?.getGradientColors() ??
            [const Color(0xFF0F3460), const Color(0xFF16213E)];

        return Scaffold(
          body: Container(
            // Dynamic background gradient
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradientColors,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Search card section
                      CitySearchCard(
                        onSearch: (city) {
                          context.read<WeatherProvider>().fetchWeatherByCity(
                            city,
                          );
                        },
                        isLoading: weatherProvider.isLoading,
                      ),

                      const SizedBox(height: 32),

                      // Loading state
                      if (weatherProvider.isLoading)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Fetching weather...',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 60),
                          ],
                        )
                      // Error state
                      else if (weatherProvider.hasError)
                        Column(
                          children: [
                            const SizedBox(height: 40),
                            ErrorMessageWidget(
                              message:
                                  weatherProvider.errorMessage ??
                                  'Unknown error',
                              onRetry: () {
                                context
                                    .read<WeatherProvider>()
                                    .fetchWeatherByCity('London');
                              },
                            ),
                            const SizedBox(height: 60),
                          ],
                        )
                      // Success state - Display weather
                      else if (weatherProvider.weather != null)
                        WeatherContent(weather: weatherProvider.weather!)
                      // Empty state
                      else
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            Text(
                              '🔍 Enter a city name to get started',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget displaying weather content when data is available
class WeatherContent extends StatefulWidget {
  final WeatherModel weather;

  const WeatherContent({Key? key, required this.weather}) : super(key: key);

  @override
  State<WeatherContent> createState() => _WeatherContentState();
}

class _WeatherContentState extends State<WeatherContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(WeatherContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weather.cityName != widget.weather.cityName) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Main weather card
          WeatherCard(weather: widget.weather),

          const SizedBox(height: 32),

          // Large weather icon/illustration
          WeatherIconDisplay(
            mainCondition: widget.weather.mainCondition,
            size: 110,
          ),

          const SizedBox(height: 32),

          // Weather details card
          WeatherDetailsCard(
            humidity: widget.weather.humidity,
            windSpeed: widget.weather.windSpeed,
            pressure: widget.weather.pressure,
            cloudiness: widget.weather.cloudiness,
          ),

          const SizedBox(height: 32),

          // 7-day forecast section
          if (widget.weather.forecast.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '7-Day Forecast',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.weather.forecast.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return ForecastItem(
                    forecastDay: widget.weather.forecast[index],
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
