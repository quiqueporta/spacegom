class Transaction {
  final String concept;
  final int amount;

  const Transaction({
    required this.concept,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
    'concept': concept,
    'amount': amount,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    concept: json['concept'] as String,
    amount: json['amount'] as int,
  );
}

class Loan {
  static const maxLoans = 10;
  static const maxInstallments = 20;

  final int id;
  final int amount;
  final int totalRepayment;
  final String grantDate;
  final String endDate;
  final int monthlyPayment;
  final int paidInstallments;

  const Loan({
    required this.id,
    this.amount = 0,
    this.totalRepayment = 0,
    this.grantDate = '',
    this.endDate = '',
    this.monthlyPayment = 0,
    this.paidInstallments = 0,
  });

  Loan copyWith({
    int? id,
    int? amount,
    int? totalRepayment,
    String? grantDate,
    String? endDate,
    int? monthlyPayment,
    int? paidInstallments,
  }) {
    final clampedInstallments = paidInstallments != null
        ? paidInstallments.clamp(0, maxInstallments)
        : this.paidInstallments;

    return Loan(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      totalRepayment: totalRepayment ?? this.totalRepayment,
      grantDate: grantDate ?? this.grantDate,
      endDate: endDate ?? this.endDate,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      paidInstallments: clampedInstallments,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'totalRepayment': totalRepayment,
    'grantDate': grantDate,
    'endDate': endDate,
    'monthlyPayment': monthlyPayment,
    'paidInstallments': paidInstallments,
  };

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
    id: json['id'] as int,
    amount: json['amount'] as int? ?? 0,
    totalRepayment: json['totalRepayment'] as int? ?? 0,
    grantDate: json['grantDate'] as String? ?? '',
    endDate: json['endDate'] as String? ?? '',
    monthlyPayment: json['monthlyPayment'] as int? ?? 0,
    paidInstallments: json['paidInstallments'] as int? ?? 0,
  );
}

class Treasury {
  final List<Transaction> transactions;
  final List<Loan> loans;

  const Treasury({
    this.transactions = const [],
    this.loans = const [],
  });

  int get balance => transactions.fold(0, (sum, tx) => sum + tx.amount);

  Treasury copyWith({
    List<Transaction>? transactions,
    List<Loan>? loans,
  }) {
    return Treasury(
      transactions: transactions ?? this.transactions,
      loans: loans ?? this.loans,
    );
  }

  Map<String, dynamic> toJson() => {
    'transactions': transactions.map((e) => e.toJson()).toList(),
    'loans': loans.map((e) => e.toJson()).toList(),
  };

  factory Treasury.fromJson(Map<String, dynamic> json) => Treasury(
    transactions: (json['transactions'] as List<dynamic>?)
        ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
    loans: (json['loans'] as List<dynamic>?)
        ?.map((e) => Loan.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
  );
}
