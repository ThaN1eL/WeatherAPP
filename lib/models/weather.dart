class Weather {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final String description;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final DateTime dateTime;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.dateTime,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      pressure: json['main']['pressure'],
      dateTime: DateTime.now(),
    );
  }
}