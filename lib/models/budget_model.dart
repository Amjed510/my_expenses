class Budget {
  final int? id;
  final double amount;
  final int month;
  final int year;
  final String userId;

  Budget({
    this.id,
    required this.amount,
    required this.month,
    required this.year,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'month': month,
      'year': year,
      'userId': userId,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      amount: map['amount'] as double,
      month: map['month'] as int,
      year: map['year'] as int,
      userId: map['userId'] as String,
    );
  }
}
