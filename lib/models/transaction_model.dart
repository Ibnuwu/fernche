class TransactionModel {
  final int? id;
  final String type; // income or expense
  final int amount;
  final String category;
  final String? note;
  final String source; // manual or project_auto
  final int? sourceId;
  final String createdAt;

  const TransactionModel({
    this.id,
    required this.type,
    required this.amount,
    required this.category,
    this.note,
    this.source = 'manual',
    this.sourceId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'amount': amount,
      'category': category,
      'note': note,
      'source': source,
      'source_id': sourceId,
      'created_at': createdAt,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      type: map['type'] as String,
      amount: map['amount'] as int,
      category: map['category'] as String,
      note: map['note'] as String?,
      source: (map['source'] as String?) ?? 'manual',
      sourceId: map['source_id'] as int?,
      createdAt: map['created_at'] as String,
    );
  }

  TransactionModel copyWith({
    int? id,
    String? type,
    int? amount,
    String? category,
    String? note,
    String? source,
    int? sourceId,
    String? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
  bool get isFromProject => source == 'project_auto';
}
