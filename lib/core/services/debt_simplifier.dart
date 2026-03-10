/// Greedy debt simplification — minimises the number of transactions
/// needed to settle all debts in a group.
class DebtSimplifier {
  /// [balances] — map of userId → net balance.
  /// Positive = owed money. Negative = owes money.
  static List<Transaction> simplify(Map<String, double> balances) {
    final creditors = <_Entry>[];
    final debtors   = <_Entry>[];

    balances.forEach((uid, amount) {
      final r = double.parse(amount.toStringAsFixed(2));
      if (r > 0.01)       creditors.add(_Entry(uid, r));
      else if (r < -0.01) debtors.add(_Entry(uid, r.abs()));
    });

    creditors.sort((a, b) => b.amount.compareTo(a.amount));
    debtors.sort((a, b)   => b.amount.compareTo(a.amount));

    final result = <Transaction>[];
    int ci = 0, di = 0;

    while (ci < creditors.length && di < debtors.length) {
      final settle = creditors[ci].amount < debtors[di].amount
          ? creditors[ci].amount
          : debtors[di].amount;

      result.add(Transaction(
        from:   debtors[di].uid,
        to:     creditors[ci].uid,
        amount: double.parse(settle.toStringAsFixed(2)),
      ));

      creditors[ci].amount -= settle;
      debtors[di].amount   -= settle;

      if (creditors[ci].amount < 0.01) ci++;
      if (debtors[di].amount   < 0.01) di++;
    }

    return result;
  }
}

class _Entry {
  final String uid;
  double amount;
  _Entry(this.uid, this.amount);
}

class Transaction {
  final String from;
  final String to;
  final double amount;
  const Transaction({required this.from, required this.to, required this.amount});
}
