import 'dart:math';

class Planet {
  final String name;
  final String lifeSupport;
  final String contagionRisk;
  final String agreement;
  final int hyperjumpDays;
  final String legalSystem;
  final String spaceport;
  final String cc;
  final String pi;
  final String ds;
  final String aa;
  final List<String> products;
  final int selfSufficiency;
  final int ucnPerOrder;
  final int passengers;
  final String missions;

  const Planet({
    required this.name,
    required this.lifeSupport,
    required this.contagionRisk,
    required this.agreement,
    required this.hyperjumpDays,
    required this.legalSystem,
    required this.spaceport,
    required this.cc,
    required this.pi,
    required this.ds,
    required this.aa,
    required this.products,
    required this.selfSufficiency,
    required this.ucnPerOrder,
    required this.passengers,
    required this.missions,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'lifeSupport': lifeSupport,
    'contagionRisk': contagionRisk,
    'agreement': agreement,
    'hyperjumpDays': hyperjumpDays,
    'legalSystem': legalSystem,
    'spaceport': spaceport,
    'cc': cc,
    'pi': pi,
    'ds': ds,
    'aa': aa,
    'products': products,
    'selfSufficiency': selfSufficiency,
    'ucnPerOrder': ucnPerOrder,
    'passengers': passengers,
    'missions': missions,
  };

  factory Planet.fromJson(Map<String, dynamic> json) => Planet(
    name: json['name'] as String,
    lifeSupport: json['lifeSupport'] as String,
    contagionRisk: json['contagionRisk'] as String,
    agreement: json['agreement'] as String,
    hyperjumpDays: json['hyperjumpDays'] as int,
    legalSystem: json['legalSystem'] as String,
    spaceport: json['spaceport'] as String,
    cc: json['cc'] as String,
    pi: json['pi'] as String,
    ds: json['ds'] as String,
    aa: json['aa'] as String,
    products: (json['products'] as List).cast<String>(),
    selfSufficiency: json['selfSufficiency'] as int,
    ucnPerOrder: json['ucnPerOrder'] as int,
    passengers: json['passengers'] as int,
    missions: json['missions'] as String,
  );
}

class PlanetDatabase {
  PlanetDatabase._();

  static final Map<int, Planet> planets = _buildPlanetData();

  static int randomSectionNumber({Random? random}) {
    final rng = random ?? Random();
    final d1 = rng.nextInt(6) + 1;
    final d2 = rng.nextInt(6) + 1;
    final d3 = rng.nextInt(6) + 1;

    return d1 * 100 + d2 * 10 + d3;
  }
}

Map<int, Planet> _buildPlanetData() {
  final data = <int, Planet>{};
  final lines = _planetCsv.split('\n');

  for (var i = 2; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;

    final cols = line.split(';');
    if (cols.length < 28) continue;

    final section = int.tryParse(cols[1].trim());
    if (section == null) continue;

    final productCodes = ['INDU', 'BASI', 'ALIM', 'MADE', 'AGUA', 'MICO', 'MIRA', 'MIPR', 'PAVA', 'A', 'AE', 'AEI', 'COM'];
    final parsedProducts = <String>[];
    for (var j = 0; j < 13; j++) {
      if (cols.length > 12 + j && cols[12 + j].trim().toUpperCase() == 'X') {
        parsedProducts.add(productCodes[j]);
      }
    }

    data[section] = Planet(
      name: cols[0].trim(),
      lifeSupport: cols[2].trim(),
      contagionRisk: cols[3].trim(),
      agreement: cols[4].trim(),
      hyperjumpDays: int.tryParse(cols[5].trim()) ?? 0,
      legalSystem: cols[6].trim(),
      spaceport: cols[7].trim(),
      cc: cols[8].trim(),
      pi: cols[9].trim(),
      ds: cols[10].trim(),
      aa: cols[11].trim(),
      products: parsedProducts,
      selfSufficiency: int.tryParse(cols[25].trim()) ?? 0,
      ucnPerOrder: int.tryParse(cols[26].trim()) ?? 0,
      passengers: int.tryParse(cols[27].trim()) ?? 0,
      missions: cols.length > 28 ? cols[28].trim() : '',
    );
  }

  return data;
}

const _planetCsv = '''Nombre;*1;*2;*3;*4;*5;*6;Espaciopuerto;Instalaciones orbitales;;;;Códigos de productos;;;;;;;;;;;;;*7;*8;*9;*10
;;;;;;;;CC;PI;DS;AA;INDU;BASI;ALIM;MADE;AGUA;MICO;MIRA;MIPR;PAVA;A;AE;AEI;COM;;;;
Chipethea;111;NO;NO;SÍ;7;5+;MED-DB-2;NO;SÍ;NO;NO;X;X;X;X;X;X;;;;X;;;;1;10;7;10+
Bars 87;112;NO*;NO;SI;7;6+;NOT-DM-9;SI;NO;SI;NO;;X;X;;X;;;;;;;;;-7;12;9;6+
Vollurus;113;MF*;NO;SI;9;6+;MED-DM-6;NO;NO;SI;NO;;X;X;;X;;;;;;;;;-7;7;0;8+
Zibbichi;114;NO;NO;SI;1;7+;MED-DM-6;NO;SI;NO;NO;;;;;;;;;;;;;X;-11;6;9;7+
Thocinus;115;SO;NO;SI;5;0;BAS-DB-3;NO;SI;NO;NO;;;;;;;;;;;;;X;-11;11;10;7+
Sillon D138;116;TE;NO;SI;1;7+;BAS-DB-3;NO;NO;NO;NO;;;;;;;;;;;;;;-13;10;12;7+
Pundolla;121;NO/TA;NO;SI;4;0;MED-DM-6;NO;NO;NO;NO;X;X;X;X;X;X;;;;;;;;1;24;11;8+
Gnonoe GZ42;122;RE;NO;NO;8;6+;MED-DB-4;NO;NO;SI;NO;;;;;;;;;;;;;;-13;8;1;9+
Hiulara;123;RF;NO;SI;6;8+;BAS-DB-2;NO;SI;NO;NO;;;;;;;;;;;;;;-13;4;6;7+
Nutera;124;NO;NO;SI;4;7+;BAS-DB-6;NO;NO;NO;NO;X;X;X;X;X;X;X;;;X;;;;3;18;9;8+
Xonkilia;125;RE;NO;SI;2;0;NOT-DA-3;NO;SI;NO;NO;X;X;;;;;;;;;X;;;-5;11;9;5+
Deceter;126;MF*;NO;SI;6;5;MED-DB-12;NO;NO;NO;NO;;;;;;;;;;;;;;-13;18;6;7+
Yenia;131;MF;NO;NO;4;9;EXC-DA-24;NO;SI;NO;SI;X;X;;;;X;;;X;X;;;;-3;8;11;8+
Cosie RH;132;NO;SI;NO;4;0;NOT-DA-3;SI;NO;SI;NO;X;X;X;;X;X;X;X;;X;;;;5;16;11;9+
Cippe YCB;133;MF;NO;SI;4;7+;MED-DB-4;NO;NO;NO;NO;X;X;X;;X;X;X;X;;X;;;;3;14;11;8+
Ebbuatis;134;MF;SI;SI;5;9+;MED-DB-10;NO;NO;NO;NO;X;X;X;X;X;X;X;X;;X;;;;5;18;4;8+
Lecater;135;RF;NO;SI;4;0;MED-DM-6;NO;SI;NO;NO;;;;;;;;;;;;;;-13;14;11;7+
Coduthea;136;TE;NO;SI;8;0;NOT-DA-3;SI;NO;NO;NO;X;X;;;X;;;;X;;X;;X;-1;25;8;7+
Llov AEI;141;NO/TA;NO;SI;4;6+;EXC-DA-24;SI;SI;NO;SI;X;X;;;;X;;;X;;;;;-5;13;14;6+
Kepra;142;SO;NO;SI;4;8+;MED-DB-4;NO;SI;SI;NO;;;;;;;;;;;;;X;-11;14;3;5+
Chostrenerth;143;RF;NO;SI;11;6+;NOT-DM-15;SI;SI;NO;NO;;;;;;;;;;;;;;-13;16;13;6+
Tholmilia;144;RE;NO;SI;7;0;RUD-DB-0;NO;SI;NO;NO;;;;;;;;;;;;;;-13;11;6;7+
Chutragua;145;NO*;NO;SI;9;7+;NOT-DA-12;NO;NO;NO;NO;X;X;;;;;;;X;;X;X;;-3;13;8;7+
Gukoclite;146;MF;SI;NO;6;0;BAS-DB-3;NO;NO;NO;NO;X;X;X;;X;X;X;X;;X;;;;3;11;9;7+
Chore 3N07;151;MF*;NO;SI;6;0;MED-DB-8;NO;NO;NO;NO;;;;;;;;;;;;;;-13;22;15;6+
Tatroter;152;MF/TA;NO;SI;7;7+;MED-DB-10;NO;SI;NO;NO;;X;X;;X;;;;;;;;;-7;9;9;9+
Strikupra;153;NO*;NO;SI;11;6+;MED-DM-4;NO;NO;NO;NO;X;X;X;X;X;X;;;X;;;;X;3;17;10;6+
Gryke JQ69;154;MF*;NO;SI;6;6+;BAS-DB-4;NO;SI;NO;NO;;;;;;;;;;;;;;-13;16;9;6+
Trohanerth;155;NO;NO;SI;9;0;RUD-DB-0;NO;NO;NO;NO;X;X;X;X;X;X;;;;X;;;;1;2;11;8+
Lulveulia;156;TE;NO;SI;6;0;RUD-DB-0;NO;SI;NO;NO;;;;;;;;;;;;;;-13;15;10;7+
Drinda LSPH;161;TE;NO;NO;9;0;EXC-DA-8;SI;SI;NO;NO;X;X;;;;;;;X;;X;X;;-3;9;16;8+
Monoe JK35;162;MF*;NO;SI;6;0;BAS-DB-5;NO;NO;NO;NO;;;;;;;;;;;;;;-13;8;6;7+
Zarvis 1UU;163;MF*;NO;NO;2;6+;EXC-DA-20;NO;NO;SI;NO;X;X;X;X;X;;;;X;;X;X;;3;12;6;6+
Brapus L70;164;RE;NO;NO;6;7+;MED-DM-10;NO;NO;NO;NO;X;X;;;;X;;;X;;;;;-5;10;12;8+
Luna 4AC;165;SO;NO;SI;2;0;MED-DM-10;NO;SI;NO;NO;;;;;;;;;;;;;X;-11;8;7;7+
Zade V6R;166;TE;NO;SI;3;0;BAS-DB-5;NO;NO;NO;NO;;;;;X;;;;;;;;X;-9;8;8;7+
Crorix 5WU;211;RF;NO;NO;4;0;NOT-DM-18;SI;NO;NO;NO;;;;;;;;;;;;;X;-11;12;10;8+
Thunope;212;MF*;NO;SI;4;5+;MED-DB-2;NO;NO;SI;NO;;X;X;X;X;;;;;;;;;-5;20;5;9+
Mootune;213;MF;NO;NO;6;0;EXC-DA-24;SI;NO;SI;NO;X;X;X;X;X;X;X;;;X;;;;3;18;14;7+
Gippe 624;214;MF;NO;SI;4;9+;MED-DB-4;NO;SI;NO;NO;;;X;;X;;;;;;;;X;-7;6;8;9+
Pheshan Q18;215;TE;NO;SI;9;0;BAS-DB-5;NO;SI;NO;NO;;;;;;;;;;;;;;-13;8;8;7+
Abeitera;216;NO/TA*;SI;SI;3;5+;RUD-DB-0;NO;NO;NO;NO;X;X;X;;X;X;X;;;X;;;;1;13;9;8+
Buturn;221;NO/TA*;SI;SI;9;0;MED-DM-10;NO;SI;SI;NO;X;X;X;X;X;X;X;X;;X;;;;5;11;14;8+
Llyria 6HL1;222;NO;NO;SI;8;0;NOT-DM-9;NO;NO;NO;NO;;;;;;;;;;;;;;-13;25;17;6+
Chaenerth;223;RE;NO;SI;7;0;BAS-DB-3;NO;NO;NO;NO;;;;;;;;;;;;;X;-11;19;4;6+
Cinvagawa;224;NO*;NO;SI;3;6;RUD-DB-0;NO;NO;NO;NO;;;;;;;;;;;;;X;-11;11;10;8+
Oapra;225;NO/TA*;NO;SI;5;0;NOT-DM-3;NO;SI;SI;NO;;;;;;;;;;;;;;-13;11;9;8+
Gezeria;226;MF;NO;SI;8;6+;BAS-DB-6;NO;NO;NO;NO;;;X;X;X;;;;;;;;X;-5;17;7;6+
Elromia;231;RF;NO;SI;5;0;MED-DB-10;NO;NO;SI;NO;X;X;;;;X;;;X;X;;;;-3;20;11;7+
Ragnuwei;232;MF/TA*;NO;SI;3;0;NOT-DA-6;SI;SI;SI;NO;X;X;;;;;;;X;;X;X;;-3;10;8;7+
Gnora T9P7;233;SO;NO;SI;7;0;EXC-DA-8;NO;NO;SI;NO;X;X;;;;X;;;X;;X;X;X;1;18;14;7+
Vainus;234;MF/TA*;NO;SI;6;0;BAS-DB-1;NO;NO;NO;NO;;;X;X;X;;;;;;;;X;-5;22;19;7+
Gnixotov;235;SO;NO;SI;7;0;BAS-DB-2;NO;SI;NO;NO;;;;;;;;;;;;;X;-11;20;6;7+
Tadrapus;236;NO/TA*;NO;NO;3;0;MED-DB-10;NO;NO;NO;NO;;;;;;;;;;;;;;-13;5;13;6+
Sutera;241;NO;NO;NO;6;7+;BAS-DB-3;NO;SI;NO;NO;X;X;X;;X;X;;;X;;;;X;1;13;5;7+
Sulmiuq;242;MF/TA*;NO;SI;9;7+;NOT-DA-12;NO;SI;NO;SI;;X;X;;X;;;;;;;;;-7;12;0;8+
Gniri V4E;243;MF*;NO;SI;11;0;RUD-DB-0;NO;NO;NO;NO;;X;X;;X;;;;;;;;;-7;9;15;7+
Cezaogantu;244;NO;NO;SI;2;0;MED-DM-6;NO;NO;SI;NO;X;X;X;X;X;X;X;X;;X;;;;5;3;6;9+
Othurus;245;TA*;NO;SI;6;0;MED-DM-10;NO;NO;NO;NO;;;;;;;;;;;;;X;-11;6;14;7+
Ninda R5KZ;246;MF;NO;SI;5;0;EXC-DA-4;NO;NO;SI;NO;X;X;X;;X;X;X;;;X;;;;1;14;10;9+
Gogrion;251;TH;NO;SI;10;7+;NOT-DA-15;SI;NO;NO;NO;X;X;;;;;;;X;;X;X;X;-1;9;5;7+
Kunkoigantu;252;NO*;NO;SI;5;6+;NOT-DA-15;NO;NO;NO;NO;X;X;;;;X;;;X;;X;;;-3;10;8;5+
Yitherth;253;MF*;NO;SI;7;5+;MED-DM-10;NO;NO;SI;NO;;X;X;;X;;;;;;;;;-7;24;8;7+
Thichi 2IT;254;MF/TA*;NO;SI;5;8+;MED-DB-10;NO;NO;SI;NO;;X;X;X;X;;;;;;;;;-5;9;0;9+
Unragua;255;RE;NO;SI;6;0;NOT-DM-12;NO;SI;NO;NO;;;;;;;;;;;;;;-13;5;4;7+
Pucolla;256;NO/TA*;NO;SI;7;9+;EXC-DA-16;NO;SI;SI;NO;X;X;X;;X;X;;;X;X;X;X;;5;10;18;8+
Thumater;261;MF/TA*;NO;SI;4;9+;NOT-DA-6;SI;NO;NO;NO;X;X;;;;X;;;X;X;;;;-3;11;12;7+
Dater;262;NO*;NO;SI;9;9+;NOT-DA-9;NO;NO;SI;NO;X;X;X;;X;;;;X;;X;X;;1;14;4;8
Yuberon;263;RE;NO;SI;7;0;NOT-DM-3;NO;SI;NO;SI;;;;;;;;;;;;;;-13;21;27;6
Doaruta;264;MF;NO;SI;10;5+;EXC-DA-8;SI;NO;SI;SI;X;X;;;;X;;;X;X;X;;;-1;14;7;6+
Elveon;265;NO/TA;NO;SI;9;5+;BAS-DB-6;NO;SI;NO;NO;;;;;;;;;;;;;;-13;5;14;8+
Larvis Q6QZ;266;NO;NO;SI;3;0;BAS-DB-4;NO;NO;NO;NO;;;X;;X;;;;;;;;X;-7;12;11;8+
Austea;311;MF;SI;SI;8;0;NOT-DM-18;SI;NO;SI;NO;X;X;X;;X;X;X;X;;X;;;;3;8;16;8+
Caothea;312;MF;NO;SI;7;7+;NOT-DA-12;SI;NO;SI;SI;X;X;X;X;X;;;;X;;X;X;;3;11;9;6+
Vypso 0X2;313;TE;NO;NO;4;7+;RUD-DB-0;NO;NO;NO;NO;X;X;;;;X;;;X;;;;;-5;4;0;8+
Xuphinda;314;NO;NO;NO;8;0;BAS-DB-4;NO;SI;NO;NO;;;;;;;;;;;;;;-13;9;7;5+
Corth 14W;315;RE;NO;SI;3;0;NOT-DA-3;NO;NO;NO;NO;X;X;;;;;;;X;;X;;X;-3;25;18;8+
Chelrazuno;316;TE;NO;SI;8;0;0-0-0;NO;NO;NO;NO;;;;;X;;;;;;;;X;-9;5;8;8+
Migrion;321;MF/TA;NO;SI;2;5+;EXC-DA-8;SI;NO;SI;NO;;;;;;;;;;;;;;-13;22;5;7+
Gnichi OR2;322;MF*;NO;NO;7;9+;EXC-DA-12;SI;SI;NO;NO;X;X;;;;X;;;X;X;;;;-3;14;4;8+
Monerilia;323;TE;NO;SI;2;0;BAS-DB-1;NO;SI;NO;NO;;;;;;;;;;;;;;-13;4;11;7+
Yicreinus;324;MF;NO;SI;10;0;BAS-DB-1;NO;SI;NO;NO;;X;X;X;X;;;;;;;;;-5;5;8;8+
Chulinda;325;NO;SI;SI;8;5+;0-0-0;NO;NO;NO;NO;X;X;X;X;X;X;X;;;X;;;;3;9;8;7+
Rilvonov;326;MF;NO;SI;8;0;NOT-DM-6;NO;NO;NO;SI;;;;;;;;;;;;;;-13;13;15;7+
Xonninda;331;MF/TA;NO;SI;6;6+;NOT-DM-18;NO;SI;SI;SI;;X;X;;X;;;;;;;;;-7;6;9;7+
Vitis;332;NO/TA;NO;SI;8;7+;MED-DB-10;NO;SI;SI;NO;;;;;;;;;;;;;;-13;9;3;7+
Anus;333;NO;NO;NO;6;0;BAS-DB-4;NO;SI;NO;NO;;;X;X;X;;;;;;;;X;-5;15;7;9+
Pososie;334;MF;NO;SI;7;5+;BAS-DB-3;NO;SI;NO;NO;;;X;;X;;;;;;;;X;-7;15;7;10+
Nuna L4G;335;TH;NO;SI;4;0;BAS-DB-4;NO;SI;NO;NO;;;X;;X;;;;;;;;X;-7;8;10;8+
Curn 8G1;336;NO*;NO;SI;8;0;BAS-DB-1;NO;NO;NO;NO;;;;;;;;;;;;;;-13;20;10;7+
Revis;341;RE;NO;SI;11;0;RUD-DB-0;NO;SI;NO;NO;;;;;;;;;;;;;X;-11;17;11;6+
Larth N70N;342;MF/TA;NO;SI;8;0;NOT-DA-15;SI;NO;SI;NO;X;X;;;;;;;X;;X;X;;-3;16;7;7+
Chulniegawa;343;RF;NO;SI;1;5+;MED-DM-10;NO;SI;NO;NO;;;;;;;;;;;;;;-13;21;8;5+
Soyama;344;NO;NO;SI;8;0;MED-DM-4;NO;SI;SI;NO;X;X;X;X;X;X;;;;X;;;;1;11;13;9+
Conus;345;MF*;NO;SI;4;0;0-0-0;NO;NO;NO;NO;;;X;X;X;;;;;;;;X;-5;11;6;8+
Gecanov;346;TA*;NO;SI;11;6+;NOT-DA-6;SI;SI;SI;NO;;;;;;;;;;;;;X;-11;20;14;7+
Misorus;351;MF;NO;NO;8;0;NOT-DA-12;SI;NO;NO;NO;X;X;X;X;X;X;X;X;;X;;;;5;29;12;8+
Relriahiri;352;MF;NO;NO;9;0;RUD-DB-0;NO;NO;NO;NO;;;X;X;X;;;;;;;;X;-5;6;7;9+
Mozuatune;353;TA*;NO;SI;6;0;EXC-DA-4;SI;NO;SI;NO;;;;;;;;;;;;;X;-11;12;14;6+
Kalroagawa;354;NO/TA;NO;SI;4;7+;NOT-DA-9;NO;NO;NO;NO;X;X;X;X;X;X;;;X;;;;X;3;13;9;7+
Kebbichi;355;MF;SI;SI;7;7+;RUD-DB-0;NO;SI;NO;NO;X;X;X;X;X;X;X;X;;X;;;;5;13;10;10+
Theccorth;356;TE;NO;SI;6;0;NOT-DA-3;SI;NO;SI;NO;X;X;;;;;;;X;;X;;;-5;28;12;8+
Lubrerth;361;MF*;NO;SI;5;0;RUD-DB-0;NO;SI;NO;NO;;X;X;;X;;;;;;;;;-7;4;10;8+
Zunkienope;362;TE;NO;SI;5;8+;MED-DM-2;NO;NO;NO;NO;;;;;;X;X;;;;;;;-9;5;5;8+
Totreron;363;MF/TA;NO;SI;3;9+;EXC-DA-4;SI;SI;SI;NO;X;X;;;;X;;;X;X;;;;-3;6;8;9+
Thacratera;364;NO*;NO;SI;4;0;MED-DM-2;NO;SI;NO;NO;;X;X;;X;;;;;;;;;-7;12;5;9+
Atriri;365;RE;NO;SI;7;0;MED-DM-2;NO;SI;SI;NO;;;;;;;;;;;;;;-13;14;10;8+
Agnao;366;RF;NO;SI;9;6+;MED-DM-8;NO;SI;SI;NO;;;;;;;;;;;;;X;-11;13;7;7+
Earia;411;RE;NO;SI;9;0;BAS-DB-4;NO;SI;NO;NO;;;;;;;;;;;;;;-13;4;4;7+
Siotov;412;MF;SI;SI;3;0;MED-DB-12;NO;NO;NO;NO;X;X;X;X;X;X;X;;;X;;;;3;15;12;9+
Cudihines;413;RF;NO;SI;6;8+;EXC-DA-16;SI;NO;NO;NO;X;X;;;;X;;;X;X;X;;;-1;16;2;7+
Gupheon;414;TE;NO;SI;6;9+;RUD-DB-0;NO;SI;NO;NO;X;X;;;;X;;;X;X;;;;-3;14;0;9+
Linzora;415;NO*;NO;SI;2;0;MED-DB-6;NO;SI;NO;NO;;X;X;;X;;;;;;;;;-7;12;14;7+
Cuehines;416;NO/TA;NO;NO;5;0;BAS-DB-1;NO;SI;NO;NO;X;X;X;X;X;X;X;;;X;;;;3;18;14;6+
Biri 3TNU;421;MF;NO;NO;9;9+;MED-DB-8;NO;NO;NO;NO;X;X;X;X;X;X;X;X;;X;;;X;7;20;6;8+
Cevinus;422;TH*;NO;SI;10;7+;RUD-DB-0;NO;SI;NO;NO;;;X;X;X;;;;;;;;X;-5;11;0;7+
Pephyke;423;NO/TA;SI;SI;5;6+;BAS-DB-1;NO;NO;NO;NO;X;X;X;;X;X;X;X;;X;;;;3;19;6;8+
Zidichi;424;NO/TA;NO;NO;6;0;MED-DB-8;NO;NO;NO;NO;X;X;X;;X;X;;;;X;;;;-1;9;6;9+
Chognunus;425;NO*;NO;SI;5;0;SIN;NO;NO;NO;NO;X;X;X;X;X;X;;;;X;;;;1;6;12;9+
Unreinus;426;NO/TA;NO;SI;6;0;BAS-DB-2;NO;NO;NO;NO;;;;;;;;;;;;;X;-11;14;7;7+
Gimigantu;431;RF;NO;SI;9;0;NOT-DA-6;NO;SI;SI;NO;X;X;;;;;;;X;;X;;X;-3;16;16;7+
Hiohiri;432;MF;NO;SI;10;9+;MED-DB-4;NO;SI;NO;NO;X;X;;;;X;;;X;X;;;;-3;10;7;6+
Thierilia;433;MF;NO;SI;2;0;MED-DM-4;NO;SI;SI;NO;;;X;X;X;;;;;;;;X;-5;17;21;10+
Yastrarus;434;NO;NO;NO;5;9+;MED-DB-10;NO;SI;SI;NO;;;;;;;;;;;;;;-13;13;3;7+
Struraliv;435;NO*;NO;SI;9;7+;BAS-DB-6;NO;SI;NO;NO;;X;X;;X;;;;;;;;;-7;17;3;7+
Cheiliv;436;MF/TA*;NO;SI;5;5+;RUD-DB-0;NO;NO;NO;NO;;;X;X;X;;;;;;;;X;-5;4;11;7+
Lleshan FDK;441;RE;NO;SI;5;0;MED-DM-10;NO;SI;NO;NO;;;;;;;;;;;;;;-13;6;10;8+
Lapus X6G3;442;MF;NO;SI;7;0;RUD-DB-0;NO;NO;NO;NO;;;;;;;;;;;;;X;-11;5;9;8+
Tulnion;443;SO;NO;SI;5;0;NOT-DA-6;SI;NO;NO;NO;X;X;;;;;;;X;;X;;X;-3;10;15;7+
Unkadus;444;NO*;NO;NO;6;6+;NOT-DM-15;SI;NO;SI;SI;X;X;;;;X;;;X;;;;;-5;28;10;6+
Cehotov;445;RF;NO;SI;3;6+;RUD-DB-0;NO;NO;NO;NO;X;X;;;;;;;X;;X;X;X;-1;8;10;6+
Pitronoe;446;NO;NO;NO;5;7+;NOT-DA-18;SI;SI;NO;NO;X;X;X;;X;X;X;;;X;;;;1;10;12;8+
Sicumia;451;NO*;NO;SI;4;0;BAS-DB-3;NO;SI;NO;NO;;;;;;;;;;;;;;-13;12;12;7+
Chitricarro;452;MF;NO;SI;2;8+;MED-DB-4;NO;SI;NO;NO;X;X;X;;X;X;X;;;X;;;X;3;4;4;9+
Trivitis;453;TA*;NO;SI;7;0;RUD-DB-0;NO;SI;NO;NO;;;;;;;;;;;;;X;-11;5;6;8+
Lotinia;454;MF;NO;SI;9;7+;BAS-DB-2;NO;NO;NO;NO;X;X;;;;X;;;X;X;;;;-3;16;10;6+
Rolnuegawa;455;MF;NO;SI;7;7+;MED-DM-2;NO;SI;SI;NO;;X;X;;X;;;;;;;;;-7;4;4;7+
Xoyama;456;TE;NO;SI;7;9+;NOT-DA-9;SI;SI;SI;NO;X;X;;;;X;;;X;X;X;X;;1;10;7;8+
Eiter;461;MF/TA;NO;SI;8;0;BAS-DB-1;NO;SI;NO;NO;;X;X;;X;;;;;;;;;-7;20;22;8+
Chuphiephus;462;NO*;NO;NO;8;0;RUD-DB-0;NO;NO;NO;NO;;;;;;;;;;;;;X;-11;10;8;9+
Xabrao;463;TE;NO;SI;11;0;NOT-DA-15;NO;NO;SI;NO;X;X;;;;;;;X;;X;;;-5;19;8;8+
Zenkuathea;464;TE;NO;SI;5;8+;BAS-DB-6;NO;NO;NO;NO;;;;;;;;;;;;;;-13;11;6;6+
Yutreiruta;465;TH*;NO;SI;6;7+;BAS-DB-3;NO;NO;NO;NO;;;;;;;;;;;;;X;-11;8;7;6+
Bretobos;466;RF;NO;SI;4;0;EXC-DA-20;SI;NO;NO;NO;X;X;;;;;;;X;;X;X;;-3;12;2;9+
Jujava 29A;511;NO/TA*;NO;NO;9;7+;RUD-DB-0;NO;NO;NO;NO;;;;;;;;;;;;;;-13;10;1;8+
Aselea;512;SO;NO;SI;2;0;MED-DB-2;NO;SI;SI;NO;;;;;;;;;;;;;X;-11;7;5;7+
Strevunope;513;MF*;NO;SI;9;0;BAS-DB-5;NO;NO;NO;NO;;X;X;X;X;;;;;;;;;-5;8;12;8+
Cebbagantu;514;MF;NO;SI;2;0;MED-DB-10;NO;NO;NO;NO;;;X;;X;;X;;;;;;X;-5;16;9;9+
Trillon 8UP1;515;RF;NO;SI;5;0;NOT-DA-18;SI;SI;SI;SI;X;X;;;;;;;X;;X;X;;-3;16;17;8+
Ethuna;516;RF;NO;SI;7;0;NOT-DM-15;NO;NO;NO;NO;X;X;;;;X;;;X;X;;;;-3;18;11;7+
Rognuephus;521;TE;NO;SI;9;0;MED-DB-12;NO;NO;SI;NO;X;X;;;;X;;;X;X;;;;-3;19;9;6+
Strorix DWD;522;RE;NO;NO;6;0;BAS-DB-6;NO;NO;NO;NO;;;;;;;;;;;;;;-13;8;20;6+
Meonus;523;TE;NO;SI;10;0;0-0-0;NO;NO;NO;NO;;;;;;;;;;;;;;-13;11;12;6+
Tiophus;524;RE;NO;SI;9;0;BAS-DB-3;NO;NO;NO;NO;;;;;;;;;;;;;;-13;9;10;7+
Reanus;525;TE;NO;NO;7;9+;NOT-DA-6;SI;NO;NO;NO;X;X;;;;;;;X;;X;;;-5;17;0;6+
Vapus 8U0E;526;MF;NO;SI;7;6;RUD-DB-0;NO;SI;NO;NO;X;X;;;;X;;;X;X;;;;-3;13;16;6+
Malara;531;TA*;NO;SI;8;7+;BAS-DB-5;NO;SI;NO;NO;;;;;;;;;;;;;X;-11;4;3;8+
Rimia;532;SO;NO;SI;4;0;MED-DB-6;NO;NO;NO;NO;;;;;;;;;;;;;X;-11;14;5;8+
Agreron;533;MF/RE*;NO;SI;2;0;BAS-DB-2;NO;NO;NO;NO;;X;X;X;X;;;;;;;;;-5;19;7;7+
Yuziri;534;TE;NO;SI;7;9+;RUD-DB-0;NO;NO;NO;NO;X;X;;;;X;;;X;X;;;;-3;9;5;7+
Droria 64YN;535;TE;NO;SI;6;7+;NOT-DA-18;SI;NO;NO;NO;X;X;;;;X;;;X;X;X;X;;1;12;4;6+
Zochoter;536;RF;NO;SI;10;6+;0-0-0;NO;NO;NO;NO;;;;;;;;;;;;;;-13;9;7;8+
Yingetera;541;NO;SI;SI;4;7+;EXC-DA-8;SI;NO;NO;NO;X;X;X;;X;X;X;;;X;;;;1;12;10;9+
Rogreunov;542;TE;NO;SI;7;0;NOT-DA-15;SI;NO;NO;NO;;;;;;;;;;;;;;-13;27;12;7+
Nuphus;543;NO;NO;SI;6;0;BAS-DB-1;NO;NO;NO;NO;X;X;X;;X;X;;;X;;;;X;1;13;9;6+
Rindars;544;TA*;NO;SI;4;5+;RUD-DB-0;NO;NO;NO;NO;;;;;;;;;;;;;X;-11;15;6;8+
Haria;545;RE;NO;SI;4;0;BAS-DB-2;NO;SI;NO;NO;;;;;;;;;;;;;;-13;12;12;6+
Begantu;546;MF*;NO;SI;5;6+;NOT-DM-18;SI;NO;NO;SI;;X;X;X;X;;;;;;;;;-5;9;6;10+
Criguphus;551;MF/TA;NO;SI;7;0;MED-DB-12;NO;SI;SI;NO;;;;;;;;;;;;;;-13;9;7;5+
Miinerth;552;NO*;NO;NO;8;0;BAS-DB-4;NO;NO;NO;NO;;X;X;X;X;;;;;;;;;-5;8;9;8+
Phore 790;553;MF;NO;SI;5;0;BAS-DB-4;NO;NO;NO;NO;;;;;;;;;;;;;;-13;9;11;8+
Tanguibos;554;NO;NO;SI;6;6+;RUD-DB-0;NO;NO;NO;NO;X;X;X;;X;X;;;;X;;;;-1;11;6;7+
Igypso;555;MF*;NO;SI;7;0;BAS-DB-1;NO;SI;NO;NO;;;X;;X;;;;;;;;X;-7;12;8;8+
Bamewei;556;MF/TA;NO;NO;8;9+;NOT-DA-18;NO;NO;NO;SI;X;X;;;;X;;;X;X;X;;;-1;16;11;8+
Genrolla;561;NO;NO;SI;7;7+;EXC-DA-16;SI;NO;SI;NO;X;X;X;X;X;X;X;X;;X;;;;5;16;11;10+
Diri B27A;562;RF;NO;SI;5;0;BAS-DB-3;NO;SI;NO;NO;;;;;;;;;;;;;;-13;16;8;8+
Onroth;563;MF*;NO;SI;1;8+;BAS-DB-6;NO;SI;NO;NO;;;;;;;;;;;;;X;-11;13;13;8+
Sinzorix;564;MF;NO;SI;5;8+;MED-DM-10;NO;NO;SI;NO;X;X;X;;X;X;X;X;;X;;;X;5;6;0;8+
Cunrolea;565;NO/TA*;NO;SI;5;0;0-0-0;NO;NO;NO;NO;;;;;;;;;;;;;X;-11;4;7;8+
Miphomia;566;TE;NO;SI;7;5+;NOT-DM-6;NO;SI;NO;NO;;;;;;;;;;;;;;-13;13;19;7+
Hedraenus;611;NO*;NO;SI;9;0;MED-DB-12;NO;NO;SI;NO;;X;X;X;X;;;;;;;;;-5;11;9;7+
Didrapra;612;NO/TA;NO;SI;11;0;RUD-DB-0;NO;SI;NO;NO;X;X;X;;X;X;;;;X;;;;-1;21;17;8+
Thastrypso;613;SO;NO;SI;10;5+;MED-DB-10;NO;NO;NO;NO;;;;;;;;;;;;;X;-11;14;6;6+
Methoter;614;NO;SI;SI;6;5+;MED-DM-10;NO;SI;SI;NO;X;X;X;X;X;X;X;;;X;;;;3;12;16;8+
Suzebos;615;NO/TA;NO;SI;8;9+;RUD-DB-0;NO;NO;NO;NO;X;X;X;X;X;X;;;;X;;;;1;12;0;10+
Troiter;616;TE;NO;SI;5;7+;EXC-DA-20;NO;NO;SI;NO;X;X;;;;;;;X;;X;X;;-3;14;13;6+
Stregenus;621;TH;NO;NO;1;9+;NOT-DM-18;SI;NO;NO;NO;X;X;;;;X;;;X;;;;X;-3;17;6;9+
Yothion;622;NO/TA;NO;SI;7;7+;BAS-DB-5;NO;NO;NO;NO;X;X;X;X;X;X;;;;X;;;;1;3;7;8+
Pungomia;623;MF*;NO;SI;8;9+;NOT-DM-9;SI;NO;SI;NO;X;X;;;;X;;;X;X;;;;-3;17;14;9+
Tholoria;624;TE;NO;SI;8;7+;RUD-DB-0;NO;SI;NO;NO;;;;;;;;;;;;;;-13;11;2;7+
Grourilia;625;MF*;NO;SI;5;0;NOT-DM-3;SI;SI;NO;NO;;X;X;;X;;;;;;;;;-7;11;12;8+
Zibbeter;626;MF*;NO;SI;2;7+;EXC-DA-4;SI;NO;SI;NO;X;X;;;;X;;;X;X;;;;-3;23;8;6+
Thoc;631;RE;NO;SI;8;9+;EXC-DA-16;SI;NO;NO;NO;X;X;;;;X;;;X;;X;;X;-1;10;10;7+
Kubbars;632;NO;NO;SI;10;9+;MED-DM-10;NO;NO;NO;NO;X;X;;;;X;;;X;;;;;-5;12;12;8+
Telmyria;633;MF*;NO;SI;2;7+;BAS-DB-4;NO;SI;NO;NO;;;;;;;;;;;;;;-13;15;8;7+
Thoter;634;TE;NO;SI;1;9+;NOT-DA-12;NO;SI;NO;NO;X;X;;;;;;;X;;X;X;;-3;12;12;8+
Outis;635;TE;NO;NO;2;0;NOT-DM-3;SI;SI;NO;NO;;;;;;X;X;;;;;;;-9;19;10;8+
Sucreyama;636;TE;NO;SI;7;8+;EXC-DA-20;SI;SI;SI;NO;;;;;;;;;;;;;;-13;6;6;6+
Xicoatania;641;NO*;NO;SI;5;9+;RUD-DB-0;NO;SI;NO;NO;X;X;X;;X;X;;;;X;;;;-1;6;2;9+
Dunouca;642;RF;NO;SI;6;0;NOT-DA-6;NO;NO;SI;NO;X;X;;;;;;;X;;X;X;;-3;9;16;8+
Llade J37M;643;RF;NO;SI;6;0;MED-DM-4;NO;NO;SI;NO;;;;;;;;;;;;;;-13;19;6;6+
Tenkoiter;644;NO*;NO;NO;6;7+;RUD-DB-0;NO;SI;NO;NO;X;X;X;X;X;X;;;;X;;;;1;7;14;8+
Xelmaiter;645;NO;NO;SI;5;7+;BAS-DB-5;NO;NO;NO;NO;;X;X;X;X;;;;;;;;;-5;10;6;8+
Gnochacarro;646;NO;NO;SI;5;9+;NOT-DA-12;SI;NO;NO;NO;X;X;;;;;;;X;;X;X;;-3;8;6;6+
Crabitania;651;TA*;NO;SI;4;7+;NOT-DA-3;NO;NO;NO;NO;X;X;;;;;;;X;;X;X;X;-1;18;9;8+
Uliv;652;TE;NO;SI;6;0;BAS-DB-1;NO;NO;NO;NO;;;;;;;;;;;;;;-13;6;5;6+
Tinus;653;MF/TA;NO;SI;8;5+;NOT-DM-15;NO;NO;NO;NO;;;X;;X;;;;;;;;X;-7;6;13;8+
Eatov;654;NO;NO;NO;9;5+;BAS-DB-5;NO;SI;NO;NO;X;X;X;;X;X;X;X;;X;;;;3;12;12;8+
Vekerus;655;TH*;NO;SI;5;6+;BAS-DB-4;NO;SI;NO;NO;X;X;;;;X;;;X;;;;X;-3;10;8;8+
Boyutania;656;NO/TA;NO;NO;5;0;MED-DB-10;NO;NO;SI;NO;X;X;X;;X;X;;;;X;;;;-1;20;7;7+
Pubrara;661;NO*;NO;SI;3;7+;0-0-0;NO;SI;NO;NO;;X;X;;X;;;;;;;;;-7;10;0;9+
Lluostea;662;RF;NO;SI;6;0;MED-DB-2;NO;NO;SI;NO;X;X;;;;X;;;X;X;;;;-3;26;9;7+
Chiyitune;663;NO/TA;NO;SI;5;0;MED-DB-8;NO;SI;NO;NO;X;X;X;;X;X;X;X;;X;;;;3;10;5;8+
Bruvaria;664;MF*;NO;SI;9;9+;EXC-DA-12;SI;NO;NO;NO;X;X;;;;X;;;X;X;;;;-3;9;9;7+
Naipra;665;NO/TA;SI;SI;7;7+;NOT-DM-9;SI;SI;SI;NO;X;X;X;X;X;X;X;X;;X;;;;5;13;8;9+
Vilecarro;666;NO;SI;SI;7;6+;MED-DB-8;NO;NO;NO;NO;X;X;X;;X;X;X;;;X;;;;1;15;8;9+''';
