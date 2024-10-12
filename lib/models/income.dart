// Modell für Einkommen.
class Income {
  final int? id;
  final double? amount;
  final int? startMonth;
  final int? startYear;

  Income({this.id, this.amount, this.startMonth, this.startYear});

  // Convert a Income-Objct into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'start_month': startMonth,
      'start_year': startYear,
    };
  }

  // Convert a Map into a Income-Object.
  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      amount: map['amount'],
      startMonth: map['start_month'],
      startYear: map['start_year'],
    );
  }
}
