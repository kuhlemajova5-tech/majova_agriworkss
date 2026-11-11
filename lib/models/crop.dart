class Crop {
  final String cropName;
  final String variety;
  final String field;
  final double area;
  final DateTime plantingDate;
  final DateTime harvestDate;
  final String notes;

  const Crop({
    required this.cropName,
    required this.variety,
    required this.field,
    required this.area,
    required this.plantingDate,
    required this.harvestDate,
    this.notes = '',
  });

  int get daysUntilHarvest {
    final difference = harvestDate.difference(DateTime.now()).inDays;

    if (difference < 0) {
      return 0;
    }

    return difference;
  }

  String get areaText {
    return '${area.toStringAsFixed(2)} ha';
  }
}