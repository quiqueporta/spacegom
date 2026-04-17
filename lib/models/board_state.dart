import 'package:spacegom_companion/models/cell_data.dart';

class BoardState {
  final int shipArea;
  final int shipRow;
  final int shipCol;
  final int month;
  final int year;
  final int day;
  final int hyperjumpDays;
  final Map<int, Map<(int, int), CellData>> areaCells;
  final Map<int, AreaDensity> areaDensity;
  final Map<int, int> customHyperjumpDays;
  final Map<int, int> customMissions;
  final String? selectedLocation;

  const BoardState({
    this.shipArea = 1,
    this.shipRow = 1,
    this.shipCol = 1,
    this.month = 1,
    this.year = 1,
    this.day = 1,
    this.hyperjumpDays = 0,
    this.areaCells = const {},
    this.areaDensity = const {},
    this.customHyperjumpDays = const {},
    this.customMissions = const {},
    this.selectedLocation,
  });

  BoardState copyWith({
    int? shipArea,
    int? shipRow,
    int? shipCol,
    int? month,
    int? year,
    int? day,
    int? hyperjumpDays,
    Map<int, Map<(int, int), CellData>>? areaCells,
    Map<int, AreaDensity>? areaDensity,
    Map<int, int>? customHyperjumpDays,
    Map<int, int>? customMissions,
    String? selectedLocation,
    bool clearLocation = false,
  }) {
    return BoardState(
      shipArea: shipArea ?? this.shipArea,
      shipRow: shipRow ?? this.shipRow,
      shipCol: shipCol ?? this.shipCol,
      month: month ?? this.month,
      year: year ?? this.year,
      day: day ?? this.day,
      hyperjumpDays: hyperjumpDays ?? this.hyperjumpDays,
      areaCells: areaCells ?? this.areaCells,
      areaDensity: areaDensity ?? this.areaDensity,
      customHyperjumpDays: customHyperjumpDays ?? this.customHyperjumpDays,
      customMissions: customMissions ?? this.customMissions,
      selectedLocation: clearLocation ? null : (selectedLocation ?? this.selectedLocation),
    );
  }

  int? findAreaForSection(int sectionNumber) {
    for (final areaEntry in areaCells.entries) {
      for (final cell in areaEntry.value.values) {
        if (cell.sectionNumber == sectionNumber) return areaEntry.key;
      }
    }

    return null;
  }

  Map<String, dynamic> toJson() => {
    'shipArea': shipArea,
    'shipRow': shipRow,
    'shipCol': shipCol,
    'month': month,
    'year': year,
    'day': day,
    'hyperjumpDays': hyperjumpDays,
    'areaCells': _areaCellsToJson(),
    'areaDensity': _areaDensityToJson(),
    'customHyperjumpDays': _customHyperjumpDaysToJson(),
    'customMissions': _customMissionsToJson(),
    'selectedLocation': selectedLocation,
  };

  factory BoardState.fromJson(Map<String, dynamic> json) => BoardState(
    shipArea: json['shipArea'] as int? ?? 1,
    shipRow: json['shipRow'] as int? ?? 1,
    shipCol: json['shipCol'] as int? ?? 1,
    month: json['month'] as int? ?? 1,
    year: json['year'] as int? ?? 1,
    day: json['day'] as int? ?? 1,
    hyperjumpDays: json['hyperjumpDays'] as int? ?? 0,
    areaCells: _areaCellsFromJson(json['areaCells']),
    areaDensity: _areaDensityFromJson(json['areaDensity']),
    customHyperjumpDays: _customHyperjumpDaysFromJson(json['customHyperjumpDays']),
    customMissions: _customMissionsFromJson(json['customMissions']),
    selectedLocation: json['selectedLocation'] as String?,
  );

  Map<String, dynamic> _areaCellsToJson() {
    final result = <String, dynamic>{};

    for (final entry in areaCells.entries) {
      final cellMap = <String, dynamic>{};

      for (final cell in entry.value.entries) {
        cellMap['${cell.key.$1},${cell.key.$2}'] = cell.value.toJson();
      }

      result['${entry.key}'] = cellMap;
    }

    return result;
  }

  static Map<int, Map<(int, int), CellData>> _areaCellsFromJson(dynamic raw) {
    if (raw == null) return {};

    final jsonMap = raw as Map<String, dynamic>;
    final result = <int, Map<(int, int), CellData>>{};

    for (final areaEntry in jsonMap.entries) {
      final areaNum = int.parse(areaEntry.key);
      final cellsJson = areaEntry.value as Map<String, dynamic>;
      final cells = <(int, int), CellData>{};

      for (final cellEntry in cellsJson.entries) {
        final parts = cellEntry.key.split(',');
        final row = int.parse(parts[0]);
        final col = int.parse(parts[1]);

        if (cellEntry.value is int) {
          cells[(row, col)] = CellData(sectionNumber: cellEntry.value as int);
        } else {
          cells[(row, col)] = CellData.fromJson(cellEntry.value as Map<String, dynamic>);
        }
      }

      result[areaNum] = cells;
    }

    return result;
  }

  Map<String, String> _areaDensityToJson() {
    return areaDensity.map((k, v) => MapEntry('$k', v.toJson()));
  }

  static Map<int, AreaDensity> _areaDensityFromJson(dynamic raw) {
    if (raw == null) return {};

    final jsonMap = raw as Map<String, dynamic>;

    return jsonMap.map(
      (k, v) => MapEntry(int.parse(k), AreaDensityExtension.fromJson(v as String)),
    );
  }

  Map<String, int> _customHyperjumpDaysToJson() {
    return customHyperjumpDays.map((k, v) => MapEntry('$k', v));
  }

  static Map<int, int> _customHyperjumpDaysFromJson(dynamic raw) {
    if (raw == null) return {};

    final jsonMap = raw as Map<String, dynamic>;

    return jsonMap.map((k, v) => MapEntry(int.parse(k), v as int));
  }

  Map<String, int> _customMissionsToJson() {
    return customMissions.map((k, v) => MapEntry('$k', v));
  }

  static Map<int, int> _customMissionsFromJson(dynamic raw) {
    if (raw == null) return {};

    final jsonMap = raw as Map<String, dynamic>;

    return jsonMap.map((k, v) => MapEntry(int.parse(k), v as int));
  }
}
