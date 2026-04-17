import 'package:flutter/material.dart';

import 'package:spacegom_companion/models/area_sheet.dart';
import 'package:spacegom_companion/models/board_state.dart';
import 'package:spacegom_companion/models/cell_data.dart';
import 'package:spacegom_companion/models/name_database.dart';
import 'package:spacegom_companion/models/planet.dart';
import 'package:spacegom_companion/widgets/area_grid.dart';

class BoardScreen extends StatefulWidget {
  final BoardState initialState;
  final ValueChanged<BoardState> onChanged;
  final VoidCallback? onOpenCalendar;
  final void Function(int area)? onOpenAreaSheet;
  final int currentMonth;
  final int currentDay;
  final int currentYear;

  const BoardScreen({
    super.key,
    required this.initialState,
    required this.onChanged,
    this.onOpenCalendar,
    this.onOpenAreaSheet,
    this.currentMonth = 1,
    this.currentDay = 1,
    this.currentYear = 1,
  });

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> with AutomaticKeepAliveClientMixin {
  late int _shipArea;
  late int _shipRow;
  late int _shipCol;
  late int _hyperjumpDays;
  late Map<int, Map<(int, int), CellData>> _areaCells;
  late Map<int, AreaDensity> _areaDensity;
  late Map<int, int> _customHyperjumpDays;
  late Map<int, int> _customMissions;

  int _viewingArea = 1;
  LocationType? _selectedLocation;

  static LocationType? _locationFromString(String? s) {
    if (s == null) return null;

    return LocationType.values.where((e) => e.name == s).firstOrNull;
  }

  @override
  void initState() {
    super.initState();

    _shipArea = widget.initialState.shipArea;
    _shipRow = widget.initialState.shipRow;
    _shipCol = widget.initialState.shipCol;
    _hyperjumpDays = widget.initialState.hyperjumpDays;
    _areaCells = Map.from(widget.initialState.areaCells);
    _areaDensity = Map.from(widget.initialState.areaDensity);
    _customHyperjumpDays = Map.from(widget.initialState.customHyperjumpDays);
    _customMissions = Map.from(widget.initialState.customMissions);
    _selectedLocation = _locationFromString(widget.initialState.selectedLocation);
    _viewingArea = _shipArea;
  }

  Map<(int, int), CellData> get _currentCells => _areaCells[_viewingArea] ?? {};

  Set<String> _megacorpNamesInArea(int area) {
    final cells = _areaCells[area];
    if (cells == null) return {};

    return cells.values
        .map((c) => c.megacorporation)
        .where((name) => name.isNotEmpty)
        .toSet();
  }

  Map<String, int> get _allMegacorpNumbers {
    final numbers = <String, int>{};
    var nextNumber = 1;

    for (final cells in _areaCells.values) {
      for (final cell in cells.values) {
        final name = cell.megacorporation;
        if (name.isEmpty || numbers.containsKey(name)) continue;

        numbers[name] = nextNumber++;
      }
    }

    return numbers;
  }

  BoardState _buildState() {
    return BoardState(
      shipArea: _shipArea,
      shipRow: _shipRow,
      shipCol: _shipCol,
      hyperjumpDays: _hyperjumpDays,
      areaCells: Map.from(_areaCells),
      areaDensity: Map.from(_areaDensity),
      customHyperjumpDays: Map.from(_customHyperjumpDays),
      customMissions: Map.from(_customMissions),
      selectedLocation: _selectedLocation?.name,
    );
  }

  int? _missionsForSection(int sectionNumber) {
    return _customMissions[sectionNumber] ?? PlanetDatabase.planets[sectionNumber]?.parsedMissions;
  }

  void _seedMissionsForSection(int sectionNumber) {
    if (_customMissions.containsKey(sectionNumber)) return;

    final parsed = PlanetDatabase.planets[sectionNumber]?.parsedMissions;
    if (parsed != null) _customMissions[sectionNumber] = parsed;
  }

  void _notifyChanged() => widget.onChanged(_buildState());

  bool get _viewingShipArea => _viewingArea == _shipArea;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildTopBar(),

          const SizedBox(height: 8),

          _buildBoardWithArrows(),

          const SizedBox(height: 8),

          _buildShipLocation(),

          _buildAreaPlanets(),

          _buildAreaMegacorps(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        _buildDateField(),

        const SizedBox(width: 4),

        _buildDensityChip(),

        const Spacer(),

        _buildAreaSelector(),
      ],
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () => widget.onOpenCalendar?.call(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF30363D)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            const Text(
              'FECHA',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF8B949E)),
            ),

            Text(
              '${widget.currentDay.toString().padLeft(2, '0')}/${widget.currentMonth.toString().padLeft(2, '0')}/${widget.currentYear.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDensityChip() {
    final density = _areaDensity[_viewingArea];
    final label = switch (density) {
      AreaDensity.low => 'Baja',
      AreaDensity.medium => 'Media',
      AreaDensity.high => 'Alta',
      null => '—',
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _showDensityDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF30363D)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                const Text(
                  'DENSIDAD',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF8B949E)),
                ),

                Text(
                  label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),

        IconButton(
          onPressed: () => widget.onOpenAreaSheet?.call(_viewingArea),
          icon: const Icon(Icons.description_outlined, size: 18, color: Color(0xFF8B949E)),
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildAreaSelector() {
    final isViewingOther = !_viewingShipArea;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: isViewingOther ? const Color(0xFFE8B830) : const Color(0xFF30363D)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'ÁREA',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF8B949E)),
          ),

          const SizedBox(width: 4),

          IconButton(
            onPressed: _viewingArea > 1 ? () => setState(() => _viewingArea--) : null,
            icon: const Text('<', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2EA043))),
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            padding: EdgeInsets.zero,
          ),

          SizedBox(
            width: 32,
            child: Center(
              child: Text(
                '$_viewingArea',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          IconButton(
            onPressed: _viewingArea < 11 ? () => setState(() => _viewingArea++) : null,
            icon: const Text('>', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2EA043))),
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildBoardWithArrows() {
    return Column(
      children: [
        _buildArrowButton(Icons.arrow_drop_up, _moveNorth),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildArrowButton(Icons.arrow_left, _moveWest),

            Expanded(
              child: AreaGrid(
                cells: _currentCells,
                onCellTap: _onCellTap,
                onCellLongPress: _onCellLongPress,
                shipPosition: _viewingShipArea ? (_shipRow, _shipCol) : null,
                megacorpNumbers: _allMegacorpNumbers,
              ),
            ),

            _buildArrowButton(Icons.arrow_right, _moveEast),
          ],
        ),

        _buildArrowButton(Icons.arrow_drop_down, _moveSouth),
      ],
    );
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: const Color(0xFF484F58), size: 40),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildShipLocation() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'UBICACIÓN DE LA NAVE',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8B949E)),
          ),

          const SizedBox(height: 6),

          _buildTypeIndicators(),

          _buildCurrentPlanetInfo(),
        ],
      ),
    );
  }

  Widget _buildTypeIndicators() {
    return Row(
      children: [
        Expanded(child: _buildIndicatorChip('MUNDO', const Color(0xFF8B949E), LocationType.world)),
        const SizedBox(width: 3),
        Expanded(child: _buildIndicatorChip('ESPACIO.', const Color(0xFF58A6FF), LocationType.spaceport)),
        const SizedBox(width: 3),
        Expanded(child: _buildIndicatorChip('ORBITAL', const Color(0xFFBC8CFF), LocationType.orbitalStation)),
        const SizedBox(width: 3),
        _buildHyperjumpIndicator(),
        const SizedBox(width: 3),
        Expanded(child: _buildIndicatorChip('HIPERDISP.', const Color(0xFFE8B830), LocationType.hyperjump)),
      ],
    );
  }

  Widget _buildIndicatorChip(String label, Color color, LocationType type) {
    final isSelected = _selectedLocation == type;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedLocation = isSelected ? null : type;
        _notifyChanged();
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.25) : Colors.transparent,
          border: Border.all(color: isSelected ? color : const Color(0xFF30363D)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isSelected ? color : const Color(0xFF8B949E),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildHyperjumpIndicator() {
    return GestureDetector(
      onTap: _editHyperjumpDays,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          '↔*$_hyperjumpDays',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _updateHyperjumpDaysFromPosition() {
    final cellData = _areaCells[_shipArea]?[(_shipRow, _shipCol)];
    final sectionNumber = cellData?.sectionNumber;

    if (sectionNumber == null) return;

    _hyperjumpDays = _hyperjumpDaysForSection(sectionNumber);
  }

  int _hyperjumpDaysForSection(int sectionNumber) {
    final custom = _customHyperjumpDays[sectionNumber];

    if (custom != null) return custom;

    final planet = PlanetDatabase.planets[sectionNumber];

    return planet?.hyperjumpDays ?? _hyperjumpDays;
  }

  void _moveShip(int dRow, int dCol) {
    setState(() {
      if (!_viewingShipArea) {
        _viewingArea = _shipArea;

        return;
      }

      final newRow = _shipRow + dRow;
      final newCol = _shipCol + dCol;

      if (newCol < 1 && _shipArea > 1) {
        _shipArea--;
        _viewingArea = _shipArea;
        _shipCol = 6;
        _updateHyperjumpDaysFromPosition();
        _notifyChanged();

        return;
      }

      if (newCol > 6 && _shipArea < 11) {
        _shipArea++;
        _viewingArea = _shipArea;
        _shipCol = 1;
        _updateHyperjumpDaysFromPosition();
        _notifyChanged();

        return;
      }

      _shipRow = newRow.clamp(1, 6);
      _shipCol = newCol.clamp(1, 6);
      _updateHyperjumpDaysFromPosition();
      _notifyChanged();
    });
  }

  void _moveNorth() => _moveShip(-1, 0);
  void _moveSouth() => _moveShip(1, 0);
  void _moveWest() => _moveShip(0, -1);
  void _moveEast() => _moveShip(0, 1);

  void _onCellTap(int row, int col) {
    final existing = _currentCells[(row, col)];

    if (existing != null && !existing.isDeepSpace) {
      _showPlanetDetail(existing.sectionNumber!);

      return;
    }

    if (existing != null && existing.isDeepSpace) {
      _showCellOptionsDialog(row, col, existing);

      return;
    }

    _showNewCellDialog(row, col);
  }

  void _onCellLongPress(int row, int col) {
    final existing = _currentCells[(row, col)];

    if (existing == null) return;

    _showCellOptionsDialog(row, col, existing);
  }

  void _showNewCellDialog(int row, int col) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Tipo de cuadrante'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              _showSectionDialog(row, col);
            },
            child: const Row(
              children: [
                Icon(Icons.public, size: 20, color: Color(0xFF58A6FF)),
                SizedBox(width: 8),
                Text('Mundo'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              setState(() {
                _areaCells.putIfAbsent(_viewingArea, () => {});
                _areaCells[_viewingArea]![(row, col)] = CellData.deepSpace();
                _notifyChanged();
              });
              Navigator.pop(ctx);
            },
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, size: 20, color: Color(0xFF30363D)),
                SizedBox(width: 8),
                Text('Espacio profundo'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCellOptionsDialog(int row, int col, CellData cellData) {
    final title = cellData.isDeepSpace
        ? 'Espacio profundo'
        : 'Mundo ${cellData.sectionNumber}';

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(title),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              _showEditSectionDialog(row, col, cellData);
            },
            child: const Text('Editar'),
          ),
          SimpleDialogOption(
            onPressed: () {
              setState(() {
                _areaCells[_viewingArea]?.remove((row, col));
                _notifyChanged();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Borrar', style: TextStyle(color: Color(0xFFDA3633))),
          ),
        ],
      ),
    );
  }

  void _showEditSectionDialog(int row, int col, CellData cellData) {
    final controller = TextEditingController(
      text: cellData.sectionNumber != null ? '${cellData.sectionNumber}' : '',
    );
    final megacorpController = TextEditingController(text: cellData.megacorporation);
    final notesController = TextEditingController(text: cellData.notes);
    var pirates = cellData.pirates;
    var isDeepSpace = cellData.isDeepSpace;
    String? errorText;
    var missionValue = cellData.sectionNumber != null
        ? (_missionsForSection(cellData.sectionNumber!) ?? 0)
        : 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isDeepSpace ? 'Editar espacio profundo' : 'Editar mundo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isDeepSpace) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'Nº mundo',
                            errorText: errorText,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      IconButton(
                        icon: const Icon(Icons.casino),
                        tooltip: 'Tirada aleatoria (3d6)',
                        onPressed: () {
                          final code = PlanetDatabase.randomSectionNumber();
                          controller.text = '$code';
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                ],

                Row(
                  children: [
                    const Text('Piratas'),
                    const Spacer(),
                    Switch(
                      value: pirates,
                      onChanged: (v) => setDialogState(() => pirates = v),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: megacorpController,
                        decoration: const InputDecoration(labelText: 'Megacorporación'),
                      ),
                    ),

                    const SizedBox(width: 8),

                    IconButton(
                      icon: const Icon(Icons.casino_outlined),
                      tooltip: 'Nombre aleatorio',
                      onPressed: () {
                        megacorpController.text = NameDatabase.randomMegacorpName();
                      },
                    ),
                  ],
                ),

                if (!isDeepSpace) ...[
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Text('Misiones'),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => setDialogState(() {
                          if (missionValue > 0) missionValue--;
                        }),
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '$missionValue',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setDialogState(() => missionValue++),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notas'),
                  maxLines: 4,
                  minLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (!isDeepSpace) {
                  final number = int.tryParse(controller.text);
                  if (number == null) return;

                  final existingArea = _findExistingSection(number);
                  if (existingArea != null && number != cellData.sectionNumber) {
                    setDialogState(() {
                      errorText = 'Este mundo ya está en el área $existingArea';
                    });

                    return;
                  }
                }

                setState(() {
                  _areaCells.putIfAbsent(_viewingArea, () => {});

                  if (isDeepSpace) {
                    _areaCells[_viewingArea]![(row, col)] = CellData.deepSpace(
                      pirates: pirates,
                      megacorporation: megacorpController.text.trim(),
                      notes: notesController.text.trim(),
                    );
                  } else {
                    final number = int.tryParse(controller.text)!;
                    final sectionChanged = number != cellData.sectionNumber;

                    _areaCells[_viewingArea]![(row, col)] = CellData(
                      sectionNumber: number,
                      pirates: pirates,
                      megacorporation: megacorpController.text.trim(),
                      notes: notesController.text.trim(),
                    );

                    if (sectionChanged) {
                      _customMissions.remove(cellData.sectionNumber);
                      _seedMissionsForSection(number);
                    } else {
                      _customMissions[number] = missionValue;
                    }
                  }

                  _notifyChanged();
                });

                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  int? _findExistingSection(int sectionNumber) {
    for (final areaEntry in _areaCells.entries) {
      for (final cell in areaEntry.value.values) {
        if (cell.sectionNumber == sectionNumber) return areaEntry.key;
      }
    }

    return null;
  }

  void _showSectionDialog(int row, int col) {
    final controller = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nº mundo'),
          content: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Ej: 256',
                    errorText: errorText,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              IconButton(
                icon: const Icon(Icons.casino),
                tooltip: 'Tirada aleatoria (3d6)',
                onPressed: () {
                  final code = PlanetDatabase.randomSectionNumber();
                  controller.text = '$code';
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final number = int.tryParse(controller.text);
                if (number == null) return;

                final existingArea = _findExistingSection(number);
                if (existingArea != null) {
                  setDialogState(() {
                    errorText = 'Este mundo ya está en el área $existingArea';
                  });

                  return;
                }

                setState(() {
                  _areaCells.putIfAbsent(_viewingArea, () => {});
                  _areaCells[_viewingArea]![(row, col)] = CellData(
                    sectionNumber: number,
                  );
                  _seedMissionsForSection(number);
                  _notifyChanged();
                });

                Navigator.pop(ctx);
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      ),
    );
  }

  static const _productCodes = ['INDU', 'BASI', 'ALIM', 'MADE', 'AGUA', 'MICO', 'MIRA', 'MIPR', 'PAVA', 'A', 'AE', 'AEI', 'COM'];

  Widget _buildAreaPlanets() {
    final cells = _areaCells[_viewingArea];
    if (cells == null) return const SizedBox.shrink();

    final planets = <int, Planet>{};
    for (final cell in cells.values) {
      if (cell.isDeepSpace || cell.sectionNumber == null) continue;

      final planet = PlanetDatabase.planets[cell.sectionNumber];
      if (planet != null) planets[cell.sectionNumber!] = planet;
    }

    if (planets.isEmpty) return const SizedBox.shrink();

    final shipCell = _areaCells[_shipArea]?[(_shipRow, _shipCol)];
    final currentSection = _viewingShipArea ? shipCell?.sectionNumber : null;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PLANETAS DEL ÁREA',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8B949E)),
          ),

          const SizedBox(height: 6),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildPlanetsProductMatrix(planets, currentSection),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaMegacorps() {
    final areaMegacorps = _megacorpNamesInArea(_viewingArea);
    if (areaMegacorps.isEmpty) return const SizedBox.shrink();

    final allNumbers = _allMegacorpNumbers;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MEGACORPORACIONES',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8B949E)),
          ),

          const SizedBox(height: 6),

          for (final name in areaMegacorps)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '${allNumbers[name]}. $name',
                style: const TextStyle(fontSize: 12, color: Color(0xFFBC8CFF)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlanetsProductMatrix(Map<int, Planet> planets, int? currentSection) {
    return Table(
      defaultColumnWidth: const FixedColumnWidth(28),
      columnWidths: const {0: IntrinsicColumnWidth()},
      border: TableBorder.all(color: const Color(0xFF30363D), width: 0.5),
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFF1C2333)),
          children: [
            _matrixHeader(''),
            for (final code in _productCodes)
              _matrixHeader(code),
          ],
        ),

        for (final entry in planets.entries)
          _buildPlanetRow(entry.key, entry.value, entry.key == currentSection),
      ],
    );
  }

  TableRow _buildPlanetRow(int section, Planet planet, bool isCurrent) {
    return TableRow(
      decoration: isCurrent
          ? const BoxDecoration(color: Color(0xFF1A2332))
          : null,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Text(
            '${planet.name} ($section)',
            style: TextStyle(
              fontSize: 9,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? const Color(0xFF58A6FF) : null,
            ),
          ),
        ),

        for (final code in _productCodes)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(
                planet.products.contains(code) ? '●' : '',
                style: TextStyle(
                  fontSize: 8,
                  color: planet.products.contains(code) ? const Color(0xFF2EA043) : const Color(0xFF30363D),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _matrixHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Color(0xFF8B949E)),
        ),
      ),
    );
  }

  Widget _buildDeepSpaceInfo(CellData cell) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          border: Border.all(color: const Color(0xFF30363D)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Espacio profundo',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            if (cell.megacorporation.isNotEmpty) ...[
              const SizedBox(height: 6),
              _planetInfoRow('Megacorporación', cell.megacorporation),
            ],

            if (cell.pirates) ...[
              const SizedBox(height: 6),
              _planetInfoRow('Piratas', 'Sí'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanetInfo() {
    final cell = _areaCells[_shipArea]?[(_shipRow, _shipCol)];
    if (cell == null) return const SizedBox.shrink();

    if (cell.isDeepSpace) return _buildDeepSpaceInfo(cell);

    final planet = PlanetDatabase.planets[cell.sectionNumber];
    if (planet == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          border: Border.all(color: const Color(0xFF30363D)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${planet.name} (${cell.sectionNumber})',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            _planetInfoRow('Soporte vital', planet.lifeSupport),
            _planetInfoRow('Convenio', planet.agreement),
            _planetInfoRow('Espaciopuerto', planet.spaceport),
            _planetInfoRow('Autosuficiencia', '${planet.selfSufficiency}'),
            _planetInfoRow('UCN/pedido', '${planet.ucnPerOrder}'),
            _planetInfoRow('Pasajeros', '${planet.passengers}'),

            if (cell.megacorporation.isNotEmpty)
              _planetInfoRow('Megacorporación', cell.megacorporation),

            if (cell.pirates)
              _planetInfoRow('Piratas', 'Sí'),

            const SizedBox(height: 8),

            _buildProductProfitTable(planet),

            if (cell.hasNotes) ...[
              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF21262D),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF30363D)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NOTAS',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF8B949E)),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      cell.notes,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductProfitTable(Planet planet) {
    final planetProducts = ProductReference.products
        .where((p) => planet.products.contains(p.code))
        .toList()
      ..sort((a, b) => _profitPercent(b).compareTo(_profitPercent(a)));

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(),
        1: FixedColumnWidth(32),
        2: FixedColumnWidth(32),
        3: FixedColumnWidth(48),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFF1C2333)),
          children: [
            _productHeader('Producto'),
            _productHeader('C'),
            _productHeader('V'),
            _productHeader('Rent.%'),
          ],
        ),

        for (final p in planetProducts)
          TableRow(
            children: [
              _productCell(p.code, bold: true),
              _productCell('${p.purchasePrice}'),
              _productCell('${p.salePrice}'),
              _productCell(
                '${_profitPercent(p)}%',
                color: const Color(0xFF2EA043),
                bold: true,
              ),
            ],
          ),
      ],
    );
  }

  int _profitPercent(ProductInfo p) {
    return ((p.salePrice - p.purchasePrice) / p.purchasePrice * 100).round();
  }

  Widget _productHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Text(text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF8B949E))),
    );
  }

  Widget _productCell(String text, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: color),
      ),
    );
  }

  Widget _planetInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8B949E))),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showPlanetDetail(int sectionNumber) {
    final planet = PlanetDatabase.planets[sectionNumber];

    if (planet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mundo $sectionNumber no encontrado')),
      );

      return;
    }

    setState(() {
      _hyperjumpDays = _hyperjumpDaysForSection(sectionNumber);
      _notifyChanged();
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          '${planet.name} ($sectionNumber)',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 340,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _planetRow('*2 Soporte vital', planet.lifeSupport),
                _planetRow('*3 Riesgo contagio', planet.contagionRisk),
                _planetRow('*4 Convenio', planet.agreement),
                _planetRow('*5 Días hiperdisparo', '${planet.hyperjumpDays}'),
                _planetRow('*6 Orden. legal', planet.legalSystem),
                _planetRow('Espaciopuerto', planet.spaceport),

                const Divider(height: 16),

                _planetRow('CC', planet.cc),
                _planetRow('PI', planet.pi),
                _planetRow('DS', planet.ds),
                _planetRow('AA', planet.aa),

                const Divider(height: 16),

                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: planet.products.map((p) => Chip(
                    label: Text(p, style: const TextStyle(fontSize: 10)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),

                const Divider(height: 16),

                _planetRow('*7 Autosuficiencia', '${planet.selfSufficiency}'),
                _planetRow('*8 UCN por pedido', '${planet.ucnPerOrder}'),
                _planetRow('*9 Pasajeros', '${planet.passengers}'),
                _planetRow('*10 Misiones', '${_missionsForSection(sectionNumber) ?? planet.missions}'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _planetRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8B949E))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _editHyperjumpDays() {
    final controller = TextEditingController(text: '$_hyperjumpDays');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Días hasta hiperdisparo'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);

              if (value != null) {
                setState(() {
                  _hyperjumpDays = value;
                  _persistCustomHyperjumpDays(value);
                  _notifyChanged();
                });
              }

              Navigator.pop(ctx);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _persistCustomHyperjumpDays(int value) {
    final sectionNumber = _areaCells[_shipArea]?[(_shipRow, _shipCol)]?.sectionNumber;

    if (sectionNumber == null) return;

    _customHyperjumpDays[sectionNumber] = value;
  }

  void _showDensityDialog() {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Densidad área $_viewingArea'),
        children: [
          for (final density in AreaDensity.values)
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _areaDensity[_viewingArea] = density;
                  _notifyChanged();
                });
                Navigator.pop(ctx);
              },
              child: Text(_densityLabel(density)),
            ),
          SimpleDialogOption(
            onPressed: () {
              setState(() {
                _areaDensity.remove(_viewingArea);
                _notifyChanged();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Sin asignar', style: TextStyle(color: Color(0xFF8B949E))),
          ),
        ],
      ),
    );
  }

  String _densityLabel(AreaDensity density) {
    return switch (density) {
      AreaDensity.low => 'Baja (2-4)',
      AreaDensity.medium => 'Media (5-9)',
      AreaDensity.high => 'Alta (10-12)',
    };
  }

}
