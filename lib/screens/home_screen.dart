import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:spacegom_companion/models/area_sheet.dart';
import 'package:spacegom_companion/models/campaign_calendar.dart';
import 'package:spacegom_companion/models/game_state.dart';
import 'package:spacegom_companion/screens/area_sheet_screen.dart';
import 'package:spacegom_companion/screens/board_screen.dart';
import 'package:spacegom_companion/screens/calendar_screen.dart';
import 'package:spacegom_companion/models/treasury.dart';
import 'package:spacegom_companion/screens/company_sheet_screen.dart';
import 'package:spacegom_companion/screens/dice_screen.dart';
import 'package:spacegom_companion/screens/treasury_screen.dart';
import 'package:spacegom_companion/services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  final GameState initialState;

  HomeScreen({super.key, GameState? initialState})
      : initialState = initialState ?? GameState();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late GameState _gameState;
  int _stateVersion = 0;
  final _storageService = StorageService();

  @override
  void initState() {
    super.initState();

    _gameState = widget.initialState;
  }

  void _onBoardChanged(boardState) {
    _gameState = _gameState.copyWith(boardState: boardState);
    _storageService.saveGameState(_gameState);
  }

  void _onCompanyChanged(company) {
    _gameState = _gameState.copyWith(company: company);
    _storageService.saveGameState(_gameState);
  }

  void _onTreasuryChanged(Treasury treasury) {
    _gameState = _gameState.copyWith(
      company: _gameState.company.copyWith(treasury: treasury),
    );
    _storageService.saveGameState(_gameState);
  }

  void _onCalendarChanged(CampaignCalendar calendar) {
    setState(() {
      _gameState = _gameState.copyWith(calendar: calendar);
    });
    _storageService.saveGameState(_gameState);
  }

  void _openAreaSheet(int area) {
    final sheet = _gameState.areaSheets[area] ?? const AreaSheet();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AreaSheetScreen(
          area: area,
          sheet: sheet,
          onChanged: (updatedSheet) {
            final sheets = Map<int, AreaSheet>.from(_gameState.areaSheets);
            sheets[area] = updatedSheet;
            _gameState = _gameState.copyWith(areaSheets: sheets);
            _storageService.saveGameState(_gameState);
          },
        ),
      ),
    );
  }

  void _openCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CalendarScreen(
          calendar: _gameState.calendar,
          onChanged: _onCalendarChanged,
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    final dir = await getTemporaryDirectory();
    final file = await _storageService.exportToFile(_gameState, dir.path);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)]),
    );
  }

  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Resetear todos los datos?'),
        content: const Text('Se borrarán todos los datos y se restaurará la tripulación inicial.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Resetear', style: TextStyle(color: Color(0xFFDA3633))),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final defaultState = GameState.withDefaultCrew();
    await _storageService.clearGameState();
    await _storageService.saveGameState(defaultState);

    setState(() {
      _gameState = defaultState;
      _stateVersion++;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos reseteados')),
      );
    }
  }

  Future<void> _importData() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) return;

    try {
      final imported = await _storageService.importFromFile(
        result.files.single.path!,
      );

      await _storageService.saveGameState(imported);

      setState(() {
        _gameState = imported;
        _stateVersion++;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos importados correctamente')),
        );
      }
    } on FormatException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El archivo no tiene un formato válido')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/spacegom_logo.png',
          height: 32,
          color: const Color(0xFFE6EDF3),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportData();
                case 'import':
                  _importData();
                case 'reset':
                  _resetData();
                case 'about':
                  showAboutDialog(
                    context: context,
                    applicationName: 'Spacegom Companion',
                    applicationVersion: '1.2.1',
                    applicationIcon: Image.asset(
                      'assets/spacegom_logo.png',
                      width: 48,
                      height: 48,
                    ),
                  );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.upload_outlined),
                  title: Text('Exportar datos'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: ListTile(
                  leading: Icon(Icons.download_outlined),
                  title: Text('Importar datos'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: Icon(Icons.restore_outlined),
                  title: Text('Resetear datos'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'about',
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Acerca de'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        key: ValueKey(_stateVersion),
        index: _currentIndex,
        children: [
          BoardScreen(
            initialState: _gameState.boardState,
            onChanged: _onBoardChanged,
            onOpenCalendar: _openCalendar,
            onOpenAreaSheet: _openAreaSheet,
            currentMonth: _gameState.calendar.currentDate.$1,
            currentDay: _gameState.calendar.currentDate.$2,
            currentYear: _gameState.calendar.currentYear,
          ),
          CompanySheetScreen(
            initialCompany: _gameState.company,
            onChanged: _onCompanyChanged,
          ),
          TreasuryScreen(
            treasury: _gameState.company.treasury,
            onChanged: _onTreasuryChanged,
          ),
          const DiceScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF161B22),
        selectedItemColor: const Color(0xFF58A6FF),
        unselectedItemColor: const Color(0xFF8B949E),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_on),
            label: 'Tablero',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rocket_launch_outlined),
            label: 'Compañía',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_outlined),
            label: 'Tesorería',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.casino_outlined),
            label: 'Dados',
          ),
        ],
      ),
    );
  }
}
