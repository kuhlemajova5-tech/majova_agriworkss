class PestDiseaseRecord {
  final int? id;

  String recordType;
  String problemName;

  String crop;
  String fieldName;

  String symptoms;
  String severity;
  String status;

  DateTime detectionDate;

  String treatment;
  DateTime? treatmentDate;

  String notes;

  String? photoPath;

  DateTime createdAt;
  DateTime updatedAt;

  PestDiseaseRecord({
    this.id,
    required this.recordType,
    required this.problemName,
    required this.crop,
    required this.fieldName,
    required this.symptoms,
    required this.severity,
    required this.status,
    required this.detectionDate,
    this.treatment = '',
    this.treatmentDate,
    this.notes = '',
    this.photoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get hasPhoto {
    return photoPath != null &&
        photoPath!.trim().isNotEmpty;
  }

  bool get hasTreatment {
    return treatment.trim().isNotEmpty;
  }

  bool get isActive {
    return status == 'Active';
  }

  bool get isResolved {
    return status == 'Resolved';
  }

  bool get isPest {
    return recordType == 'Pest';
  }

  bool get isDisease {
    return recordType == 'Disease';
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'record_type': recordType,
      'problem_name': problemName,
      'crop': crop,
      'field_name': fieldName,
      'symptoms': symptoms,
      'severity': severity,
      'status': status,
      'detection_date':
      detectionDate.toIso8601String(),
      'treatment': treatment,
      'treatment_date':
      treatmentDate?.toIso8601String(),
      'notes': notes,
      'photo_path': photoPath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PestDiseaseRecord.fromMap(
      Map<String, Object?> map,
      ) {
    return PestDiseaseRecord(
      id: map['id'] as int?,
      recordType:
      map['record_type'] as String? ?? 'Pest',
      problemName:
      map['problem_name'] as String? ?? '',
      crop: map['crop'] as String? ?? '',
      fieldName:
      map['field_name'] as String? ?? '',
      symptoms:
      map['symptoms'] as String? ?? '',
      severity:
      map['severity'] as String? ?? 'Low',
      status:
      map['status'] as String? ?? 'Active',
      detectionDate: DateTime.parse(
        map['detection_date'] as String,
      ),
      treatment:
      map['treatment'] as String? ?? '',
      treatmentDate: map['treatment_date'] == null
          ? null
          : DateTime.parse(
        map['treatment_date'] as String,
      ),
      notes: map['notes'] as String? ?? '',
      photoPath: map['photo_path'] as String?,
      createdAt: map['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(
        map['created_at'] as String,
      ),
      updatedAt: map['updated_at'] == null
          ? DateTime.now()
          : DateTime.parse(
        map['updated_at'] as String,
      ),
    );
  }

  PestDiseaseRecord copyWith({
    int? id,
    String? recordType,
    String? problemName,
    String? crop,
    String? fieldName,
    String? symptoms,
    String? severity,
    String? status,
    DateTime? detectionDate,
    String? treatment,
    DateTime? treatmentDate,
    String? notes,
    String? photoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PestDiseaseRecord(
      id: id ?? this.id,
      recordType:
      recordType ?? this.recordType,
      problemName:
      problemName ?? this.problemName,
      crop: crop ?? this.crop,
      fieldName:
      fieldName ?? this.fieldName,
      symptoms:
      symptoms ?? this.symptoms,
      severity:
      severity ?? this.severity,
      status: status ?? this.status,
      detectionDate:
      detectionDate ?? this.detectionDate,
      treatment:
      treatment ?? this.treatment,
      treatmentDate:
      treatmentDate ?? this.treatmentDate,
      notes: notes ?? this.notes,
      photoPath:
      photoPath ?? this.photoPath,
      createdAt:
      createdAt ?? this.createdAt,
      updatedAt:
      updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'PestDiseaseRecord('
        'id: $id, '
        'type: $recordType, '
        'problem: $problemName, '
        'crop: $crop, '
        'field: $fieldName, '
        'severity: $severity, '
        'status: $status'
        ')';
  }
}