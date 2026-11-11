class Tractor {
  final String name;
  final String brand;
  final String model;
  final String registrationNumber;
  final int year;
  final double engineHours;
  final String fuelType;
  final String condition;
  final String status;
  final String location;
  final DateTime? lastServiceDate;
  final DateTime? nextServiceDate;
  final String notes;

  const Tractor({
    required this.name,
    required this.brand,
    required this.model,
    required this.registrationNumber,
    required this.year,
    required this.engineHours,
    required this.fuelType,
    required this.condition,
    required this.status,
    required this.location,
    required this.lastServiceDate,
    required this.nextServiceDate,
    this.notes = '',
  });

  String get displayName {
    if (name.trim().isNotEmpty) {
      return name;
    }

    return '$brand $model';
  }

  String get fullModelName {
    return '$brand $model';
  }

  String get engineHoursText {
    return '${engineHours.toStringAsFixed(1)} hrs';
  }

  bool get needsService {
    if (nextServiceDate == null) {
      return false;
    }

    final today = DateTime.now();

    return nextServiceDate!.isBefore(today) ||
        nextServiceDate!.difference(today).inDays <= 7;
  }

  bool get isOperational {
    return status == 'Operational';
  }
}