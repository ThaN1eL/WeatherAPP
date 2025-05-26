import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  Weather? _weather;
  bool _isLoading = false;
  String _errorMessage = '';
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWeatherByLocation();
  }

  Future<void> _fetchWeatherByLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable GPS and try again.';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permission denied. Please use manual search.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions are permanently denied. Please enable in device settings or use manual search.';
          _isLoading = false;
        });
        return;
      }

      // Try to get location with timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      final weather = await _weatherService.getCurrentWeatherByLocation();
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Cannot get your location. Please use manual search or check GPS settings.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherByCity() async {
    if (_cityController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final weather = await _weatherService.getCurrentWeather(_cityController.text.trim());
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'City not found or network error';
        _isLoading = false;
      });
    }
  }

  String _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'fog':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text('Weather App'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          hintText: 'Enter city name',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _fetchWeatherByCity(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: _fetchWeatherByCity,
                    ),
                    IconButton(
                      icon: Icon(Icons.my_location),
                      onPressed: _fetchWeatherByLocation,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Weather Content
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, size: 64, color: Colors.red),
                              SizedBox(height: 16),
                              Text(
                                _errorMessage, 
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchWeatherByLocation,
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _weather != null
                          ? _buildWeatherDisplay()
                          : Center(child: Text('No weather data')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDisplay() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Main Weather Card
          Card(
            elevation: 8,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _weather!.cityName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    DateFormat('EEEE, MMM d').format(_weather!.dateTime),
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _getWeatherIcon(_weather!.mainCondition),
                    style: TextStyle(fontSize: 80),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${_weather!.temperature.round()}°C',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _weather!.description.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          
          // Weather Details
          Row(
            children: [
              Expanded(
                child: _buildDetailCard(
                  'Humidity',
                  '${_weather!.humidity}%',
                  Icons.water_drop,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildDetailCard(
                  'Wind Speed',
                  '${_weather!.windSpeed.toStringAsFixed(1)} m/s',
                  Icons.air,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailCard(
                  'Pressure',
                  '${_weather!.pressure} hPa',
                  Icons.speed,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildDetailCard(
                  'Feels Like',
                  '${_weather!.temperature.round()}°C',
                  Icons.thermostat,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue.shade600),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}