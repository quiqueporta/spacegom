class SpecialDate {
  final String letter;
  final int month;
  final int day;
  final String description;

  const SpecialDate({
    required this.letter,
    required this.month,
    required this.day,
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
    'letter': letter,
    'month': month,
    'day': day,
    'description': description,
  };

  factory SpecialDate.fromJson(Map<String, dynamic> json) => SpecialDate(
    letter: json['letter'] as String,
    month: json['month'] as int,
    day: json['day'] as int,
    description: json['description'] as String? ?? '',
  );
}

class CampaignCalendar {
  final int currentYear;
  final Map<int, Set<(int, int)>> markedDays;
  final Map<int, List<SpecialDate>> specialDates;
  final Map<int, Set<(int, int)>> adminDone;

  const CampaignCalendar({
    this.currentYear = 1,
    this.markedDays = const {},
    this.specialDates = const {},
    this.adminDone = const {},
  });

  (int, int) get currentDate {
    final marks = markedDays[currentYear] ?? {};

    for (var m = 1; m <= 12; m++) {
      for (var d = 1; d <= 35; d++) {
        if (!marks.contains((m, d))) return (m, d);
      }
    }

    return (12, 35);
  }

  List<SpecialDate> eventsForDay(int month, int day) {
    final yearEvents = specialDates[currentYear];
    if (yearEvents == null) return [];

    return yearEvents.where((e) => e.month == month && e.day == day).toList();
  }

  static bool isWeeklyAdmin(int day) =>
      day == 7 || day == 14 || day == 21 || day == 28;

  static bool isMonthlyAdmin(int day) => day == 35;

  static bool isAdminDay(int day) => isWeeklyAdmin(day) || isMonthlyAdmin(day);

  CampaignCalendar copyWith({
    int? currentYear,
    Map<int, Set<(int, int)>>? markedDays,
    Map<int, List<SpecialDate>>? specialDates,
    Map<int, Set<(int, int)>>? adminDone,
  }) {
    return CampaignCalendar(
      currentYear: currentYear ?? this.currentYear,
      markedDays: markedDays ?? this.markedDays,
      specialDates: specialDates ?? this.specialDates,
      adminDone: adminDone ?? this.adminDone,
    );
  }

  Map<String, dynamic> toJson() => {
    'currentYear': currentYear,
    'markedDays': _markedDaysToJson(),
    'specialDates': _specialDatesToJson(),
    'adminDone': _adminDoneToJson(),
  };

  factory CampaignCalendar.fromJson(Map<String, dynamic> json) =>
      CampaignCalendar(
        currentYear: json['currentYear'] as int? ?? 1,
        markedDays: _markedDaysFromJson(json['markedDays']),
        specialDates: _specialDatesFromJson(json['specialDates']),
        adminDone: _adminDoneFromJson(json['adminDone']),
      );

  Map<String, dynamic> _markedDaysToJson() {
    return markedDays.map(
      (year, days) => MapEntry(
        '$year',
        days.map((d) => '${d.$1},${d.$2}').toList(),
      ),
    );
  }

  static Map<int, Set<(int, int)>> _markedDaysFromJson(dynamic raw) {
    if (raw == null) return {};

    final jsonMap = raw as Map<String, dynamic>;

    return jsonMap.map((k, v) {
      final year = int.parse(k);
      final days = (v as List<dynamic>).map((e) {
        final parts = (e as String).split(',');

        return (int.parse(parts[0]), int.parse(parts[1]));
      }).toSet();

      return MapEntry(year, days);
    });
  }

  Map<String, dynamic> _specialDatesToJson() {
    return specialDates.map(
      (year, dates) => MapEntry(
        '$year',
        dates.map((e) => e.toJson()).toList(),
      ),
    );
  }

  static Map<int, List<SpecialDate>> _specialDatesFromJson(dynamic raw) {
    if (raw == null) return {};

    if (raw is List) {
      if (raw.isEmpty) return {};

      return {
        1: raw
            .map((e) => SpecialDate.fromJson(e as Map<String, dynamic>))
            .toList(),
      };
    }

    final jsonMap = raw as Map<String, dynamic>;

    return jsonMap.map((k, v) {
      final year = int.parse(k);
      final dates = (v as List<dynamic>)
          .map((e) => SpecialDate.fromJson(e as Map<String, dynamic>))
          .toList();

      return MapEntry(year, dates);
    });
  }

  Map<String, dynamic> _adminDoneToJson() {
    return adminDone.map(
      (year, days) => MapEntry(
        '$year',
        days.map((d) => '${d.$1},${d.$2}').toList(),
      ),
    );
  }

  static Map<int, Set<(int, int)>> _adminDoneFromJson(dynamic raw) {
    if (raw == null) return {};

    if (raw is List) {
      if (raw.isEmpty) return {};

      return {
        1: raw.map((e) {
          final parts = (e as String).split(',');

          return (int.parse(parts[0]), int.parse(parts[1]));
        }).toSet(),
      };
    }

    final jsonMap = raw as Map<String, dynamic>;

    return jsonMap.map((k, v) {
      final year = int.parse(k);
      final days = (v as List<dynamic>).map((e) {
        final parts = (e as String).split(',');

        return (int.parse(parts[0]), int.parse(parts[1]));
      }).toSet();

      return MapEntry(year, days);
    });
  }
}
