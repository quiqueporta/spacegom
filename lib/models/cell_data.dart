enum LocationType { world, spaceport, orbitalStation, hyperjump }

extension LocationTypeExtension on LocationType {
  String toJson() => name;

  static LocationType fromJson(String json) =>
      LocationType.values.firstWhere((e) => e.name == json);
}

enum AreaDensity { low, medium, high }

extension AreaDensityExtension on AreaDensity {
  String toJson() => name;

  static AreaDensity fromJson(String json) =>
      AreaDensity.values.firstWhere((e) => e.name == json);
}

enum CellType { unassigned, world, deepSpace }

extension CellTypeExtension on CellType {
  String toJson() => name;

  static CellType fromJson(String json) =>
      CellType.values.firstWhere((e) => e.name == json);
}

class CellData {
  final CellType type;
  final int? sectionNumber;
  final bool pirates;
  final String megacorporation;
  final String notes;

  bool get isUnassigned => type == CellType.unassigned;
  bool get isWorld => type == CellType.world;
  bool get isDeepSpace => type == CellType.deepSpace;
  bool get hasNotes => notes.isNotEmpty;

  const CellData({
    CellType? type,
    this.sectionNumber,
    this.pirates = false,
    this.megacorporation = '',
    this.notes = '',
  }) : type = type ?? (sectionNumber != null ? CellType.world : CellType.unassigned);

  const CellData.deepSpace({
    this.pirates = false,
    this.megacorporation = '',
    this.notes = '',
  })  : type = CellType.deepSpace,
        sectionNumber = null;

  CellData copyWith({
    CellType? type,
    int? sectionNumber,
    bool? pirates,
    String? megacorporation,
    String? notes,
    bool clearSection = false,
  }) {
    return CellData(
      type: type ?? this.type,
      sectionNumber: clearSection ? null : (sectionNumber ?? this.sectionNumber),
      pirates: pirates ?? this.pirates,
      megacorporation: megacorporation ?? this.megacorporation,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.toJson(),
    'sectionNumber': sectionNumber,
    'pirates': pirates,
    'megacorporation': megacorporation,
    'notes': notes,
  };

  factory CellData.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] as String?;
    final sectionNumber = json['sectionNumber'] as int?;
    final type = rawType != null
        ? CellTypeExtension.fromJson(rawType)
        : (sectionNumber != null ? CellType.world : CellType.deepSpace);

    return CellData(
      type: type,
      sectionNumber: sectionNumber,
      pirates: json['pirates'] as bool? ?? false,
      megacorporation: json['megacorporation'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }
}
