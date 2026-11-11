class FarmField {
  final int? id;

  String name;
  String crop;
  double sizeHectares;

  DateTime plantingDate;
  DateTime expectedHarvestDate;

  String status;
  String notes;

  double? latitude;
  double? longitude;

  DateTime createdAt;

  FarmField({
    this.id,
    required this.name,
    required this.crop,
    required this.sizeHectares,
    required this.plantingDate,
    required this.expectedHarvestDate,
    this.status = 'Planned',
    this.notes = '',
    this.latitude,
    this.longitude,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get growingDays {
    return expectedHarvestDate
        .difference(plantingDate)
        .inDays;
  }

  bool get hasLocation {
    return latitude != null && longitude != null;
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'crop': crop,
      'size_hectares': sizeHectares,
      'planting_date': plantingDate.toIso8601String(),
      'expected_harvest_date':
      expectedHarvestDate.toIso8601String(),
      'status': status,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FarmField.fromMap(
      Map<String, Object?> map,
      ) {
    return FarmField(
      id: map['id'] as int?,
      name: map['name'] as String,
      crop: map['crop'] as String,
      sizeHectares:
      (map['size_hectares'] as num).toDouble(),
      plantingDate: DateTime.parse(
        map['planting_date'] as String,
      ),
      expectedHarvestDate: DateTime.parse(
        map['expected_harvest_date'] as String,
      ),
      status:
      map['status'] as String? ?? 'Planned',
      notes: map['notes'] as String? ?? '',
      latitude: map['latitude'] == null
          ? null
          : (map['latitude'] as num).toDouble(),
      longitude: map['longitude'] == null
          ? null
          : (map['longitude'] as num).toDouble(),
      createdAt: map['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(
        map['created_at'] as String,
      ),
    );
  }

  FarmField copyWith({
    int? id,
    String? name,
    String? crop,
    double? sizeHectares,
    DateTime? plantingDate,
    DateTime? expectedHarvestDate,
    String? status,
    String? notes,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return FarmField(
      id: id ?? this.id,
      name: name ?? this.name,
      crop: crop ?? this.crop,
      sizeHectares:
      sizeHectares ?? this.sizeHectares,
      plantingDate:
      plantingDate ?? this.plantingDate,
      expectedHarvestDate:
      expectedHarvestDate ??
          this.expectedHarvestDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'FarmField('
        'id: $id, '
        'name: $name, '
        'crop: $crop, '
        'sizeHectares: $sizeHectares, '
        'status: $status'
        ')';
  }
}