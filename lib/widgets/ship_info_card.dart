import 'package:flutter/material.dart';

import 'package:spacegom_companion/models/name_database.dart';
import 'package:spacegom_companion/models/ship.dart';

class ShipInfoCard extends StatelessWidget {
  final String companyName;
  final Ship ship;
  final int shipCount;
  final int activeIndex;
  final ValueChanged<String> onCompanyNameChanged;
  final ValueChanged<Ship> onShipChanged;
  final VoidCallback? onAddShip;
  final VoidCallback? onSwitchShip;

  const ShipInfoCard({
    super.key,
    required this.companyName,
    required this.ship,
    this.shipCount = 1,
    this.activeIndex = 0,
    required this.onCompanyNameChanged,
    required this.onShipChanged,
    this.onAddShip,
    this.onSwitchShip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextField('COMPAÑÍA', companyName, onCompanyNameChanged),
                ),
                IconButton(
                  onPressed: () => onCompanyNameChanged(NameDatabase.randomMegacorpName()),
                  icon: const Icon(Icons.casino_outlined, size: 20, color: Color(0xFF58A6FF)),
                  tooltip: 'Nombre aleatorio',
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'NOMBRE NAVE (${activeIndex + 1}/$shipCount)',
                    ship.name,
                    (v) => onShipChanged(ship.copyWith(name: v)),
                  ),
                ),

                if (onAddShip != null)
                  IconButton(
                    onPressed: onAddShip,
                    icon: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF58A6FF)),
                    tooltip: 'Añadir nave',
                  ),

                if (shipCount > 1 && onSwitchShip != null)
                  IconButton(
                    onPressed: onSwitchShip,
                    icon: const Icon(Icons.swap_horiz, size: 20, color: Color(0xFFE8B830)),
                    tooltip: 'Cambiar nave activa',
                  ),
              ],
            ),

            const SizedBox(height: 8),

            _buildTextField(
              'MODELO',
              ship.model,
              (v) => onShipChanged(ship.copyWith(model: v)),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    'HIPERSALTO', ship.hyperjumpCapacity,
                    (v) => onShipChanged(ship.copyWith(hyperjumpCapacity: v)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildNumberField(
                    'MOD. TIRADAS', ship.rollModifier,
                    (v) => onShipChanged(ship.copyWith(rollModifier: v)),
                    showZero: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    'PASAJEROS', ship.maxPassengers,
                    (v) => onShipChanged(ship.copyWith(maxPassengers: v)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildNumberField(
                    'ALMACÉN MÁX.', ship.maxCargo,
                    (v) => onShipChanged(ship.copyWith(maxCargo: v)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Color(0xFF8B949E),
          ),
        ),

        const SizedBox(height: 2),

        TextFormField(
          initialValue: value,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF30363D)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF30363D)),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildNumberField(
    String label,
    int value,
    ValueChanged<int> onChanged, {
    bool showZero = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Color(0xFF8B949E),
          ),
        ),

        const SizedBox(height: 2),

        TextFormField(
          initialValue: value == 0 && !showZero ? '' : '$value',
          style: const TextStyle(fontSize: 14),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF30363D)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF30363D)),
            ),
          ),
          onChanged: (text) {
            final parsed = int.tryParse(text);
            if (parsed != null) onChanged(parsed);
          },
        ),
      ],
    );
  }
}
