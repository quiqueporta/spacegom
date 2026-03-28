class Ship {
  final String model;
  final int hyperjumpCapacity;
  final int rollModifier;
  final int maxPassengers;
  final int maxCargo;
  final int lightSupport;
  final int moderateSupport;
  final int severeSupport;

  const Ship({
    this.model = '',
    this.hyperjumpCapacity = 0,
    this.rollModifier = 0,
    this.maxPassengers = 0,
    this.maxCargo = 0,
    this.lightSupport = 0,
    this.moderateSupport = 0,
    this.severeSupport = 0,
  });

  Ship copyWith({
    String? model,
    int? hyperjumpCapacity,
    int? rollModifier,
    int? maxPassengers,
    int? maxCargo,
    int? lightSupport,
    int? moderateSupport,
    int? severeSupport,
  }) {
    return Ship(
      model: model ?? this.model,
      hyperjumpCapacity: hyperjumpCapacity ?? this.hyperjumpCapacity,
      rollModifier: rollModifier ?? this.rollModifier,
      maxPassengers: maxPassengers ?? this.maxPassengers,
      maxCargo: maxCargo ?? this.maxCargo,
      lightSupport: lightSupport ?? this.lightSupport,
      moderateSupport: moderateSupport ?? this.moderateSupport,
      severeSupport: severeSupport ?? this.severeSupport,
    );
  }

  Map<String, dynamic> toJson() => {
    'model': model,
    'hyperjumpCapacity': hyperjumpCapacity,
    'rollModifier': rollModifier,
    'maxPassengers': maxPassengers,
    'maxCargo': maxCargo,
    'lightSupport': lightSupport,
    'moderateSupport': moderateSupport,
    'severeSupport': severeSupport,
  };

  factory Ship.fromJson(Map<String, dynamic> json) => Ship(
    model: json['model'] as String? ?? '',
    hyperjumpCapacity: json['hyperjumpCapacity'] as int? ?? 0,
    rollModifier: json['rollModifier'] as int? ?? 0,
    maxPassengers: json['maxPassengers'] as int? ?? 0,
    maxCargo: json['maxCargo'] as int? ?? 0,
    lightSupport: json['lightSupport'] as int? ?? 0,
    moderateSupport: json['moderateSupport'] as int? ?? 0,
    severeSupport: json['severeSupport'] as int? ?? 0,
  );
}
