class LifeSupportType {
  final String code;
  final String equipmentName;

  const LifeSupportType({
    required this.code,
    required this.equipmentName,
  });
}

class LifeSupportReference {
  static const equipment = [
    LifeSupportType(code: 'SO', equipmentName: 'Suministro básico de oxígeno'),
    LifeSupportType(code: 'MF', equipmentName: 'Máscara con filtraje'),
    LifeSupportType(code: 'RE', equipmentName: 'Respirador'),
    LifeSupportType(code: 'RF', equipmentName: 'Respirador con filtraje'),
    LifeSupportType(code: 'TE', equipmentName: 'Traje espacial estándar'),
    LifeSupportType(code: 'TA', equipmentName: 'Traje espacial avanzado'),
    LifeSupportType(code: 'TH', equipmentName: 'Traje espacial hiperavanzado'),
  ];
}
