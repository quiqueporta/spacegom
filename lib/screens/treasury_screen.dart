import 'package:flutter/material.dart';

import 'package:spacegom_companion/models/treasury.dart';
import 'package:spacegom_companion/widgets/date_field.dart';
import 'package:spacegom_companion/widgets/loan_card.dart';

class TreasuryScreen extends StatefulWidget {
  final Treasury treasury;
  final ValueChanged<Treasury> onChanged;

  const TreasuryScreen({
    super.key,
    required this.treasury,
    required this.onChanged,
  });

  @override
  State<TreasuryScreen> createState() => _TreasuryScreenState();
}

class _TreasuryScreenState extends State<TreasuryScreen> {
  static const _maxVisibleTransactions = 5;

  late List<Transaction> _transactions;
  late List<Loan> _loans;
  bool _showAllTransactions = false;

  @override
  void initState() {
    super.initState();

    _transactions = List.from(widget.treasury.transactions);
    _loans = List.from(widget.treasury.loans);
  }

  int get _balance => _transactions.fold(0, (sum, tx) => sum + tx.amount);

  void _notifyChanged() {
    widget.onChanged(Treasury(
      transactions: List.from(_transactions),
      loans: List.from(_loans),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceHeader(),

            const SizedBox(height: 12),

            _buildTransactionsSection(),

            const SizedBox(height: 20),

            _buildLoansSection(),
          ],
        ),
    );
  }

  Widget _buildBalanceHeader() {
    final color = _balance >= 0 ? const Color(0xFF2EA043) : const Color(0xFFDA3633);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SALDO',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            Text(
              '$_balance SC',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsSection() {
    final total = _transactions.length;
    final hasMore = total > _maxVisibleTransactions && !_showAllTransactions;
    final visibleCount = hasMore ? _maxVisibleTransactions : total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MOVIMIENTOS ($total)',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            IconButton(
              onPressed: _addTransaction,
              icon: const Icon(Icons.add, size: 20),
            ),
          ],
        ),

        if (_transactions.isEmpty)
          const Text(
            'Sin movimientos',
            style: TextStyle(color: Color(0xFF8B949E), fontSize: 12),
          ),

        for (var j = 0; j < visibleCount; j++)
          _buildTransactionRow(total - 1 - j, _transactions[total - 1 - j]),

        if (hasMore)
          Center(
            child: TextButton(
              onPressed: () => setState(() => _showAllTransactions = true),
              child: Text(
                'Ver todos (${total - _maxVisibleTransactions} más)',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),

        if (_showAllTransactions && total > _maxVisibleTransactions)
          Center(
            child: TextButton(
              onPressed: () => setState(() => _showAllTransactions = false),
              child: const Text('Mostrar menos', style: TextStyle(fontSize: 12)),
            ),
          ),
      ],
    );
  }

  Widget _buildTransactionRow(int index, Transaction tx) {
    final color = tx.amount >= 0 ? const Color(0xFF2EA043) : const Color(0xFFDA3633);
    final prefix = tx.amount >= 0 ? '+' : '';

    return GestureDetector(
      onTap: () => _editTransaction(index),
      onLongPress: () => _deleteTransaction(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(tx.concept, style: const TextStyle(fontSize: 13)),
            ),

            Text(
              '$prefix${tx.amount} SC',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  void _editTransaction(int index) {
    final tx = _transactions[index];
    final conceptController = TextEditingController(text: tx.concept);
    final amountController = TextEditingController(text: '${tx.amount}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar movimiento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: conceptController,
              decoration: const InputDecoration(labelText: 'Concepto'),
              autofocus: true,
            ),

            const SizedBox(height: 8),

            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Importe (SC)'),
              keyboardType: const TextInputType.numberWithOptions(signed: true),
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
              final concept = conceptController.text.trim();
              final amount = int.tryParse(amountController.text);

              if (concept.isNotEmpty && amount != null) {
                setState(() {
                  _transactions[index] = Transaction(concept: concept, amount: amount);
                  _notifyChanged();
                });
              }

              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _addTransaction() {
    final conceptController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo movimiento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: conceptController,
              decoration: const InputDecoration(labelText: 'Concepto'),
              autofocus: true,
            ),

            const SizedBox(height: 8),

            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Importe (SC)',
                hintText: 'Negativo para gastos',
              ),
              keyboardType: const TextInputType.numberWithOptions(signed: true),
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
              final concept = conceptController.text.trim();
              final amount = int.tryParse(amountController.text);

              if (concept.isNotEmpty && amount != null) {
                setState(() {
                  _transactions.add(Transaction(concept: concept, amount: amount));
                  _notifyChanged();
                });
              }

              Navigator.pop(ctx);
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  void _deleteTransaction(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar movimiento'),
        content: Text('¿Eliminar "${_transactions[index].concept}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _transactions.removeAt(index);
                _notifyChanged();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar', style: TextStyle(color: Color(0xFFDA3633))),
          ),
        ],
      ),
    );
  }

  Widget _buildLoansSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PRÉSTAMOS (${_loans.length}/${Loan.maxLoans})',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            IconButton(
              onPressed: _loans.length < Loan.maxLoans ? _addLoan : null,
              icon: const Icon(Icons.add, size: 20),
            ),
          ],
        ),

        for (final loan in _loans)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onLongPress: () => _deleteLoan(loan.id),
              child: LoanCard(
                loan: loan,
                onChanged: _updateLoan,
              ),
            ),
          ),
      ],
    );
  }

  void _addLoan() {
    final amountController = TextEditingController();
    final totalController = TextEditingController();
    final grantDateController = TextEditingController();
    final endDateController = TextEditingController();
    final monthlyPaymentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo préstamo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Importe (SC)'),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
              TextField(
                controller: totalController,
                decoration: const InputDecoration(labelText: 'Total a devolver'),
                keyboardType: TextInputType.number,
              ),
              DateField(controller: grantDateController, labelText: 'Fecha concesión'),
              DateField(controller: endDateController, labelText: 'Fecha fin'),
              TextField(
                controller: monthlyPaymentController,
                decoration: const InputDecoration(labelText: 'Cuota mensual'),
                keyboardType: TextInputType.number,
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
              final nextId = _loans.isEmpty ? 1 : _loans.last.id + 1;

              setState(() {
                _loans.add(Loan(
                  id: nextId,
                  amount: int.tryParse(amountController.text) ?? 0,
                  totalRepayment: int.tryParse(totalController.text) ?? 0,
                  grantDate: grantDateController.text.trim(),
                  endDate: endDateController.text.trim(),
                  monthlyPayment: int.tryParse(monthlyPaymentController.text) ?? 0,
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

  void _updateLoan(Loan updated) {
    setState(() {
      final index = _loans.indexWhere((l) => l.id == updated.id);

      if (index >= 0) {
        _loans[index] = updated;
      }

      _notifyChanged();
    });
  }

  void _deleteLoan(int loanId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar préstamo'),
        content: Text('¿Eliminar préstamo #$loanId?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _loans.removeWhere((l) => l.id == loanId);
                _notifyChanged();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar', style: TextStyle(color: Color(0xFFDA3633))),
          ),
        ],
      ),
    );
  }
}
