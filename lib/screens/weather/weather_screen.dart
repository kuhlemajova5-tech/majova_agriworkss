import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import '../../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  static const Color _primaryGreen = Color(0xFF1B5E20);
  static const Color _darkGreen = Color(0xFF0B3D1B);
  static const Color _mediumGreen = Color(0xFF43A047);
  static const Color _background = Color(0xFFF4F7F4);
  static const Color _textPrimary = Color(0xFF17201A);
  static const Color _textSecondary = Color(0xFF66736A);

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _current;
  Map<String, dynamic>? _forecast;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadLiveWeather();
  }

  Future<void> _loadLiveWeather() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final Position position =
      await LocationService.getCurrentLocation();

      final results = await Future.wait([
        WeatherService.instance.getCurrentWeather(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
        WeatherService.instance.getForecast(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      ]);

      if (!mounted) return;

      setState(() {
        _current = results[0];
        _forecast = results[1];
        _lastUpdated = DateTime.now();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = _friendlyError(error);
      });
    }
  }

  String _friendlyError(Object error) {
    final text = error.toString().replaceFirst('Exception: ', '');

    if (text.contains('API key')) {
      return text;
    }

    if (text.toLowerCase().contains('location')) {
      return text;
    }

    return 'Could not load live weather. Check your internet connection, GPS and API key, then try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Farm Weather',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh live weather',
            onPressed: _isLoading ? null : _loadLiveWeather,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _current == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: _primaryGreen,
        ),
      );
    }

    if (_errorMessage != null && _current == null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      color: _primaryGreen,
      onRefresh: _loadLiveWeather,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null) ...[
              _buildInlineError(),
              const SizedBox(height: 14),
            ],
            _buildCurrentWeather(),
            const SizedBox(height: 22),
            _buildWeatherDetails(),
            const SizedBox(height: 30),
            _sectionTitle(
              'Today\'s Forecast',
              'Live 3-hour forecast for farm planning.',
            ),
            const SizedBox(height: 14),
            _buildHourlyForecast(),
            const SizedBox(height: 30),
            _sectionTitle(
              '5-Day Forecast',
              'Upcoming conditions for farm planning.',
            ),
            const SizedBox(height: 14),
            _buildFiveDayForecast(),
            const SizedBox(height: 30),
            _sectionTitle(
              'Smart Farming Advice',
              'Recommendations based on the live conditions.',
            ),
            const SizedBox(height: 14),
            ..._buildAdviceCards(),
            const SizedBox(height: 18),
            _buildRainfallCard(),
            const SizedBox(height: 22),
            _buildLiveNotice(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 70,
              color: _primaryGreen,
            ),
            const SizedBox(height: 18),
            const Text(
              'Live weather unavailable',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textPrimary,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? 'Could not load weather.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _loadLiveWeather,
              style: FilledButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather() {
    final current = _current ?? {};
    final main = _map(current['main']);
    final weather = _firstMap(current['weather']);
    final temp = _double(main['temp']);
    final feels = _double(main['feels_like']);
    final locationName = _string(current['name'], fallback: 'Farm Location');
    final condition = _titleCase(
      _string(weather['description'], fallback: 'Weather unavailable'),
    );

    final today = _todayForecasts();
    final temperatures = today
        .map((item) => _double(_map(item['main'])['temp']))
        .toList();

    final high = temperatures.isEmpty
        ? _double(main['temp_max'])
        : temperatures.reduce((a, b) => a > b ? a : b);
    final low = temperatures.isEmpty
        ? _double(main['temp_min'])
        : temperatures.reduce((a, b) => a < b ? a : b);
    final rainChance = _maxRainChance(today);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_darkGreen, _primaryGreen, _mediumGreen],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  locationName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${temp.round()}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      condition,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Feels like ${feels.round()}°C',
                      style: const TextStyle(
                        color: Color(0xFFD7EED9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                _weatherIcon(_string(weather['main'])),
                color: _weatherIconColor(_string(weather['main'])),
                size: 82,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _WeatherHeaderValue(
                  label: 'High',
                  value: '${high.round()}°C',
                ),
              ),
              Expanded(
                child: _WeatherHeaderValue(
                  label: 'Low',
                  value: '${low.round()}°C',
                ),
              ),
              Expanded(
                child: _WeatherHeaderValue(
                  label: 'Rain',
                  value: '$rainChance%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetails() {
    final current = _current ?? {};
    final main = _map(current['main']);
    final wind = _map(current['wind']);
    final clouds = _map(current['clouds']);
    final rain = _map(current['rain']);

    final humidity = _int(main['humidity']);
    final windKmh = _double(wind['speed']) * 3.6;
    final rainfall = _double(rain['1h']);
    final cloudCover = _int(clouds['all']);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.65,
      children: [
        _weatherDetailCard(
          icon: Icons.water_drop_outlined,
          label: 'Humidity',
          value: '$humidity%',
        ),
        _weatherDetailCard(
          icon: Icons.air_rounded,
          label: 'Wind',
          value: '${windKmh.toStringAsFixed(1)} km/h',
        ),
        _weatherDetailCard(
          icon: Icons.umbrella_outlined,
          label: 'Rainfall',
          value: '${rainfall.toStringAsFixed(1)} mm',
        ),
        _weatherDetailCard(
          icon: Icons.cloud_outlined,
          label: 'Cloud Cover',
          value: '$cloudCover%',
        ),
      ],
    );
  }

  Widget _weatherDetailCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E9E4)),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: _primaryGreen, size: 22),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyForecast() {
    final items = _forecastList().take(6).toList();

    if (items.isEmpty) {
      return _emptyForecast('Hourly forecast unavailable.');
    }

    return SizedBox(
      height: 128,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          final date = _forecastDate(item);
          final main = _map(item['main']);
          final weather = _firstMap(item['weather']);
          final temp = _double(main['temp']);

          return Container(
            width: 82,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: index == 0
                  ? const Color(0xFFE8F5E9)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: index == 0
                    ? const Color(0xFFA5D6A7)
                    : const Color(0xFFE3E9E4),
              ),
            ),
            child: Column(
              children: [
                Text(
                  index == 0 ? 'Next' : _formatTime(date),
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 9),
                Icon(
                  _weatherIcon(_string(weather['main'])),
                  color: _weatherIconColor(_string(weather['main'])),
                  size: 26,
                ),
                const Spacer(),
                Text(
                  '${temp.round()}°',
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFiveDayForecast() {
    final days = _dailyForecasts();

    if (days.isEmpty) {
      return _emptyForecast('5-day forecast unavailable.');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE3E9E4)),
      ),
      child: Column(
        children: List.generate(days.length, (index) {
          final day = days[index];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 82,
                      child: Text(
                        day.label,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Icon(
                      _weatherIcon(day.conditionCode),
                      color: _weatherIconColor(day.conditionCode),
                      size: 25,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day.condition,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.water_drop_outlined,
                                color: Color(0xFF1976D2),
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${day.rainChance}%',
                                style: const TextStyle(
                                  color: _textSecondary,
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${day.high.round()}°',
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${day.low.round()}°',
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (index != days.length - 1)
                const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Color(0xFFE8ECE9),
                ),
            ],
          );
        }),
      ),
    );
  }

  List<Widget> _buildAdviceCards() {
    final current = _current ?? {};
    final main = _map(current['main']);
    final wind = _map(current['wind']);
    final weather = _firstMap(current['weather']);

    final temp = _double(main['temp']);
    final humidity = _int(main['humidity']);
    final windKmh = _double(wind['speed']) * 3.6;
    final condition = _string(weather['main']).toLowerCase();
    final todayRain = _maxRainChance(_todayForecasts());

    final bool wet = condition.contains('rain') ||
        condition.contains('drizzle') ||
        condition.contains('thunderstorm') ||
        todayRain >= 60;
    final bool windy = windKmh >= 35;
    final bool hot = temp >= 30;

    final fieldStatus = wet || windy ? 'Caution' : 'Good';
    final fieldDescription = wet
        ? 'Rain is likely or occurring. Avoid unnecessary spraying and heavy field traffic.'
        : windy
        ? 'Wind is strong. Delay spraying and secure loose farm equipment.'
        : 'Conditions are suitable for routine field inspections and general farm work.';

    final irrigationStatus = wet || todayRain >= 50 ? 'Delay' : 'Monitor';
    final irrigationDescription = wet || todayRain >= 50
        ? 'Rain is likely. Check soil moisture before irrigating to avoid unnecessary watering.'
        : 'No strong rain signal is showing. Check soil moisture and irrigate only where needed.';

    final livestockStatus = hot ? 'Heat Alert' : 'Normal';
    final livestockDescription = hot
        ? 'Warm conditions detected. Ensure sheep and goats have shade and plenty of clean drinking water.'
        : 'Continue normal livestock checks and ensure clean water and suitable shelter are available.';

    final cropDescription = humidity >= 80
        ? 'High humidity can favour some crop diseases. Inspect cabbage, spinach and onions closely.'
        : 'Inspect cabbage, spinach and onions for moisture stress, pests and signs of disease.';

    return [
      _buildAdviceCard(
        icon: Icons.agriculture_rounded,
        title: 'Field Work',
        description: fieldDescription,
        status: fieldStatus,
        statusColor: fieldStatus == 'Good'
            ? const Color(0xFF2E7D32)
            : Colors.orange.shade800,
        statusBackground: fieldStatus == 'Good'
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFF3E0),
      ),
      const SizedBox(height: 12),
      _buildAdviceCard(
        icon: Icons.water_drop_rounded,
        title: 'Irrigation',
        description: irrigationDescription,
        status: irrigationStatus,
        statusColor: const Color(0xFF1565C0),
        statusBackground: const Color(0xFFE3F2FD),
      ),
      const SizedBox(height: 12),
      _buildAdviceCard(
        icon: Icons.eco_rounded,
        title: 'Crop Care',
        description: cropDescription,
        status: 'Inspect',
        statusColor: const Color(0xFF2E7D32),
        statusBackground: const Color(0xFFE8F5E9),
      ),
      const SizedBox(height: 12),
      _buildAdviceCard(
        icon: Icons.pets_rounded,
        title: 'Livestock',
        description: livestockDescription,
        status: livestockStatus,
        statusColor:
        hot ? Colors.deepOrange.shade700 : const Color(0xFF6A1B9A),
        statusBackground:
        hot ? const Color(0xFFFBE9E7) : const Color(0xFFF3E5F5),
      ),
    ];
  }

  Widget _buildAdviceCard({
    required IconData icon,
    required String title,
    required String description,
    required String status,
    required Color statusColor,
    required Color statusBackground,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E9E4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: _primaryGreen, size: 24),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 11.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRainfallCard() {
    final days = _dailyForecasts();
    final maxRain = days.isEmpty
        ? 0
        : days.map((e) => e.rainChance).reduce((a, b) => a > b ? a : b);

    final message = maxRain >= 60
        ? 'Rain is likely during the forecast period. Review irrigation, spraying and field-work plans.'
        : maxRain >= 30
        ? 'There is some chance of rain in the forecast. Check the forecast again before irrigation or spraying.'
        : 'Rain chances are currently low. Monitor soil moisture and plan irrigation according to crop needs.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBBDEFB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xFFBBDEFB),
            child: Icon(
              Icons.water_drop_rounded,
              color: Color(0xFF1565C0),
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rainfall Outlook',
                  style: TextStyle(
                    color: Color(0xFF0D47A1),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF315E86),
                    fontSize: 11.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveNotice() {
    final updated = _lastUpdated;
    final text = updated == null
        ? 'Live weather is provided using your device location.'
        : 'Live weather updated at ${_formatTime(updated)}. Pull down or tap refresh to update again.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.cloud_done_outlined,
            color: _primaryGreen,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _darkGreen,
                fontSize: 10.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyForecast(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E9E4)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: _textSecondary),
      ),
    );
  }

  List<Map<String, dynamic>> _forecastList() {
    final raw = _forecast?['list'];
    if (raw is! List) return [];

    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  List<Map<String, dynamic>> _todayForecasts() {
    final now = DateTime.now();

    return _forecastList().where((item) {
      final date = _forecastDate(item);
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).toList();
  }

  List<_DailyWeather> _dailyForecasts() {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final item in _forecastList()) {
      final date = _forecastDate(item);
      final key = '${date.year}-${date.month}-${date.day}';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final result = <_DailyWeather>[];
    final entries = grouped.entries.take(5).toList();

    for (int index = 0; index < entries.length; index++) {
      final items = entries[index].value;
      if (items.isEmpty) continue;

      double high = -100;
      double low = 100;
      int rainChance = 0;

      Map<String, dynamic> representative = items.first;
      int smallestNoonDifference = 24;

      for (final item in items) {
        final main = _map(item['main']);
        final tempMax = _double(main['temp_max']);
        final tempMin = _double(main['temp_min']);
        if (tempMax > high) high = tempMax;
        if (tempMin < low) low = tempMin;

        final pop = (_double(item['pop']) * 100).round();
        if (pop > rainChance) rainChance = pop;

        final hour = _forecastDate(item).hour;
        final difference = (hour - 12).abs();
        if (difference < smallestNoonDifference) {
          smallestNoonDifference = difference;
          representative = item;
        }
      }

      final date = _forecastDate(representative);
      final weather = _firstMap(representative['weather']);

      result.add(
        _DailyWeather(
          label: index == 0 ? 'Today' : _weekday(date.weekday),
          condition: _titleCase(
            _string(weather['description'], fallback: 'Unknown'),
          ),
          conditionCode: _string(weather['main']),
          high: high,
          low: low,
          rainChance: rainChance,
        ),
      );
    }

    return result;
  }

  int _maxRainChance(List<Map<String, dynamic>> items) {
    int max = 0;
    for (final item in items) {
      final chance = (_double(item['pop']) * 100).round();
      if (chance > max) max = chance;
    }
    return max;
  }

  DateTime _forecastDate(Map<String, dynamic> item) {
    final seconds = _int(item['dt']);
    return DateTime.fromMillisecondsSinceEpoch(
      seconds * 1000,
      isUtc: true,
    ).toLocal();
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  Map<String, dynamic> _firstMap(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return _map(value.first);
    }
    return {};
  }

  double _double(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _string(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _weekday(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value
        .split(' ')
        .map(
          (word) => word.isEmpty
          ? word
          : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
    )
        .join(' ');
  }

  IconData _weatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'clouds':
        return Icons.cloud_rounded;
      case 'rain':
      case 'drizzle':
        return Icons.grain_rounded;
      case 'thunderstorm':
        return Icons.thunderstorm_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'mist':
      case 'fog':
      case 'haze':
        return Icons.foggy;
      default:
        return Icons.cloud_outlined;
    }
  }

  Color _weatherIconColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return const Color(0xFFFFD54F);
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return const Color(0xFF90CAF9);
      case 'clouds':
      case 'mist':
      case 'fog':
      case 'haze':
        return const Color(0xFFCFD8DC);
      default:
        return const Color(0xFFFFD54F);
    }
  }
}

class _WeatherHeaderValue extends StatelessWidget {
  final String label;
  final String value;

  const _WeatherHeaderValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _DailyWeather {
  final String label;
  final String condition;
  final String conditionCode;
  final double high;
  final double low;
  final int rainChance;

  const _DailyWeather({
    required this.label,
    required this.condition,
    required this.conditionCode,
    required this.high,
    required this.low,
    required this.rainChance,
  });
}