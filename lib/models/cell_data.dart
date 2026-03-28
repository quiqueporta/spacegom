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
  final LocationType locationType;
  final bool pirates;
  final String megacorporation;

  bool get isDeepSpace => sectionNumber == null;

  const CellData({
    this.sectionNumber,
    this.locationType = LocationType.world,
    this.pirates = false,
    this.megacorporation = '',
  });

  const CellData.deepSpace({
    this.pirates = false,
    this.megacorporation = '',
  })  : sectionNumber = null,
        locationType = LocationType.world;

  CellData copyWith({
    int? sectionNumber,
    LocationType? locationType,
    bool? pirates,
    String? megacorporation,
    bool clearSection = false,
  }) {
    return CellData(
      sectionNumber: clearSection ? null : (sectionNumber ?? this.sectionNumber),
      locationType: locationType ?? this.locationType,
      pirates: pirates ?? this.pirates,
      megacorporation: megacorporation ?? this.megacorporation,
    );
  }

  Map<String, dynamic> toJson() => {
    'sectionNumber': sectionNumber,
    'locationType': locationType.toJson(),
    'pirates': pirates,
    'megacorporation': megacorporation,
  };

  factory CellData.fromJson(Map<String, dynamic> json) => CellData(
    sectionNumber: json['sectionNumber'] as int?,
    locationType: LocationTypeExtension.fromJson(json['locationType'] as String),
    pirates: json['pirates'] as bool? ?? false,
    megacorporation: json['megacorporation'] as String? ?? '',
  );
}
