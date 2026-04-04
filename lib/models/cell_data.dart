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

class CellData {
  final int? sectionNumber;
  final bool pirates;
  final String megacorporation;

  bool get isDeepSpace => sectionNumber == null;

  const CellData({
    this.sectionNumber,
    this.pirates = false,
    this.megacorporation = '',
  });

  const CellData.deepSpace({
    this.pirates = false,
    this.megacorporation = '',
  }) : sectionNumber = null;

  CellData copyWith({
    int? sectionNumber,
    bool? pirates,
    String? megacorporation,
    bool clearSection = false,
  }) {
    return CellData(
      sectionNumber: clearSection ? null : (sectionNumber ?? this.sectionNumber),
      pirates: pirates ?? this.pirates,
      megacorporation: megacorporation ?? this.megacorporation,
    );
  }

  Map<String, dynamic> toJson() => {
    'sectionNumber': sectionNumber,
    'pirates': pirates,
    'megacorporation': megacorporation,
  };

  factory CellData.fromJson(Map<String, dynamic> json) => CellData(
    sectionNumber: json['sectionNumber'] as int?,
    pirates: json['pirates'] as bool? ?? false,
    megacorporation: json['megacorporation'] as String? ?? '',
  );
}
