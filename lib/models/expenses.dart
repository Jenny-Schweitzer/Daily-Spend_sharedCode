class Expenses {
  final int? id;
  final String? name;
  final double? amount;
  final int? month;
  final int? year;
  final int? categoryId;

  Expenses({this.id, this.name, this.amount, this.month, this.year, this.categoryId});

  // Convert a Expenses-Object into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'month': month,
      'year': year,
      'category_id': categoryId,
    };
  }

  // Convert a Map into a Expenses-Object.
  factory Expenses.fromMap(Map<String, dynamic> map) {
    return Expenses(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      month: map['month'],
      year: map['year'],
      categoryId: map['category_id'],
    );
  }
}
