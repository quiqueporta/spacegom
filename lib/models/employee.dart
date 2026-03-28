enum ExperienceLevel { beginner, experienced, veteran }

extension ExperienceLevelExtension on ExperienceLevel {
  String toJson() => name;

  static ExperienceLevel fromJson(String json) =>
      ExperienceLevel.values.firstWhere((e) => e.name == json);
}

enum MoraleLevel { low, medium, high }

extension MoraleLevelExtension on MoraleLevel {
  String toJson() => name;

  static MoraleLevel fromJson(String json) =>
      MoraleLevel.values.firstWhere((e) => e.name == json);
}

class Employee {
  static const maxMoralChecks = 10;

  static const roles = [
    'Abogado',
    'Agente secreto',
    'Asistente doméstico',
    'Auxiliar de vuelo',
    'Científico de terraformación',
    'Cocinero',
    'Comandante de hipersaltos',
    'Director gerente',
    'Ingeniero astronavegación',
    'Ingeniero computacional',
    'Médico',
    'Negociador de compraventa de mercadería',
    'Operario de logística y almacén',
    'Piloto',
    'Político demagogo',
    'Psicólogo',
    'Recursos Humanos',
    'Responsable de contabilidad y burocracia',
    'Responsable de soporte a pasajeros',
    'Responsable de suministros de manutención',
    'Soldado mercenario',
    'Técnico de mantenimiento de astronaves',
    'Técnico de repostaje y análisis de combustibles',
    'Técnico de soportes vitales',
    'Vicedirector gerente',
  ];

  final int id;
  final String role;
  final String name;
  final int salary;
  final ExperienceLevel experience;
  final MoraleLevel morale;
  final int moralChecks;
  final bool dismissed;

  const Employee({
    required this.id,
    this.role = '',
    this.name = '',
    this.salary = 0,
    this.experience = ExperienceLevel.beginner,
    this.morale = MoraleLevel.medium,
    this.moralChecks = 0,
    this.dismissed = false,
  });

  Employee promoteExperience() {
    if (experience == ExperienceLevel.veteran) return this;

    final nextIndex = ExperienceLevel.values.indexOf(experience) + 1;

    return copyWith(experience: ExperienceLevel.values[nextIndex]);
  }

  Employee copyWith({
    int? id,
    String? role,
    String? name,
    int? salary,
    ExperienceLevel? experience,
    MoraleLevel? morale,
    int? moralChecks,
    bool? dismissed,
  }) {
    final clampedChecks = moralChecks != null
        ? moralChecks.clamp(0, maxMoralChecks)
        : this.moralChecks;

    return Employee(
      id: id ?? this.id,
      role: role ?? this.role,
      name: name ?? this.name,
      salary: salary ?? this.salary,
      experience: experience ?? this.experience,
      morale: morale ?? this.morale,
      moralChecks: clampedChecks,
      dismissed: dismissed ?? this.dismissed,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'name': name,
    'salary': salary,
    'experience': experience.toJson(),
    'morale': morale.toJson(),
    'moralChecks': moralChecks,
    'dismissed': dismissed,
  };

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    id: json['id'] as int,
    role: json['role'] as String? ?? '',
    name: json['name'] as String? ?? '',
    salary: json['salary'] as int? ?? 0,
    experience: ExperienceLevelExtension.fromJson(json['experience'] as String),
    morale: MoraleLevelExtension.fromJson(json['morale'] as String),
    moralChecks: json['moralChecks'] as int? ?? 0,
    dismissed: json['dismissed'] as bool? ?? false,
  );
}
