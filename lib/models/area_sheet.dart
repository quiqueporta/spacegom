enum MissionResult { pending, success, failure }

extension MissionResultExtension on MissionResult {
  String toJson() => name;

  static MissionResult fromJson(String json) =>
      MissionResult.values.firstWhere((e) => e.name == json);
}

class SpecialMission {
  final String code;
  final String acceptanceWorld;
  final String executionLocations;
  final String deadline;
  final MissionResult result;

  const SpecialMission({
    this.code = '',
    this.acceptanceWorld = '',
    this.executionLocations = '',
    this.deadline = '',
    this.result = MissionResult.pending,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'acceptanceWorld': acceptanceWorld,
    'executionLocations': executionLocations,
    'deadline': deadline,
    'result': result.toJson(),
  };

  factory SpecialMission.fromJson(Map<String, dynamic> json) => SpecialMission(
    code: json['code'] as String? ?? '',
    acceptanceWorld: json['acceptanceWorld'] as String? ?? '',
    executionLocations: json['executionLocations'] as String? ?? '',
    deadline: json['deadline'] as String? ?? '',
    result: MissionResultExtension.fromJson(json['result'] as String),
  );
}

class TradeRecord {
  final String purchaseWorld;
  final String productCode;
  final int purchaseUnits;
  final int purchaseAmount;
  final String purchaseDate;
  final String saleWorld;
  final int saleAmount;
  final String saleDate;
  final bool traceability;
  final bool voided;

  const TradeRecord({
    this.purchaseWorld = '',
    this.productCode = '',
    this.purchaseUnits = 0,
    this.purchaseAmount = 0,
    this.purchaseDate = '',
    this.saleWorld = '',
    this.saleAmount = 0,
    this.saleDate = '',
    this.traceability = false,
    this.voided = false,
  });

  int get profit => saleAmount - purchaseAmount;

  Map<String, dynamic> toJson() => {
    'purchaseWorld': purchaseWorld,
    'productCode': productCode,
    'purchaseUnits': purchaseUnits,
    'purchaseAmount': purchaseAmount,
    'purchaseDate': purchaseDate,
    'saleWorld': saleWorld,
    'saleAmount': saleAmount,
    'saleDate': saleDate,
    'traceability': traceability,
    'voided': voided,
  };

  factory TradeRecord.fromJson(Map<String, dynamic> json) => TradeRecord(
    purchaseWorld: json['purchaseWorld'] as String? ?? '',
    productCode: json['productCode'] as String? ?? '',
    purchaseUnits: json['purchaseUnits'] as int? ?? 0,
    purchaseAmount: json['purchaseAmount'] as int? ?? 0,
    purchaseDate: json['purchaseDate'] as String? ?? '',
    saleWorld: json['saleWorld'] as String? ?? '',
    saleAmount: json['saleAmount'] as int? ?? 0,
    saleDate: json['saleDate'] as String? ?? '',
    traceability: json['traceability'] as bool? ?? false,
    voided: json['voided'] as bool? ?? false,
  );
}

class AreaSheet {
  final List<SpecialMission> missions;
  final List<TradeRecord> trades;

  const AreaSheet({
    this.missions = const [],
    this.trades = const [],
  });

  AreaSheet copyWith({
    List<SpecialMission>? missions,
    List<TradeRecord>? trades,
  }) {
    return AreaSheet(
      missions: missions ?? this.missions,
      trades: trades ?? this.trades,
    );
  }

  Map<String, dynamic> toJson() => {
    'missions': missions.map((e) => e.toJson()).toList(),
    'trades': trades.map((e) => e.toJson()).toList(),
  };

  factory AreaSheet.fromJson(Map<String, dynamic> json) => AreaSheet(
    missions: (json['missions'] as List<dynamic>?)
        ?.map((e) => SpecialMission.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
    trades: (json['trades'] as List<dynamic>?)
        ?.map((e) => TradeRecord.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
  );
}

class ProductInfo {
  final String code;
  final String productName;
  final int purchasePrice;
  final int salePrice;
  final int productionDays;
  final int demandDays;

  const ProductInfo({
    required this.code,
    required this.productName,
    required this.purchasePrice,
    required this.salePrice,
    required this.productionDays,
    required this.demandDays,
  });
}

class ProductReference {
  static const products = [
    ProductInfo(code: 'INDU', productName: 'Industriales', purchasePrice: 9, salePrice: 18, productionDays: 30, demandDays: 50),
    ProductInfo(code: 'BASI', productName: 'Básicos', purchasePrice: 11, salePrice: 21, productionDays: 40, demandDays: 50),
    ProductInfo(code: 'ALIM', productName: 'Alimentación', purchasePrice: 4, salePrice: 11, productionDays: 30, demandDays: 40),
    ProductInfo(code: 'MADE', productName: 'Madera', purchasePrice: 6, salePrice: 17, productionDays: 30, demandDays: 50),
    ProductInfo(code: 'AGUA', productName: 'Agua potable', purchasePrice: 2, salePrice: 5, productionDays: 20, demandDays: 20),
    ProductInfo(code: 'MICO', productName: 'Minerales comunes', purchasePrice: 5, salePrice: 9, productionDays: 30, demandDays: 50),
    ProductInfo(code: 'MIRA', productName: 'Minerales raros', purchasePrice: 13, salePrice: 30, productionDays: 50, demandDays: 60),
    ProductInfo(code: 'MIPR', productName: 'Metales preciosos', purchasePrice: 20, salePrice: 60, productionDays: 80, demandDays: 80),
    ProductInfo(code: 'PAVA', productName: 'Prod. avanzados', purchasePrice: 15, salePrice: 30, productionDays: 40, demandDays: 60),
    ProductInfo(code: 'A', productName: 'Armas', purchasePrice: 7, salePrice: 15, productionDays: 40, demandDays: 40),
    ProductInfo(code: 'AE', productName: 'Armas etapa esp.', purchasePrice: 10, salePrice: 23, productionDays: 60, demandDays: 60),
    ProductInfo(code: 'AEI', productName: 'Armas modernas', purchasePrice: 20, salePrice: 45, productionDays: 80, demandDays: 80),
    ProductInfo(code: 'COM', productName: 'Combustible', purchasePrice: 4, salePrice: 7, productionDays: 30, demandDays: 20),
  ];
}
