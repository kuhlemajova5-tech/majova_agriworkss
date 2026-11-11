import 'package:flutter/material.dart';
import 'add_tractor_screen.dart';
import 'tractor_details_screen.dart';
import '../../models/tractor.dart';

class TractorDetailsScreen extends StatelessWidget {
  final Tractor tractor;

  const TractorDetailsScreen({
    super.key,
    required this.tractor,
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
          'Tractor Details',
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

            const SizedBox(height: 28),

            _buildSectionTitle('Tractor Information'),

            const SizedBox(height: 14),

            _buildInformationCard(
              children: [
                _buildInformationRow(
                  icon: Icons.factory_outlined,
                  title: 'Brand',
                  value: tractor.brand,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.settings_outlined,
                  title: 'Model',
                  value: tractor.model,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.confirmation_number_outlined,
                  title: 'Registration / Fleet Number',
                  value: tractor.registrationNumber,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.calendar_today_outlined,
                  title: 'Year',
                  value: tractor.year.toString(),
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.location_on_outlined,
                  title: 'Current Location',
                  value: tractor.location,
                ),
              ],
            ),

            const SizedBox(height: 28),

            _buildSectionTitle('Operating Information'),

            const SizedBox(height: 14),

            _buildInformationCard(
              children: [
                _buildInformationRow(
                  icon: Icons.timer_outlined,
                  title: 'Engine Hours',
                  value: tractor.engineHoursText,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.local_gas_station_outlined,
                  title: 'Fuel Type',
                  value: tractor.fuelType,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.build_circle_outlined,
                  title: 'Condition',
                  value: tractor.condition,
                ),
              ],
            ),

            const SizedBox(height: 28),

            _buildSectionTitle('Operating Status'),

            const SizedBox(height: 14),

            _buildStatusCard(),

            const SizedBox(height: 28),

            _buildSectionTitle('Service & Maintenance'),

            const SizedBox(height: 14),

            _buildInformationCard(
              children: [
                _buildInformationRow(
                  icon: Icons.history_rounded,
                  title: 'Last Service',
                  value: _formatDate(
                    tractor.lastServiceDate,
                  ),
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.event_available_outlined,
                  title: 'Next Service',
                  value: _formatDate(
                    tractor.nextServiceDate,
                  ),
                ),
              ],
            ),

            if (tractor.needsService) ...[
              const SizedBox(height: 14),
              _buildServiceWarning(),
            ],

            const SizedBox(height: 28),

            _buildSectionTitle('Notes'),

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
                tractor.notes.trim().isEmpty
                    ? 'No additional notes recorded.'
                    : tractor.notes,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Color(0xFF66736A),
                ),
              ),
            ),

            const SizedBox(height: 28),

            _buildSectionTitle('Quick Information'),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _buildQuickCard(
                    icon: Icons.speed_rounded,
                    title: 'Hours',
                    value: tractor.engineHoursText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickCard(
                    icon: Icons.calendar_month_outlined,
                    title: 'Year',
                    value: tractor.year.toString(),
                  ),
                ),
              ],
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
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(23),
            ),
            child: const Icon(
              Icons.agriculture_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            tractor.displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            tractor.fullModelName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tractor.registrationNumber,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF17201A),
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
          width: 44,
          height: 44,
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

  Widget _buildStatusCard() {
    final backgroundColor = _statusBackgroundColor();
    final foregroundColor = _statusTextColor();

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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              _statusIcon(),
              color: foregroundColor,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Tractor Status',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF66736A),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  tractor.status,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: foregroundColor,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  tractor.condition,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF66736A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceWarning() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFFCC80),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF57F17),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Attention Required',
                  style: TextStyle(
                    color: Color(0xFFF57F17),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'This tractor has reached or is approaching its scheduled service date.',
                  style: TextStyle(
                    color: Color(0xFF66736A),
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

  Widget _buildQuickCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE3E9E4),
        ),
      ),
      child: Column(
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
              color: const Color(0xFF1B5E20),
              size: 22,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF66736A),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF17201A),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusBackgroundColor() {
    switch (tractor.status) {
      case 'Operational':
        return const Color(0xFFE8F5E9);

      case 'In Use':
        return const Color(0xFFE3F2FD);

      case 'Under Maintenance':
        return const Color(0xFFFFF8E1);

      default:
        return const Color(0xFFFFEBEE);
    }
  }

  Color _statusTextColor() {
    switch (tractor.status) {
      case 'Operational':
        return const Color(0xFF1B5E20);

      case 'In Use':
        return const Color(0xFF1565C0);

      case 'Under Maintenance':
        return const Color(0xFFF57F17);

      default:
        return const Color(0xFFC62828);
    }
  }

  IconData _statusIcon() {
    switch (tractor.status) {
      case 'Operational':
        return Icons.check_circle_outline_rounded;

      case 'In Use':
        return Icons.agriculture_rounded;

      case 'Under Maintenance':
        return Icons.build_outlined;

      default:
        return Icons.error_outline_rounded;
    }
  }
}