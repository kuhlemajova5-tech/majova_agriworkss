
class FarmWeather {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final int rainChance;
  final int weatherCode;
  final bool isDay;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  const FarmWeather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.rainChance,
    required this.weatherCode,
    required this.isDay,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  String get condition {
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode == 1) return 'Mainly clear';
    if (weatherCode == 2) return 'Partly cloudy';
    if (weatherCode == 3) return 'Overcast';

    if ([45, 48].contains(weatherCode)) {
      return 'Foggy';
    }

    if ([51, 53, 55, 56, 57].contains(weatherCode)) {
      return 'Drizzle';
    }

    if ([61, 63, 65, 66, 67, 80, 81, 82]
        .contains(weatherCode)) {
      return 'Rain';
    }

    if ([71, 73, 75, 77, 85, 86].contains(weatherCode)) {
      return 'Snow';
    }

    if ([95, 96, 99].contains(weatherCode)) {
      return 'Thunderstorm';
    }

    return 'Weather conditions unavailable';
  }

  String get windDirectionLabel {
    const directions = [
      'N', 'NE', 'E', 'SE',
      'S', 'SW', 'W', 'NW'
    ];

    final index = ((windDirection + 22.5) ~/ 45) % 8;
    return directions[index];
  }
}
