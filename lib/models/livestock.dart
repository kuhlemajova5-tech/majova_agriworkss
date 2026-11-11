class Livestock {
  final String animalType;
  final String recordType;
  final String identification;
  final String breed;
  final String gender;
  final int quantity;
  final double weightKg;
  final DateTime? dateOfBirth;
  final String healthStatus;
  final String location;
  final String notes;

  const Livestock({
    required this.animalType,
    required this.recordType,
    required this.identification,
    required this.breed,
    required this.gender,
    required this.quantity,
    required this.weightKg,
    required this.dateOfBirth,
    required this.healthStatus,
    required this.location,
    this.notes = '',
  });

  bool get isIndividual {
    return recordType == 'Individual';
  }

  bool get isGroup {
    return recordType == 'Group';
  }

  String get quantityText {
    if (quantity == 1) {
      return '1 animal';
    }

    return '$quantity animals';
  }

  String get weightText {
    if (weightKg <= 0) {
      return 'Not recorded';
    }

    return '${weightKg.toStringAsFixed(1)} kg';
  }

  String get displayName {
    if (identification.trim().isNotEmpty) {
      return identification;
    }

    return animalType;
  }
}