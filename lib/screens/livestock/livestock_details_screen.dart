import 'package:flutter/material.dart';

import '../../models/livestock.dart';

class LivestockDetailsScreen extends StatelessWidget {
  final Livestock livestock;

  const LivestockDetailsScreen({
    super.key,
    required this.livestock,
  });

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Not recorded';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F4),
        elevation: 0,
        title: const Text(
          'Livestock Details',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF17201A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),

            const SizedBox(height: 25),

            const Text(
              'Animal Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17201A),
              ),
            ),

            const SizedBox(height: 14),

            _buildInformationCard(
              children: [
                _buildInformationRow(
                  icon: Icons.pets_outlined,
                  title: 'Animal Type',
                  value: livestock.animalType,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.category_outlined,
                  title: 'Record Type',
                  value: livestock.recordType,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.badge_outlined,
                  title: livestock.recordType == 'Individual'
                      ? 'Identification'
                      : 'Group Name',
                  value: livestock.identification,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.account_tree_outlined,
                  title: 'Breed',
                  value: livestock.breed,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.wc_rounded,
                  title: 'Gender',
                  value: livestock.gender,
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              'Farm Record',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17201A),
              ),
            ),

            const SizedBox(height: 14),

            _buildInformationCard(
              children: [
                _buildInformationRow(
                  icon: Icons.numbers_rounded,
                  title: 'Quantity',
                  value: livestock.quantityText,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.monitor_weight_outlined,
                  title: livestock.recordType == 'Individual'
                      ? 'Weight'
                      : 'Average Weight',
                  value: livestock.weightText,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.calendar_month_outlined,
                  title: livestock.recordType == 'Individual'
                      ? 'Date of Birth'
                      : 'Group Start / Birth Date',
                  value: _formatDate(
                    livestock.dateOfBirth,
                  ),
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.location_on_outlined,
                  title: 'Farm Location',
                  value: livestock.location,
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              'Health',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17201A),
              ),
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE3E9E4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _healthBackgroundColor(),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      _healthIcon(),
                      color: _healthTextColor(),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Health Status',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF66736A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          livestock.healthStatus,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _healthTextColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17201A),
              ),
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE3E9E4),
                ),
              ),
              child: Text(
                livestock.notes.trim().isEmpty
                    ? 'No additional notes recorded.'
                    : livestock.notes,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Color(0xFF66736A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B3D1B),
            Color(0xFF1B5E20),
            Color(0xFF43A047),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              _animalIcon(),
              color: Colors.white,
              size: 40,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            livestock.displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            '${livestock.animalType} • ${livestock.breed}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              livestock.recordType,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3E9E4),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInformationRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            size: 21,
            color: const Color(0xFF1B5E20),
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF66736A),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF17201A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        height: 1,
      ),
    );
  }

  IconData _animalIcon() {
    switch (livestock.animalType) {
      case 'Poultry':
        return Icons.egg_alt_outlined;

      case 'Rabbits':
        return Icons.cruelty_free_outlined;

      case 'Other':
        return Icons.more_horiz_rounded;

      default:
        return Icons.pets_rounded;
    }
  }

  Color _healthBackgroundColor() {
    if (livestock.healthStatus == 'Healthy') {
      return const Color(0xFFE8F5E9);
    }

    if (livestock.healthStatus == 'Recovering') {
      return const Color(0xFFFFF8E1);
    }

    return const Color(0xFFFFEBEE);
  }

  Color _healthTextColor() {
    if (livestock.healthStatus == 'Healthy') {
      return const Color(0xFF1B5E20);
    }

    if (livestock.healthStatus == 'Recovering') {
      return const Color(0xFFF57F17);
    }

    return const Color(0xFFC62828);
  }

  IconData _healthIcon() {
    if (livestock.healthStatus == 'Healthy') {
      return Icons.check_circle_outline_rounded;
    }

    if (livestock.healthStatus == 'Recovering') {
      return Icons.timelapse_rounded;
    }

    return Icons.warning_amber_rounded;
  }
}