import 'package:flutter/material.dart';

import 'package:spacegom_companion/models/area_sheet.dart';
import 'package:spacegom_companion/widgets/date_field.dart';

class AreaSheetScreen extends StatefulWidget {
  final int area;
  final AreaSheet sheet;
  final ValueChanged<AreaSheet> onChanged;

  const AreaSheetScreen({
    super.key,
    required this.area,
    required this.sheet,
    required this.onChanged,
  });

  @override
  State<AreaSheetScreen> createState() => _AreaSheetScreenState();
}

class _AreaSheetScreenState extends State<AreaSheetScreen> {
  late List<SpecialMission> _missions;
  late List<TradeRecord> _trades;

  @override
  void initState() {
    super.initState();

    _missions = List.from(widget.sheet.missions);
    _trades = List.from(widget.sheet.trades);
  }

  void _notifyChanged() {
    widget.onChanged(AreaSheet(
      missions: List.from(_missions),
      trades: List.from(_trades),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Área ${widget.area}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMissionsSection(),

            const SizedBox(height: 20),

            _buildTradesSection(),

            const SizedBox(height: 20),

            _buildProductsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'MISIONES ESPECIALES',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            IconButton(
              onPressed: _addMission,
              icon: const Icon(Icons.add, size: 20),
            ),
          ],
        ),

        if (_missions.isEmpty)
          const Text('Sin misiones', style: TextStyle(color: Color(0xFF8B949E), fontSize: 12)),

        for (var i = 0; i < _missions.length; i++)
          _buildMissionCard(i, _missions[i]),
      ],
    );
  }

  Widget _buildMissionCard(int index, SpecialMission mission) {
    final resultColor = switch (mission.result) {
      MissionResult.pending => const Color(0xFFE8B830),
      MissionResult.success => const Color(0xFF2EA043),
      MissionResult.failure => const Color(0xFFDA3633),
    };
    final resultLabel = switch (mission.result) {
      MissionResult.pending => 'Pendiente',
      MissionResult.success => 'Éxito',
      MissionResult.failure => 'Fracaso',
    };

    return GestureDetector(
      onLongPress: () => _deleteMission(index),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    mission.code,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),

                  const Spacer(),

                  GestureDetector(
                    onTap: () {
                      final next = switch (mission.result) {
                        MissionResult.pending => MissionResult.success,
                        MissionResult.success => MissionResult.failure,
                        MissionResult.failure => MissionResult.pending,
                      };

                      setState(() {
                        _missions[index] = SpecialMission(
                          code: mission.code,
                          acceptanceWorld: mission.acceptanceWorld,
                          executionLocations: mission.executionLocations,
                          deadline: mission.deadline,
                          result: next,
                        );
                        _notifyChanged();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: resultColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        resultLabel,
                        style: TextStyle(fontSize: 10, color: resultColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  _missionDetail('Mundo', mission.acceptanceWorld),
                  const SizedBox(width: 12),
                  Expanded(child: _missionDetail('Lugares', mission.executionLocations)),
                  _missionDetail('F. máx', mission.deadline),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _missionDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF8B949E))),
        Text(
          value.isEmpty ? '—' : value,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildTradesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'COMERCIO DE MERCANCÍAS (${_trades.length}/25)',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            IconButton(
              onPressed: _trades.length < 25 ? () => _showTradeDialog() : null,
              icon: const Icon(Icons.add, size: 20),
            ),
          ],
        ),

        if (_trades.isEmpty)
          const Text('Sin operaciones', style: TextStyle(color: Color(0xFF8B949E), fontSize: 12)),

        for (var i = 0; i < _trades.length; i++)
          _buildTradeCard(i, _trades[i]),
      ],
    );
  }

  Widget _buildTradeCard(int index, TradeRecord trade) {
    final hasSale = trade.saleAmount > 0 || trade.saleWorld.isNotEmpty;
    final profitColor = trade.profit >= 0 ? const Color(0xFF2EA043) : const Color(0xFFDA3633);
    final prefix = trade.profit >= 0 ? '+' : '';
    final isVoided = trade.voided;
    final strikethrough = isVoided ? TextDecoration.lineThrough : null;

    return GestureDetector(
      onTap: () => _showTradeDialog(index: index),
      onLongPress: () => _deleteTrade(index),
      child: Card(
        color: isVoided ? const Color(0xFF1C2333).withValues(alpha: 0.5) : null,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _productLabel(trade.productCode),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF58A6FF), decoration: strikethrough),
                  ),

                  const Spacer(),

                  if (hasSale && !isVoided)
                    Text(
                      '$prefix${trade.profit} SC',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: profitColor),
                    ),

                  if (isVoided) ...[
                    const Text(
                      'INUTILIZADA',
                      style: TextStyle(fontSize: 9, color: Color(0xFFDA3633), fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                  ],

                  const SizedBox(width: 6),

                  Icon(
                    trade.traceability ? Icons.verified : Icons.close,
                    size: 14,
                    color: trade.traceability ? const Color(0xFF2EA043) : const Color(0xFFDA3633),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('COMPRA', style: TextStyle(fontSize: 9, color: Color(0xFF8B949E))),
                        Text(
                          'Mundo ${trade.purchaseWorld}  ·  ${trade.purchaseUnits} uds  ·  ${trade.purchaseAmount} SC',
                          style: TextStyle(fontSize: 11, decoration: strikethrough),
                        ),
                        if (trade.purchaseDate.isNotEmpty)
                          Text(trade.purchaseDate, style: TextStyle(fontSize: 10, color: const Color(0xFF8B949E), decoration: strikethrough)),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('VENTA', style: TextStyle(fontSize: 9, color: Color(0xFF8B949E))),
                        if (hasSale) ...[
                          Text('Mundo ${trade.saleWorld}  ·  ${trade.saleAmount} SC', style: TextStyle(fontSize: 11, decoration: strikethrough)),
                          if (trade.saleDate.isNotEmpty)
                            Text(trade.saleDate, style: TextStyle(fontSize: 10, color: const Color(0xFF8B949E), decoration: strikethrough)),
                        ] else
                          const Text('—', style: TextStyle(fontSize: 11, color: Color(0xFF8B949E))),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PRODUCTOS (referencia)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Table(
          columnWidths: const {
            0: FixedColumnWidth(44),
            1: FlexColumnWidth(),
            2: FixedColumnWidth(40),
            3: FixedColumnWidth(40),
            4: FixedColumnWidth(32),
            5: FixedColumnWidth(32),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: const Color(0xFF1C2333)),
              children: [
                _tableHeader('Cód.'),
                _tableHeader('Producto'),
                _tableHeader('C'),
                _tableHeader('V'),
                _tableHeader('Prod'),
                _tableHeader('Nec'),
              ],
            ),

            for (final p in ProductReference.products)
              TableRow(
                children: [
                  _tableCell(p.code, bold: true),
                  _tableCell(p.productName),
                  _tableCell('${p.purchasePrice}'),
                  _tableCell('${p.salePrice}'),
                  _tableCell('${p.productionDays}'),
                  _tableCell('${p.demandDays}'),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Text(text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF8B949E))),
    );
  }

  Widget _tableCell(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
    );
  }

  String _productLabel(String code) {
    if (code.isEmpty) return '—';

    final info = ProductReference.products.where((p) => p.code == code).firstOrNull;

    return info != null ? '$code — ${info.productName}' : code;
  }

  void _addMission() {
    final codeCtrl = TextEditingController();
    final worldCtrl = TextEditingController();
    final locationsCtrl = TextEditingController();
    final deadlineCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva misión'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Código misión'), autofocus: true),
              TextField(controller: worldCtrl, decoration: const InputDecoration(labelText: 'Mundo aceptación')),
              TextField(controller: locationsCtrl, decoration: const InputDecoration(labelText: 'Lugares ejecución')),
              DateField(controller: deadlineCtrl, labelText: 'Fecha máxima'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              setState(() {
                _missions.add(SpecialMission(
                  code: codeCtrl.text.trim(),
                  acceptanceWorld: worldCtrl.text.trim(),
                  executionLocations: locationsCtrl.text.trim(),
                  deadline: deadlineCtrl.text.trim(),
                ));
                _notifyChanged();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  void _deleteMission(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar misión'),
        content: Text('¿Eliminar "${_missions[index].code}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              setState(() { _missions.removeAt(index); _notifyChanged(); });
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar', style: TextStyle(color: Color(0xFFDA3633))),
          ),
        ],
      ),
    );
  }

  void _showTradeDialog({int? index}) {
    final isEditing = index != null;
    final existing = isEditing ? _trades[index] : null;

    final purchaseWorldCtrl = TextEditingController(text: existing?.purchaseWorld ?? '');
    final purchaseUnitsCtrl = TextEditingController(text: existing != null && existing.purchaseUnits > 0 ? '${existing.purchaseUnits}' : '');
    final purchaseAmountCtrl = TextEditingController(text: existing != null && existing.purchaseAmount > 0 ? '${existing.purchaseAmount}' : '');
    final purchaseDateCtrl = TextEditingController(text: existing?.purchaseDate ?? '');
    final saleWorldCtrl = TextEditingController(text: existing?.saleWorld ?? '');
    final saleAmountCtrl = TextEditingController(text: existing != null && existing.saleAmount > 0 ? '${existing.saleAmount}' : '');
    final saleDateCtrl = TextEditingController(text: existing?.saleDate ?? '');
    var selectedProduct = existing?.productCode ?? ProductReference.products.first.code;
    var traceability = existing?.traceability ?? false;
    var voided = existing?.voided ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Editar operación' : 'Nueva operación'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('COMPRA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8B949E))),
                const SizedBox(height: 4),

                TextField(
                  controller: purchaseWorldCtrl,
                  decoration: const InputDecoration(labelText: 'Mundo (nº sección)'),
                  keyboardType: TextInputType.number,
                  autofocus: !isEditing,
                ),

                DropdownButton<String>(
                  value: selectedProduct,
                  isExpanded: true,
                  items: ProductReference.products.map((p) => DropdownMenuItem(
                    value: p.code,
                    child: Text('${p.code} — ${p.productName}', style: const TextStyle(fontSize: 13)),
                  )).toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedProduct = v);
                  },
                ),

                TextField(
                  controller: purchaseUnitsCtrl,
                  decoration: const InputDecoration(labelText: 'Unidades compradas'),
                  keyboardType: TextInputType.number,
                ),

                TextField(
                  controller: purchaseAmountCtrl,
                  decoration: const InputDecoration(labelText: 'Importe compra (SC)'),
                  keyboardType: TextInputType.number,
                ),

                DateField(controller: purchaseDateCtrl, labelText: 'Fecha compra'),

                const SizedBox(height: 16),

                const Text('VENTA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8B949E))),
                const SizedBox(height: 4),

                TextField(
                  controller: saleWorldCtrl,
                  decoration: const InputDecoration(labelText: 'Mundo (nº sección)'),
                  keyboardType: TextInputType.number,
                ),

                TextField(
                  controller: saleAmountCtrl,
                  decoration: const InputDecoration(labelText: 'Importe venta (SC)'),
                  keyboardType: TextInputType.number,
                ),

                DateField(controller: saleDateCtrl, labelText: 'Fecha venta'),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Expanded(
                      child: Text('Trazabilidad CUS', style: TextStyle(fontSize: 12)),
                    ),
                    Switch(
                      value: traceability,
                      onChanged: (v) => setDialogState(() => traceability = v),
                    ),
                  ],
                ),

                if (isEditing)
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Inutilizada', style: TextStyle(fontSize: 12)),
                      ),
                      Switch(
                        value: voided,
                        onChanged: (v) => setDialogState(() => voided = v),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                final trade = TradeRecord(
                  purchaseWorld: purchaseWorldCtrl.text.trim(),
                  productCode: selectedProduct,
                  purchaseUnits: int.tryParse(purchaseUnitsCtrl.text) ?? 0,
                  purchaseAmount: int.tryParse(purchaseAmountCtrl.text) ?? 0,
                  purchaseDate: purchaseDateCtrl.text.trim(),
                  saleWorld: saleWorldCtrl.text.trim(),
                  saleAmount: int.tryParse(saleAmountCtrl.text) ?? 0,
                  saleDate: saleDateCtrl.text.trim(),
                  traceability: traceability,
                  voided: voided,
                );

                setState(() {
                  if (isEditing) {
                    _trades[index] = trade;
                  } else {
                    _trades.add(trade);
                  }
                  _notifyChanged();
                });

                Navigator.pop(ctx);
              },
              child: Text(isEditing ? 'Guardar' : 'Añadir'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTrade(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar operación'),
        content: Text('¿Eliminar operación de ${_trades[index].productCode}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              setState(() { _trades.removeAt(index); _notifyChanged(); });
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar', style: TextStyle(color: Color(0xFFDA3633))),
          ),
        ],
      ),
    );
  }
}
