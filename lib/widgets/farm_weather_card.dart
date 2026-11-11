import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class FarmWeatherCard extends StatefulWidget {
  const FarmWeatherCard({super.key});

  @override
  State<FarmWeatherCard> createState() => _FarmWeatherCardState();
}

class _FarmWeatherCardState extends State<FarmWeatherCard> {
  static const Color darkGreen = Color(0xFF0B3D1B);
  static const Color mediumGreen = Color(0xFF2E7D32);

  FarmWeather? _weather;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final result = await FarmWeatherService().getCurrentWeather();
      if (!mounted) return;
      setState(() {
        _weather = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  IconData _weatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if ([1, 2, 3].contains(code)) return Icons.cloud_rounded;
    if ([45, 48].contains(code)) return Icons.foggy;
    if ([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82]
        .contains(code)) {
      return Icons.water_drop_rounded;
    }
    if ([95, 96, 99].contains(code)) return Icons.thunderstorm_rounded;
    if ([71, 73, 75, 77, 85, 86].contains(code)) return Icons.ac_unit_rounded;
    return Icons.cloud_queue_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [darkGreen, mediumGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const SizedBox(
        height: 190,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 14),
              Text('Getting your local weather...',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    if (_weather == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cloud_off, color: Colors.white, size: 36),
          const SizedBox(height: 12),
          const Text(
            'Weather unavailable',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(_error ?? 'Check your GPS and internet connection.',
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _loadWeather,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Try again', style: TextStyle(color: Colors.white)),
          ),
          if (_error?.toLowerCase().contains('permission') == true)
            TextButton(
              onPressed: Geolocator.openAppSettings,
              child: const Text('Open location settings',
                  style: TextStyle(color: Colors.white)),
            ),
        ],
      );
    }

    final weather = _weather!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on_outlined, color: Colors.white70),
            const SizedBox(width: 6),
            Expanded(
              child: Text(weather.location,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  )),
            ),
            IconButton(
              tooltip: 'Refresh weather',
              onPressed: _loadWeather,
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${weather.temperature.round()}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                      )),
                  Text(weather.condition,
                      style: const TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Feels like ${weather.feelsLike.round()}°C',
                      style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            Icon(_weatherIcon(weather.weatherCode),
                size: 76, color: const Color(0xFFFFD54F)),
          ],
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 18,
          runSpacing: 12,
          children: [
            _weatherDetail(Icons.water_drop_outlined, 'Humidity', '${weather.humidity}%'),
            _weatherDetail(Icons.air, 'Wind', '${weather.windSpeed.round()} km/h'),
            _weatherDetail(Icons.grain, 'Rainfall', '${weather.rainfall.toStringAsFixed(1)} mm'),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(color: Colors.white30),
        const SizedBox(height: 8),
        Text(weather.farmingAdvice,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            )),
        const SizedBox(height: 10),
        const Text('Weather data: Open-Meteo',
            style: TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _weatherDetail(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 5),
        Text('$label: $value',
            style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }
}

class FarmWeather {
  final String location;
  final double temperature;
  final double feelsLike;
  final String condition;
  final int weatherCode;
  final int humidity;
  final double windSpeed;
  final double rainfall;
  final String farmingAdvice;

  const FarmWeather({
    required this.location,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.weatherCode,
    required this.humidity,
    required this.windSpeed,
    required this.rainfall,
    required this.farmingAdvice,
  });
}

class FarmWeatherService {
  Future<FarmWeather> getCurrentWeather() async {
    final position = await _getPosition();
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': position.latitude.toString(),
      'longitude': position.longitude.toString(),
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
      'timezone': 'auto',
      'wind_speed_unit': 'kmh',
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Unable to retrieve weather data.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final current = data['current'] as Map<String, dynamic>;
    final code = (current['weather_code'] as num).toInt();
    final rain = (current['precipitation'] as num).toDouble();
    final wind = (current['wind_speed_10m'] as num).toDouble();
    final temp = (current['temperature_2m'] as num).toDouble();

    return FarmWeather(
      location: 'Your current location',
      temperature: temp,
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      condition: _conditionFromCode(code),
      weatherCode: code,
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: wind,
      rainfall: rain,
      farmingAdvice: _farmingAdvice(code, rain, wind, temp),
    );
  }

  Future<Position> _getPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Please enable your device location service.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is permanently denied. Open app settings.');
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  String _conditionFromCode(int code) {
    if (code == 0) return 'Clear sky';
    if ([1, 2, 3].contains(code)) return 'Partly cloudy';
    if ([45, 48].contains(code)) return 'Foggy';
    if ([51, 53, 55, 56, 57].contains(code)) return 'Drizzle';
    if ([61, 63, 65, 66, 67, 80, 81, 82].contains(code)) return 'Rain';
    if ([71, 73, 75, 77, 85, 86].contains(code)) return 'Snow';
    if ([95, 96, 99].contains(code)) return 'Thunderstorm';
    return 'Variable conditions';
  }

  String _farmingAdvice(int code, double rain, double wind, double temp) {
    if ([95, 96, 99].contains(code)) {
      return 'Stormy conditions possible. Delay outdoor fieldwork and protect livestock where possible.';
    }
    if (wind >= 35) {
      return 'Strong winds are possible. Secure equipment and avoid spraying in windy conditions.';
    }
    if (rain >= 5 || [61, 63, 65, 80, 81, 82].contains(code)) {
      return 'Rain is occurring or expected. Check drainage and consider postponing work on wet fields.';
    }
    if (temp >= 35) {
      return 'Very hot conditions. Check soil moisture and provide livestock with shade and drinking water.';
    }
    if (temp >= 30) {
      return 'Warm conditions. Monitor crops for water stress and check livestock water supplies.';
    }
    if (temp <= 5) {
      return 'Cold conditions. Check vulnerable crops and protect livestock from the cold.';
    }
    if (code == 0 && rain == 0) {
      return 'Dry, clear conditions. Fieldwork may be suitable; check soil moisture before irrigation.';
    }
    return 'Monitor local conditions before fieldwork and irrigation. Check soil moisture and crop needs.';
  }
}
