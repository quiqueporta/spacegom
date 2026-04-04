import 'package:flutter/material.dart';

import 'package:spacegom_companion/models/company.dart';
import 'package:spacegom_companion/models/employee.dart';
import 'package:spacegom_companion/models/life_support.dart';
import 'package:spacegom_companion/models/ship.dart';
import 'package:spacegom_companion/models/treasury.dart';
import 'package:spacegom_companion/models/weapon.dart';
import 'package:spacegom_companion/widgets/digit_counter.dart';
import 'package:spacegom_companion/widgets/level_selector.dart';
import 'package:spacegom_companion/widgets/health_tracker.dart';
import 'package:spacegom_companion/widgets/ship_info_card.dart';

class CompanySheetScreen extends StatefulWidget {
  final Company initialCompany;
  final ValueChanged<Company> onChanged;
  const CompanySheetScreen({
    super.key,
    required this.initialCompany,
    required this.onChanged,
  });

  @override
  State<CompanySheetScreen> createState() => _CompanySheetScreenState();
}

class _CompanySheetScreenState extends State<CompanySheetScreen> with AutomaticKeepAliveClientMixin {
  late String _companyName;
  late List<Ship> _ships;
  late int _activeShipIndex;
  late int _fuel;
  late int _storage;
  late int _reputation;
  late int _lightDamage;
  late int _moderateDamage;
  late int _severeDamage;
  late int _saludMarks;
  late List<Employee> _employees;
  late List<Weapon> _weapons;
  late Map<String, int> _lifeSupportEquipment;
  late Treasury _treasury;

  Ship get _activeShip => _ships[_activeShipIndex];

  @override
  void initState() {
    super.initState();

    final c = widget.initialCompany;
    _companyName = c.companyName;
    _ships = List.from(c.ships);
    _activeShipIndex = c.activeShipIndex;
    _fuel = c.fuel;
    _storage = c.storage;
    _reputation = c.reputation;
    _lightDamage = c.lightDamage;
    _moderateDamage = c.moderateDamage;
    _severeDamage = c.severeDamage;
    _saludMarks = c.saludMarks;
    _employees = List.from(c.employees);
    _weapons = List.from(c.weapons);
    _lifeSupportEquipment = Map.from(c.lifeSupportEquipment);
    _treasury = c.treasury;
  }

  Company _buildCompany() {
    return Company(
      companyName: _companyName,
      ships: List.from(_ships),
      activeShipIndex: _activeShipIndex,
      fuel: _fuel,
      storage: _storage,
      reputation: _reputation,
      lightDamage: _lightDamage,
      moderateDamage: _moderateDamage,
      severeDamage: _severeDamage,
      saludMarks: _saludMarks,
      employees: List.from(_employees),
      weapons: List.from(_weapons),
      lifeSupportEquipment: Map.from(_lifeSupportEquipment),
      treasury: _treasury,
    );
  }

  void _notifyChanged() => widget.onChanged(_buildCompany());

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildShipInfo(),

          const SizedBox(height: 16),

          _buildReputation(),

          const SizedBox(height: 16),

          _buildResources(),

          const SizedBox(height: 16),

          _buildDamagePanel(),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: HealthTracker(
                marks: _saludMarks,
                onChanged: (v) => setState(() { _saludMarks = v; _notifyChanged(); }),
              ),
            ),
          ),

          const SizedBox(height: 16),

          _buildLifeSupport(),
        ],
      ),
    );
  }

  Widget _buildShipInfo() {
    return ShipInfoCard(
      key: ValueKey('ship_$_activeShipIndex'),
      companyName: _companyName,
      ship: _activeShip,
      shipCount: _ships.length,
      activeIndex: _activeShipIndex,
      onCompanyNameChanged: (v) => setState(() { _companyName = v; _notifyChanged(); }),
      onShipChanged: (ship) => setState(() { _ships[_activeShipIndex] = ship; _notifyChanged(); }),
      onAddShip: _addShip,
      onSwitchShip: _ships.length > 1 ? _switchShip : null,
    );
  }

  void _addShip() {
    setState(() {
      _ships.add(const Ship());
      _activeShipIndex = _ships.length - 1;
      _notifyChanged();
    });
  }

  void _switchShip() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Astronaves'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _ships.length; i++)
              ListTile(
                leading: i == _activeShipIndex
                    ? const Icon(Icons.rocket_launch, size: 20, color: Color(0xFF2EA043))
                    : const Icon(Icons.rocket_launch_outlined, size: 20, color: Color(0xFF8B949E)),
                title: Text(
                  _ships[i].name.isEmpty ? 'Nave ${i + 1} (sin nombre)' : _ships[i].name,
                  style: TextStyle(
                    fontWeight: i == _activeShipIndex ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  _ships[i].model.isEmpty ? '—' : _ships[i].model,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF8B949E)),
                ),
                onTap: () {
                  setState(() { _activeShipIndex = i; _notifyChanged(); });
                  Navigator.pop(ctx);
                },
                trailing: _ships.length > 1
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDA3633)),
                        onPressed: () {
                          setState(() {
                            _ships.removeAt(i);

                            if (_activeShipIndex >= _ships.length) {
                              _activeShipIndex = _ships.length - 1;
                            }

                            _notifyChanged();
                          });
                          Navigator.pop(ctx);
                        },
                      )
                    : null,
              ),
          ],
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

  Widget _buildReputation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: LevelSelector(
          label: 'REPUTACIÓN',
          values: List.generate(11, (i) => i - 5),
          selectedValue: _reputation,
          onChanged: (v) => setState(() { _reputation = v; _notifyChanged(); }),
        ),
      ),
    );
  }

  Widget _buildResources() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: DigitCounter(
                label: 'COMBUSTIBLE',
                value: _fuel,
                digitCount: 2,
                onChanged: (v) => setState(() { _fuel = v; _notifyChanged(); }),
              ),
            ),
          ),
        ),

        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: DigitCounter(
                label: 'ALMACÉN',
                value: _storage,
                digitCount: 3,
                onChanged: (v) => setState(() { _storage = v; _notifyChanged(); }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _updateActiveShip(Ship updated) {
    setState(() {
      _ships[_activeShipIndex] = updated;
      _notifyChanged();
    });
  }

  Widget _buildDamagePanel() {
    final ship = _activeShip;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'DAÑOS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),

            _buildDamageRow(
              label: 'LEVES',
              damage: _lightDamage,
              support: ship.lightSupport,
              onDamageChanged: (v) => setState(() { _lightDamage = v; _notifyChanged(); }),
              onSupportChanged: (v) => _updateActiveShip(ship.copyWith(lightSupport: v)),
            ),

            const SizedBox(height: 8),

            _buildDamageRow(
              label: 'MODERADOS',
              damage: _moderateDamage,
              support: ship.moderateSupport,
              onDamageChanged: (v) => setState(() { _moderateDamage = v; _notifyChanged(); }),
              onSupportChanged: (v) => _updateActiveShip(ship.copyWith(moderateSupport: v)),
            ),

            const SizedBox(height: 8),

            _buildDamageRow(
              label: 'GRAVES',
              damage: _severeDamage,
              support: ship.severeSupport,
              onDamageChanged: (v) => setState(() { _severeDamage = v; _notifyChanged(); }),
              onSupportChanged: (v) => _updateActiveShip(ship.copyWith(severeSupport: v)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDamageRow({
    required String label,
    required int damage,
    required int support,
    required ValueChanged<int> onDamageChanged,
    required ValueChanged<int> onSupportChanged,
  }) {
    final exceeded = damage > support && support > 0;
    final statusColor = exceeded ? const Color(0xFFDA3633) : const Color(0xFF2EA043);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 85,
              child: Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8B949E)),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                border: Border.all(color: statusColor),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$damage/$support',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
              ),
            ),

            if (exceeded) ...[
              const SizedBox(width: 6),
              const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFDA3633)),
            ],
          ],
        ),

        const SizedBox(height: 4),

        Row(
          children: [
            for (var i = 0; i < 6; i++) ...[
              Expanded(
                child: GestureDetector(
                  onTap: () => onDamageChanged(i),
                  child: Container(
                    height: 28,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: i == damage ? LevelSelector.damageColor(i) : Colors.transparent,
                      border: Border.all(
                        color: i == damage ? LevelSelector.damageColor(i) : const Color(0xFF30363D),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$i',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: i == damage ? FontWeight.bold : FontWeight.normal,
                        color: i == damage ? Colors.white : const Color(0xFF8B949E),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(width: 6),

            const Icon(Icons.shield_outlined, size: 14, color: Color(0xFF8B949E)),

            const SizedBox(width: 2),

            SizedBox(
              width: 40,
              child: DropdownButton<int>(
                value: support,
                isDense: true,
                underline: const SizedBox.shrink(),
                items: List.generate(6, (i) => DropdownMenuItem(
                  value: i,
                  child: Text('$i', style: const TextStyle(fontSize: 11)),
                )),
                onChanged: (v) {
                  if (v != null) onSupportChanged(v);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLifeSupport() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.air, size: 16, color: Color(0xFF58A6FF)),
              const SizedBox(width: 6),
              const Text(
                'SOPORTE VITAL',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8B949E)),
              ),
            ],
          ),
        ),

        for (final type in LifeSupportReference.equipment)
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      type.code,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF58A6FF)),
                    ),
                  ),

                  Expanded(
                    child: Text(
                      type.equipmentName,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: (_lifeSupportEquipment[type.code] ?? 0) > 0
                        ? () => setState(() {
                              _lifeSupportEquipment[type.code] =
                                  (_lifeSupportEquipment[type.code] ?? 0) - 1;
                              if (_lifeSupportEquipment[type.code] == 0) {
                                _lifeSupportEquipment.remove(type.code);
                              }
                              _notifyChanged();
                            })
                        : null,
                  ),

                  SizedBox(
                    width: 24,
                    child: Text(
                      '${_lifeSupportEquipment[type.code] ?? 0}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: () => setState(() {
                      _lifeSupportEquipment[type.code] =
                          (_lifeSupportEquipment[type.code] ?? 0) + 1;
                      _notifyChanged();
                    }),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
