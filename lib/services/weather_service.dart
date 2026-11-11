
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Provides weather data in the format expected by WeatherScreen.
class WeatherService {
  WeatherService._();

  static final WeatherService instance = WeatherService._();

  static const String _baseUrl =
      'https://api.open-meteo.com/v1/forecast';

  Future<Map<String, dynamic>> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': [
          'temperature_2m',
          'relative_humidity_2m',
          'apparent_temperature',
          'is_day',
          'precipitation',
          'rain',
          'weather_code',
          'cloud_cover',
          'wind_speed_10m',
        ].join(','),
        'daily': 'temperature_2m_max,temperature_2m_min',
        'timezone': 'auto',
        'forecast_days': '1',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Could not retrieve current weather (${response.statusCode}).',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final current = Map<String, dynamic>.from(data['current'] ?? {});
    final daily = Map<String, dynamic>.from(data['daily'] ?? {});

    final code = _number(current['weather_code']).toInt();
    final temperature = _number(current['temperature_2m']);
    final maxList = daily['temperature_2m_max'] as List? ?? [];
    final minList = daily['temperature_2m_min'] as List? ?? [];

    final weather = _weatherDescription(code);

    return {
      'name': 'Farm Location',
      'main': {
        'temp': temperature,
        'feels_like': _number(current['apparent_temperature']),
        'temp_max': maxList.isNotEmpty
            ? _number(maxList.first)
            : temperature,
        'temp_min': minList.isNotEmpty
            ? _number(minList.first)
            : temperature,
        'humidity': _number(current['relative_humidity_2m']).toInt(),
      },
      'weather': [
        {
          'main': weather['main'],
          'description': weather['description'],
        }
      ],
      'wind': {
        // Open-Meteo reports km/h; the screen multiplies by 3.6.
        // Convert to m/s here so the displayed wind speed is correct.
        'speed': _number(current['wind_speed_10m']) / 3.6,
      },
      'clouds': {
        'all': _number(current['cloud_cover']).toInt(),
      },
      'rain': {
        '1h': _number(current['rain']),
      },
      'weather_code': code,
    };
  }

  Future<Map<String, dynamic>> getForecast({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'hourly': [
          'temperature_2m',
          'relative_humidity_2m',
          'apparent_temperature',
          'precipitation_probability',
          'precipitation',
          'rain',
          'weather_code',
          'cloud_cover',
          'wind_speed_10m',
        ].join(','),
        'timezone': 'auto',
        'forecast_days': '5',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Could not retrieve forecast (${response.statusCode}).',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final hourly = Map<String, dynamic>.from(data['hourly'] ?? {});

    final times = hourly['time'] as List? ?? [];
    final temperatures = hourly['temperature_2m'] as List? ?? [];
    final humidity = hourly['relative_humidity_2m'] as List? ?? [];
    final feelsLike = hourly['apparent_temperature'] as List? ?? [];
    final probabilities =
        hourly['precipitation_probability'] as List? ?? [];
    final precipitation = hourly['precipitation'] as List? ?? [];
    final rain = hourly['rain'] as List? ?? [];
    final codes = hourly['weather_code'] as List? ?? [];
    final clouds = hourly['cloud_cover'] as List? ?? [];
    final winds = hourly['wind_speed_10m'] as List? ?? [];

    final count = [
      times.length,
      temperatures.length,
      humidity.length,
      feelsLike.length,
      probabilities.length,
      precipitation.length,
      rain.length,
      codes.length,
      clouds.length,
      winds.length,
    ].reduce((a, b) => a < b ? a : b);

    final now = DateTime.now();

    // Keep forecast points at three-hour intervals, starting
    // with the next available interval.
    final firstIndex = times.indexWhere((value) {
      final date = DateTime.tryParse(value.toString());
      return date != null && date.isAfter(now);
    });

    final start = firstIndex < 0 ? 0 : firstIndex;
    final list = <Map<String, dynamic>>[];

    for (int i = start; i < count; i += 3) {
      final date = DateTime.tryParse(times[i].toString());
      if (date == null) continue;

      final code = _number(codes[i]).toInt();
      final description = _weatherDescription(code);

      list.add({
        'dt': date.toUtc().millisecondsSinceEpoch ~/ 1000,
        'main': {
          'temp': _number(temperatures[i]),
          'temp_max': _number(temperatures[i]),
          'temp_min': _number(temperatures[i]),
          'feels_like': _number(feelsLike[i]),
          'humidity': _number(humidity[i]).toInt(),
        },
        'weather': [
          {
            'main': description['main'],
            'description': description['description'],
          }
        ],
        'pop': _number(probabilities[i]) / 100,
        'rain': {
          '1h': _number(rain[i]),
        },
        'precipitation': _number(precipitation[i]),
        'wind': {
          'speed': _number(winds[i]) / 3.6,
        },
        'clouds': {
          'all': _number(clouds[i]).toInt(),
        },
      });
    }

    return {'list': list};
  }

  static double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static Map<String, String> _weatherDescription(int code) {
    if (code == 0) {
      return {'main': 'Clear', 'description': 'clear sky'};
    }

    if (code == 1 || code == 2) {
      return {'main': 'Clouds', 'description': 'partly cloudy'};
    }

    if (code == 3) {
      return {'main': 'Clouds', 'description': 'overcast'};
    }

    if (code == 45 || code == 48) {
      return {'main': 'Fog', 'description': 'foggy'};
    }

    if (code >= 51 && code <= 57) {
      return {'main': 'Drizzle', 'description': 'drizzle'};
    }

    if (code >= 61 && code <= 67) {
      return {'main': 'Rain', 'description': 'rain'};
    }

    if (code >= 71 && code <= 77) {
      return {'main': 'Snow', 'description': 'snow'};
    }

    if (code >= 80 && code <= 82) {
      return {'main': 'Rain', 'description': 'rain showers'};
    }

    if (code == 85 || code == 86) {
      return {'main': 'Snow', 'description': 'snow showers'};
    }

    if (code >= 95) {
      return {
        'main': 'Thunderstorm',
        'description': 'thunderstorm',
      };
    }

    return {'main': 'Clouds', 'description': 'variable conditions'};
  }
}

/// Compatibility model for the dashboard weather card.
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

/// Compatibility service for the dashboard weather card.
class FarmWeatherService {
  final WeatherService _service = WeatherService.instance;

  Future<FarmWeather> getCurrentWeather() async {
    final position = await _getPosition();
    final data = await _service.getCurrentWeather(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    final main = Map<String, dynamic>.from(data['main'] as Map);
    final wind = Map<String, dynamic>.from(data['wind'] as Map);
    final rain = Map<String, dynamic>.from(data['rain'] as Map);
    final weather = Map<String, dynamic>.from(
      (data['weather'] as List).first as Map,
    );

    final temp = WeatherService._number(main['temp']);
    final humidity = WeatherService._number(main['humidity']).toInt();
    final windSpeed = WeatherService._number(wind['speed']) * 3.6;
    final condition = weather['description']?.toString() ?? 'Unknown';

    return FarmWeather(
      location: data['name']?.toString() ?? 'Farm Location',
      temperature: temp,
      feelsLike: WeatherService._number(main['feels_like']),
      condition: condition,
      weatherCode: WeatherService._number(data['weather_code']).toInt(),
      humidity: humidity,
      windSpeed: windSpeed,
      rainfall: WeatherService._number(rain['1h']),
      farmingAdvice: _farmingAdvice(temp, humidity, windSpeed),
    );
  }

  Future<Position> _getPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is required for live weather.');
    }

    return Geolocator.getCurrentPosition();
  }

  String _farmingAdvice(double temp, int humidity, double windSpeed) {
    if (temp >= 30) {
      return 'Hot conditions: provide livestock with shade and clean water.';
    }

    if (windSpeed >= 35) {
      return 'Windy conditions: consider delaying spraying and secure equipment.';
    }

    if (humidity >= 80) {
      return 'High humidity: inspect crops for signs of fungal disease.';
    }

    return 'Check soil moisture and monitor local conditions before field work.';
  }
}
