import 'package:spacegom_companion/models/area_sheet.dart';
import 'package:spacegom_companion/models/board_state.dart';
import 'package:spacegom_companion/models/campaign_calendar.dart';
import 'package:spacegom_companion/models/company.dart';
import 'package:spacegom_companion/models/employee.dart';

class GameState {
  final Company company;
  final BoardState boardState;
  final CampaignCalendar calendar;
  final Map<int, AreaSheet> areaSheets;

  GameState({
    Company? company,
    this.boardState = const BoardState(),
    this.calendar = const CampaignCalendar(),
    this.areaSheets = const {},
  }) : company = company ?? Company();

  factory GameState.withDefaultCrew() {
    return GameState(
      company: Company(
        employees: _defaultCrew,
      ),
    );
  }

  static final _defaultCrew = [
    Employee(id: 1, name: 'Widaker Farq', role: 'Director gerente', salary: 20, experience: ExperienceLevel.experienced, morale: MoraleLevel.high),
    Employee(id: 2, name: 'Samantha Warm', role: 'Comandante de hipersaltos', salary: 15, experience: ExperienceLevel.experienced, morale: MoraleLevel.medium),
    Employee(id: 3, name: 'Thomas Muller', role: 'Ingeniero computacional', salary: 4, experience: ExperienceLevel.beginner, morale: MoraleLevel.medium),
    Employee(id: 4, name: 'Walter Lopez', role: 'Ingeniero astronavegación', salary: 8, experience: ExperienceLevel.beginner, morale: MoraleLevel.medium),
    Employee(id: 5, name: 'Jeffrey Cook', role: 'Técnico de repostaje y análisis de combustibles', salary: 8, experience: ExperienceLevel.experienced, morale: MoraleLevel.medium),
    Employee(id: 6, name: 'Danielle Rivers', role: 'Piloto', salary: 10, experience: ExperienceLevel.experienced, morale: MoraleLevel.medium),
    Employee(id: 7, name: 'Isaac Peterson', role: 'Operario de logística y almacén', salary: 1, experience: ExperienceLevel.beginner, morale: MoraleLevel.high),
    Employee(id: 8, name: 'Katherine Smith', role: 'Responsable de contabilidad y burocracia', salary: 3, experience: ExperienceLevel.experienced, morale: MoraleLevel.high),
    Employee(id: 9, name: 'Jason Wilson', role: 'Responsable de suministros de manutención', salary: 3, experience: ExperienceLevel.experienced, morale: MoraleLevel.medium),
    Employee(id: 10, name: 'Sam Hernández', role: 'Cocinero', salary: 3, experience: ExperienceLevel.experienced, morale: MoraleLevel.medium),
    Employee(id: 11, name: 'Alexandra Adams', role: 'Asistente doméstico', salary: 1, experience: ExperienceLevel.experienced, morale: MoraleLevel.medium),
  ];

  GameState copyWith({
    Company? company,
    BoardState? boardState,
    CampaignCalendar? calendar,
    Map<int, AreaSheet>? areaSheets,
  }) {
    return GameState(
      company: company ?? this.company,
      boardState: boardState ?? this.boardState,
      calendar: calendar ?? this.calendar,
      areaSheets: areaSheets ?? this.areaSheets,
    );
  }

  Map<String, dynamic> toJson() => {
    'company': company.toJson(),
    'boardState': boardState.toJson(),
    'calendar': calendar.toJson(),
    'areaSheets': areaSheets.map((k, v) => MapEntry('$k', v.toJson())),
  };

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
    company: json['company'] != null
        ? Company.fromJson(json['company'] as Map<String, dynamic>)
        : Company(),
    boardState: json['boardState'] != null
        ? BoardState.fromJson(json['boardState'] as Map<String, dynamic>)
        : const BoardState(),
    calendar: json['calendar'] != null
        ? CampaignCalendar.fromJson(json['calendar'] as Map<String, dynamic>)
        : const CampaignCalendar(),
    areaSheets: _areaSheetsFromJson(json['areaSheets']),
  );

  static Map<int, AreaSheet> _areaSheetsFromJson(dynamic raw) {
    if (raw == null) return {};

    final jsonMap = raw as Map<String, dynamic>;

    return jsonMap.map(
      (k, v) => MapEntry(int.parse(k), AreaSheet.fromJson(v as Map<String, dynamic>)),
    );
  }
}
