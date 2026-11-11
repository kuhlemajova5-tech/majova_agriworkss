import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/database_service.dart';
import '../../services/location_service.dart';

class FarmLocationScreen extends StatefulWidget {
  const FarmLocationScreen({super.key});

  @override
  State<FarmLocationScreen> createState() => _FarmLocationScreenState();
}

class _FarmLocationScreenState extends State<FarmLocationScreen> {
  static const Color _primaryGreen = Color(0xFF1B5E20);
  static const Color _darkGreen = Color(0xFF0B3D1B);
  static const Color _mediumGreen = Color(0xFF43A047);
  static const Color _background = Color(0xFFF4F7F4);
  static const Color _textPrimary = Color(0xFF17201A);
  static const Color _textSecondary = Color(0xFF66736A);

  Position? _position;

  bool _isLoadingLocation = false;
  bool _isSaving = false;
  bool _isLoadingSavedLocation = true;

  String? _errorMessage;

  double? _savedLatitude;
  double? _savedLongitude;
  double? _savedAccuracy;
  DateTime? _savedAt;

  @override
  void initState() {
    super.initState();
    _loadSavedFarmLocation();
  }

  Future<void> _loadSavedFarmLocation() async {
    try {
      final savedLocation =
      await DatabaseService.instance.getFarmLocation();

      if (!mounted) return;

      if (savedLocation == null) {
        setState(() {
          _isLoadingSavedLocation = false;
        });
        return;
      }

      final latitude = savedLocation['latitude'];
      final longitude = savedLocation['longitude'];
      final accuracy = savedLocation['accuracy'];
      final savedAt = savedLocation['saved_at'];

      setState(() {
        _savedLatitude =
        latitude is num ? latitude.toDouble() : null;

        _savedLongitude =
        longitude is num ? longitude.toDouble() : null;

        _savedAccuracy =
        accuracy is num ? accuracy.toDouble() : null;

        _savedAt = savedAt is String
            ? DateTime.tryParse(savedAt)
            : null;

        _isLoadingSavedLocation = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingSavedLocation = false;
        _errorMessage =
        'Could not load the saved farm location.';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      final position =
      await LocationService.getCurrentLocation();

      if (!mounted) return;

      setState(() {
        _position = position;
        _isLoadingLocation = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingLocation = false;
        _errorMessage = error
            .toString()
            .replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _saveFarmLocation() async {
    final position = _position;

    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please get your current location first.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await DatabaseService.instance.saveFarmLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );

      await _loadSavedFarmLocation();

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Farm location saved successfully.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _errorMessage =
        'Could not save the farm location.';
      });
    }
  }

  Future<void> _deleteSavedLocation() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Farm Location?',
          ),
          content: const Text(
            'This will remove the saved farm GPS location from this device.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await DatabaseService.instance.deleteFarmLocation();

      if (!mounted) return;

      setState(() {
        _savedLatitude = null;
        _savedLongitude = null;
        _savedAccuracy = null;
        _savedAt = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Saved farm location deleted.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
        'Could not delete the saved farm location.';
      });
    }
  }

  Future<void> _openLocationSettings() async {
    await LocationService.openLocationSettings();
  }

  Future<void> _openAppSettings() async {
    await LocationService.openAppSettings();
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Unknown';
    }

    final local = dateTime.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();

    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year at $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Farm Location',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _getCurrentLocation,
          color: _primaryGreen,
          child: SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              18,
              8,
              18,
              110,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                const SizedBox(height: 22),

                _buildStatusCard(),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 18),
                  _buildErrorCard(),
                ],

                const SizedBox(height: 24),

                _buildCoordinatesSection(),

                const SizedBox(height: 18),

                _buildAccuracyCard(),

                const SizedBox(height: 22),

                _buildActions(),

                const SizedBox(height: 28),

                _buildSavedLocationSection(),

                const SizedBox(height: 24),

                _buildFarmLocationInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _darkGreen,
            _primaryGreen,
            _mediumGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Farm GPS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Locate your farm and save its GPS position for offline use.',
                  style: TextStyle(
                    color: Color(0xFFD7EED9),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Icon(
            Icons.location_on_rounded,
            color: Colors.white,
            size: 58,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    String title;
    String subtitle;
    IconData icon;
    Color iconColor;
    Color iconBackground;

    if (_isLoadingLocation) {
      title = 'Locating Farm';
      subtitle =
      'Getting your current GPS position...';
      icon = Icons.gps_fixed_rounded;
      iconColor = const Color(0xFF1565C0);
      iconBackground = const Color(0xFFE3F2FD);
    } else if (_position != null) {
      title = 'GPS Location Found';
      subtitle =
      'Your current device location is ready.';
      icon = Icons.gps_fixed_rounded;
      iconColor = _primaryGreen;
      iconBackground = const Color(0xFFE8F5E9);
    } else {
      title = 'GPS Ready';
      subtitle =
      'Tap Get Current Location to locate your farm.';
      icon = Icons.gps_not_fixed_rounded;
      iconColor = const Color(0xFFF57C00);
      iconBackground = const Color(0xFFFFF3E0);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE3E9E4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _isLoadingLocation
                ? const Padding(
              padding: EdgeInsets.all(14),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF1565C0),
              ),
            )
                : Icon(
              icon,
              color: iconColor,
              size: 27,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current GPS Coordinates',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'These coordinates are obtained from your device.',
          style: TextStyle(
            color: _textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _coordinateCard(
                title: 'Latitude',
                value: _position == null
                    ? '--'
                    : _position!.latitude
                    .toStringAsFixed(6),
                icon: Icons.north_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _coordinateCard(
                title: 'Longitude',
                value: _position == null
                    ? '--'
                    : _position!.longitude
                    .toStringAsFixed(6),
                icon: Icons.east_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _coordinateCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3E9E4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: _primaryGreen,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyCard() {
    final accuracy = _position?.accuracy;

    String accuracyText = '--';
    String quality = 'Waiting for GPS';

    if (accuracy != null) {
      accuracyText =
      '${accuracy.toStringAsFixed(1)} m';

      if (accuracy <= 10) {
        quality = 'Excellent GPS accuracy';
      } else if (accuracy <= 30) {
        quality = 'Good GPS accuracy';
      } else if (accuracy <= 100) {
        quality = 'Moderate GPS accuracy';
      } else {
        quality = 'Low GPS accuracy';
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE3E9E4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: _primaryGreen,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'GPS Accuracy',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  accuracyText,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  quality,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            onPressed: _isLoadingLocation
                ? null
                : _getCurrentLocation,
            style: FilledButton.styleFrom(
              backgroundColor: _primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
            icon: _isLoadingLocation
                ? const SizedBox(
              width: 19,
              height: 19,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
                : const Icon(
              Icons.gps_fixed_rounded,
            ),
            label: Text(
              _position == null
                  ? 'Get Current Location'
                  : 'Refresh Current Location',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),

        const SizedBox(height: 11),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed:
            _position == null || _isSaving
                ? null
                : _saveFarmLocation,
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryGreen,
              side: const BorderSide(
                color: Color(0xFFA5D6A7),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
            icon: _isSaving
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Icon(
              Icons.save_outlined,
            ),
            label: Text(
              _isSaving
                  ? 'Saving Location...'
                  : 'Save Farm Location',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedLocationSection() {
    if (_isLoadingSavedLocation) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFE3E9E4),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: _primaryGreen,
          ),
        ),
      );
    }

    final hasSavedLocation =
        _savedLatitude != null &&
            _savedLongitude != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saved Farm Location',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Stored locally on this device for offline access.',
          style: TextStyle(
            color: _textSecondary,
            fontSize: 11,
          ),
        ),

        const SizedBox(height: 14),

        if (!hasSavedLocation)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFE3E9E4),
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.location_off_outlined,
                  color: _textSecondary,
                  size: 34,
                ),
                SizedBox(height: 10),
                Text(
                  'No farm location saved yet',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Get your GPS position and save it to the farm database.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFA5D6A7),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                        const Color(0xFFE8F5E9),
                        borderRadius:
                        BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: _primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 13),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Primary Farm Location',
                            style: TextStyle(
                              color: _textPrimary,
                              fontSize: 14,
                              fontWeight:
                              FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Available offline',
                            style: TextStyle(
                              color: _primaryGreen,
                              fontSize: 10.5,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: _primaryGreen,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _savedDetailRow(
                  'Latitude',
                  _savedLatitude!
                      .toStringAsFixed(6),
                ),

                const Divider(height: 22),

                _savedDetailRow(
                  'Longitude',
                  _savedLongitude!
                      .toStringAsFixed(6),
                ),

                const Divider(height: 22),

                _savedDetailRow(
                  'Accuracy',
                  _savedAccuracy == null
                      ? 'Unknown'
                      : '${_savedAccuracy!.toStringAsFixed(1)} m',
                ),

                const Divider(height: 22),

                _savedDetailRow(
                  'Saved',
                  _formatDateTime(_savedAt),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed:
                    _deleteSavedLocation,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                    ),
                    label: const Text(
                      'Delete Saved Location',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor:
                      Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _savedDetailRow(
      String label,
      String value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFCC80),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFEF6C00),
              ),
              SizedBox(width: 8),
              Text(
                'Location Problem',
                style: TextStyle(
                  color: Color(0xFFE65100),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            _errorMessage ??
                'Unable to access location.',
            style: const TextStyle(
              color: Color(0xFF7A4B00),
              fontSize: 11,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed:
                _openLocationSettings,
                icon: const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                ),
                label: const Text(
                  'Location Settings',
                ),
              ),
              OutlinedButton.icon(
                onPressed: _openAppSettings,
                icon: const Icon(
                  Icons.settings_outlined,
                  size: 18,
                ),
                label: const Text(
                  'App Settings',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFarmLocationInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.offline_bolt_outlined,
            color: _primaryGreen,
            size: 22,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Offline Farm Data',
                  style: TextStyle(
                    color: _darkGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Once saved, your farm location is stored locally using SQLite. It can be loaded again even after the app is restarted.',
                  style: TextStyle(
                    color: Color(0xFF3F6046),
                    fontSize: 10.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}