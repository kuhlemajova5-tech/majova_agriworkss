
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

const Color _primaryGreen = Color(0xFF1B5E20);
const Color _darkGreen = Color(0xFF0B3D1B);
const Color _mediumGreen = Color(0xFF43A047);
const Color _lightGreen = Color(0xFFE8F5E9);
const Color _background = Color(0xFFF4F7F4);
const Color _textPrimary = Color(0xFF17201A);
const Color _textSecondary = Color(0xFF66736A);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String farmerName = 'Farmer Account';
  String email = '';
  String phone = '';

  String farmName = 'Majova AgriWorks';
  String farmType = 'Mixed Farming';
  String farmSize = '';
  String crops = 'Cabbage, Spinach, Onions';
  String livestock = 'Sheep & Goats';
  String farmLocation = 'Location not set';

  File? profilePhoto;

  bool cropNotifications = true;
  bool taskNotifications = true;
  bool weatherNotifications = true;
  bool marketNotifications = false;

  bool syncEnabled = true;
  bool appLockEnabled = false;
  bool locationSharingEnabled = false;

  bool isGettingLocation = false;

  final ImagePicker _imagePicker = ImagePicker();

  void _message(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _pickProfilePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
      );

      if (image == null || !mounted) return;

      setState(() {
        profilePhoto = File(image.path);
      });

      _message('Profile photo updated.');
    } catch (e) {
      _message('Could not select a photo. Please try again.');
    }
  }

  Future<void> _editForm({
    required String title,
    required List<Map<String, String>> fields,
    required void Function(Map<String, String>) onSave,
  }) async {
    final controllers = <String, TextEditingController>{};

    for (final field in fields) {
      final key = field['key']!;
      controllers[key] = TextEditingController(
        text: field['value'] ?? '',
      );
    }

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: fields.map((field) {
                  final key = field['key']!;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: TextFormField(
                      controller: controllers[key],
                      textCapitalization:
                      TextCapitalization.sentences,
                      maxLines: field['multiline'] == 'true' ? 3 : 1,
                      keyboardType: field['keyboard'] == 'email'
                          ? TextInputType.emailAddress
                          : field['keyboard'] == 'phone'
                          ? TextInputType.phone
                          : TextInputType.text,
                      decoration: InputDecoration(
                        labelText: field['label'],
                        hintText: field['hint'],
                        filled: true,
                        fillColor: _background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: const BorderSide(
                            color: _primaryGreen,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (field['required'] == 'true' &&
                            (value == null || value.trim().isEmpty)) {
                          return '${field['label']} is required.';
                        }

                        return null;
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _primaryGreen,
            ),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              Navigator.pop(
                dialogContext,
                {
                  for (final entry in controllers.entries)
                    entry.key: entry.value.text.trim(),
                },
              );
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Changes'),
          ),
        ],
      ),
    );

    for (final controller in controllers.values) {
      controller.dispose();
    }

    if (result == null || !mounted) return;

    setState(() => onSave(result));
    _message('$title updated successfully.');
  }

  Future<void> _editProfile() async {
    await _editForm(
      title: 'Edit Profile',
      fields: [
        {
          'key': 'name',
          'label': 'Farmer Name',
          'value': farmerName == 'Farmer Account' ? '' : farmerName,
          'required': 'true',
        },
        {
          'key': 'email',
          'label': 'Email Address',
          'value': email,
          'keyboard': 'email',
        },
        {
          'key': 'phone',
          'label': 'Phone Number',
          'value': phone,
          'keyboard': 'phone',
        },
      ],
      onSave: (values) {
        farmerName = values['name']!;
        email = values['email']!;
        phone = values['phone']!;
      },
    );
  }

  Future<void> _editPersonalInformation() async {
    await _editForm(
      title: 'Personal Information',
      fields: [
        {
          'key': 'name',
          'label': 'Full Name',
          'value': farmerName == 'Farmer Account' ? '' : farmerName,
          'required': 'true',
        },
        {
          'key': 'email',
          'label': 'Email Address',
          'value': email,
          'keyboard': 'email',
        },
        {
          'key': 'phone',
          'label': 'Phone Number',
          'value': phone,
          'keyboard': 'phone',
        },
      ],
      onSave: (values) {
        farmerName = values['name']!;
        email = values['email']!;
        phone = values['phone']!;
      },
    );
  }

  Future<void> _editFarmDetails() async {
    await _editForm(
      title: 'Farm Details',
      fields: [
        {
          'key': 'farmName',
          'label': 'Farm Name',
          'value': farmName,
          'required': 'true',
        },
        {
          'key': 'farmType',
          'label': 'Farm Type',
          'value': farmType,
          'hint': 'e.g. Mixed Farming',
        },
        {
          'key': 'farmSize',
          'label': 'Farm Size',
          'value': farmSize,
          'hint': 'e.g. 5 hectares',
        },
        {
          'key': 'crops',
          'label': 'Main Crops',
          'value': crops,
          'hint': 'Cabbage, Spinach, Onions',
        },
        {
          'key': 'livestock',
          'label': 'Livestock',
          'value': livestock,
          'hint': 'Sheep, Goats, Cattle',
        },
      ],
      onSave: (values) {
        farmName = values['farmName']!;
        farmType = values['farmType']!;
        farmSize = values['farmSize']!;
        crops = values['crops']!;
        livestock = values['livestock']!;
      },
    );
  }

  Future<void> _getFarmLocation() async {
    if (isGettingLocation) return;

    setState(() => isGettingLocation = true);

    try {
      bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (mounted) {
          _message('Please switch on your phone location service.');
          await Geolocator.openLocationSettings();
        }
        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _message('Location permission was denied.');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _message(
          'Allow location access in your phone app settings.',
        );
        await Geolocator.openAppSettings();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 25));

      if (!mounted) return;

      setState(() {
        farmLocation =
        'Latitude: ${position.latitude.toStringAsFixed(5)}\n'
            'Longitude: ${position.longitude.toStringAsFixed(5)}';
      });

      _message('Current coordinates retrieved.');
    } catch (e) {
      _message(
        'Could not get your location. Check GPS and try again.',
      );
    } finally {
      if (mounted) {
        setState(() => isGettingLocation = false);
      }
    }
  }

  Future<void> _showFarmLocation() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Farm Location',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          '$farmLocation\n\n'
              'Use your phone GPS while you are at your farm '
              'to record its approximate coordinates.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: isGettingLocation
                ? null
                : () async {
              Navigator.pop(dialogContext);
              await _getFarmLocation();
            },
            style: FilledButton.styleFrom(
              backgroundColor: _primaryGreen,
            ),
            icon: const Icon(Icons.my_location),
            label: const Text('Get GPS Location'),
          ),
        ],
      ),
    );
  }

  Future<void> _showNotificationSettings() async {
    bool cropsValue = cropNotifications;
    bool tasksValue = taskNotifications;
    bool weatherValue = weatherNotifications;
    bool marketValue = marketNotifications;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Notification Settings',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _switchTile(
                'Crop reminders',
                'Planting and harvesting',
                cropsValue,
                    (value) => setDialogState(() => cropsValue = value),
              ),
              _switchTile(
                'Task reminders',
                'Upcoming farm activities',
                tasksValue,
                    (value) => setDialogState(() => tasksValue = value),
              ),
              _switchTile(
                'Weather alerts',
                'Weather-related farming updates',
                weatherValue,
                    (value) => setDialogState(() => weatherValue = value),
              ),
              _switchTile(
                'Market updates',
                'Sales and market activities',
                marketValue,
                    (value) => setDialogState(() => marketValue = value),
              ),
              const SizedBox(height: 8),
              const Text(
                'These preferences are currently kept in this '
                    'screen session. Push notifications require '
                    'additional notification integration.',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _primaryGreen,
              ),
              onPressed: () {
                setState(() {
                  cropNotifications = cropsValue;
                  taskNotifications = tasksValue;
                  weatherNotifications = weatherValue;
                  marketNotifications = marketValue;
                });
                Navigator.pop(dialogContext);
                _message('Notification preferences updated.');
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(
      String title,
      String subtitle,
      bool value,
      ValueChanged<bool> onChanged,
      ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      activeTrackColor: _mediumGreen,
      title: Text(
        title,
        style: const TextStyle(
          color: _textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  Future<void> _showSyncSettings() async {
    bool enabled = syncEnabled;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Data & Synchronisation',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.cloud_sync_outlined,
                color: _primaryGreen,
                size: 42,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your app can manage farm records locally. '
                    'Cloud synchronisation is not connected yet.',
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable sync preference'),
                subtitle: const Text(
                  'Save your preference for this session',
                ),
                value: enabled,
                onChanged: (value) {
                  setDialogState(() => enabled = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _primaryGreen,
              ),
              onPressed: () {
                setState(() => syncEnabled = enabled);
                Navigator.pop(dialogContext);
                _message(
                  'Sync preference updated. Cloud sync still '
                      'requires a database connection.',
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPrivacySettings() async {
    bool lockEnabled = appLockEnabled;
    bool locationEnabled = locationSharingEnabled;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Privacy & Security',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 42,
                color: _primaryGreen,
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('App lock preference'),
                subtitle: const Text(
                  'Preference only; a real lock is not implemented',
                ),
                value: lockEnabled,
                onChanged: (value) {
                  setDialogState(() => lockEnabled = value);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Location sharing preference'),
                subtitle: const Text(
                  'Choose whether you intend to share farm location',
                ),
                value: locationEnabled,
                onChanged: (value) {
                  setDialogState(() => locationEnabled = value);
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'These settings do not change Android permissions '
                    'or activate app locking. Those features need '
                    'separate implementation.',
                style: TextStyle(
                  fontSize: 12,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _primaryGreen,
              ),
              onPressed: () {
                setState(() {
                  appLockEnabled = lockEnabled;
                  locationSharingEnabled = locationEnabled;
                });
                Navigator.pop(dialogContext);
                _message('Privacy preferences updated.');
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showHelpCentre() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Majova AgriWorks Help Centre',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _HelpItem(
                title: 'Profile',
                description:
                'Edit your personal details and choose a profile photo.',
              ),
              _HelpItem(
                title: 'Farm Details',
                description:
                'Record your farm name, size, crops and livestock.',
              ),
              _HelpItem(
                title: 'Farm Location',
                description:
                'Enable GPS on your phone and grant location permission.',
              ),
              _HelpItem(
                title: 'Weather',
                description:
                'Live weather needs an internet connection and a '
                    'configured weather API key.',
              ),
              _HelpItem(
                title: 'Farm Records',
                description:
                'Use the crop, livestock, inventory and task sections '
                    'to manage farm activities.',
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _primaryGreen,
            ),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Log Out?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Are you sure you want to leave your current screen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.logout),
            label: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Returns to the first route in the current navigation stack.
    // Connect this to your authentication logout method when available.
    Navigator.of(context).popUntil((route) => route.isFirst);

    _message(
      'Returned to the first app screen. '
          'Authentication logout must be connected separately.',
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Majova AgriWorks',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.agriculture,
        color: _primaryGreen,
        size: 40,
      ),
      applicationLegalese: 'Smart Farm Management',
      children: const [
        Text(
          'A farm-management application designed to help farmers '
              'manage crops, livestock, machinery, tasks and farm records.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Farmer Profile',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 26),
              _buildStatistics(),
              const SizedBox(height: 30),
              _sectionTitle('Farm Information'),
              const SizedBox(height: 14),
              _buildFarmInformation(),
              const SizedBox(height: 30),
              _sectionTitle('Account & Farm'),
              const SizedBox(height: 12),
              _buildMenuSection([
                _ProfileMenuItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal Information',
                  subtitle: 'Manage your farmer profile',
                  onTap: _editPersonalInformation,
                ),
                _ProfileMenuItem(
                  icon: Icons.agriculture_outlined,
                  title: 'Farm Details',
                  subtitle: 'Edit farm information',
                  onTap: _editFarmDetails,
                ),
                _ProfileMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Farm Location',
                  subtitle: 'View and retrieve GPS coordinates',
                  onTap: _showFarmLocation,
                ),
              ]),
              const SizedBox(height: 28),
              _sectionTitle('Application Settings'),
              const SizedBox(height: 12),
              _buildMenuSection([
                _ProfileMenuItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  subtitle: 'Manage farm reminder preferences',
                  onTap: _showNotificationSettings,
                ),
                _ProfileMenuItem(
                  icon: Icons.cloud_outlined,
                  title: 'Data & Synchronisation',
                  subtitle: 'View sync preferences and status',
                  onTap: _showSyncSettings,
                ),
                _ProfileMenuItem(
                  icon: Icons.security_outlined,
                  title: 'Privacy & Security',
                  subtitle: 'Manage privacy preferences',
                  onTap: _showPrivacySettings,
                ),
              ]),
              const SizedBox(height: 28),
              _sectionTitle('Support'),
              const SizedBox(height: 12),
              _buildMenuSection([
                _ProfileMenuItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Help Centre',
                  subtitle: 'Learn how to use Majova AgriWorks',
                  onTap: _showHelpCentre,
                ),
                _ProfileMenuItem(
                  icon: Icons.info_outline_rounded,
                  title: 'About Majova AgriWorks',
                  subtitle: 'Application information',
                  onTap: _showAboutDialog,
                ),
              ]),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _showLogoutDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFC62828),
                    side: const BorderSide(
                      color: Color(0xFFFFCDD2),
                    ),
                    backgroundColor: const Color(0xFFFFF5F5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Majova AgriWorks',
                      style: TextStyle(
                        color: _primaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Smart Farm Management',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Color(0xFF9AA49C),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _textPrimary,
        fontSize: 19,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildProfileHeader() {
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
        children: [
          Stack(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.30),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: profilePhoto != null
                      ? Image.file(
                    profilePhoto!,
                    fit: BoxFit.cover,
                    width: 92,
                    height: 92,
                    errorBuilder: (_, __, ___) =>
                    const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 52,
                    ),
                  )
                      : const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'Change profile photo',
                    onPressed: _pickProfilePhoto,
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      color: _primaryGreen,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            farmerName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            farmName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD7EED9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _editProfile,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
            ),
            icon: const Icon(Icons.edit_outlined, size: 17),
            label: const Text(
              'Edit Profile',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(
          child: _statisticCard(
            value: '3',
            label: 'Crops',
            icon: Icons.eco_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statisticCard(
            value: '42',
            label: 'Livestock',
            icon: Icons.pets_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statisticCard(
            value: '2',
            label: 'Tractors',
            icon: Icons.agriculture_outlined,
          ),
        ),
      ],
    );
  }

  Widget _statisticCard({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E9E4)),
      ),
      child: Column(
        children: [
          Icon(icon, color: _primaryGreen, size: 23),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE3E9E4)),
      ),
      child: Column(
        children: [
          _informationRow(
            Icons.storefront_outlined,
            'Farm',
            farmName,
          ),
          const Divider(height: 28, color: Color(0xFFE8ECE9)),
          _informationRow(
            Icons.category_outlined,
            'Farm Type',
            farmType,
          ),
          const Divider(height: 28, color: Color(0xFFE8ECE9)),
          _informationRow(
            Icons.eco_outlined,
            'Main Crops',
            crops,
          ),
          const Divider(height: 28, color: Color(0xFFE8ECE9)),
          _informationRow(
            Icons.pets_outlined,
            'Livestock',
            livestock,
          ),
          if (farmSize.isNotEmpty) ...[
            const Divider(height: 28, color: Color(0xFFE8ECE9)),
            _informationRow(
              Icons.landscape_outlined,
              'Farm Size',
              farmSize,
            ),
          ],
        ],
      ),
    );
  }

  Widget _informationRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: _lightGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _primaryGreen, size: 20),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value.isEmpty ? 'Not provided' : value,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(List<_ProfileMenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE3E9E4)),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];

          return Column(
            children: [
              ListTile(
                onTap: item.onTap,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),
                leading: Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: _lightGreen,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    item.icon,
                    color: _primaryGreen,
                    size: 22,
                  ),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 11,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF98A19A),
                  size: 15,
                ),
              ),
              if (index != items.length - 1)
                const Divider(
                  height: 1,
                  indent: 72,
                  color: Color(0xFFE8ECE9),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _ProfileMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _HelpItem extends StatelessWidget {
  final String title;
  final String description;

  const _HelpItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _primaryGreen,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(height: 1.4),
          ),
        ],
      ),
    );
  }
}
