import 'package:flutter/material.dart';

import 'package:spacegom_companion/models/treasury.dart';

class LoanCard extends StatelessWidget {
  final Loan loan;
  final ValueChanged<Loan> onChanged;

  const LoanCard({
    super.key,
    required this.loan,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 6),

            _buildDetails(),

            const SizedBox(height: 8),

            _buildInstallments(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          '#${loan.id}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),

        const Spacer(),

        Text(
          '${loan.amount} SC',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF58A6FF)),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Row(
      children: [
        Expanded(child: _detailItem('Devolver', '${loan.totalRepayment} SC')),
        Expanded(child: _detailItem('Cuota', '${loan.monthlyPayment} SC')),
        Expanded(child: _detailItem('Concesión', loan.grantDate)),
        Expanded(child: _detailItem('Fin', loan.endDate)),
      ],
    );
  }

  Widget _detailItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF8B949E))),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInstallments() {
    return Wrap(
      spacing: 3,
      runSpacing: 3,
      children: List.generate(Loan.maxInstallments, (i) {
        final isPaid = i < loan.paidInstallments;

        return GestureDetector(
          onTap: () {
            final newPaid = isPaid ? i : i + 1;

            onChanged(loan.copyWith(paidInstallments: newPaid));
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isPaid ? const Color(0xFF2EA043).withValues(alpha: 0.3) : const Color(0xFF161B22),
              border: Border.all(
                color: isPaid ? const Color(0xFF2EA043) : const Color(0xFF30363D),
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Center(
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  fontSize: 9,
                  color: isPaid ? const Color(0xFF2EA043) : const Color(0xFF8B949E),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
