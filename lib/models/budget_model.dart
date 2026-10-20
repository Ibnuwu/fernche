class BudgetModel {
  final int? id;
  final String category;
  final int limitAmount;
  final String createdAt;
  final String updatedAt;

  const BudgetModel({
    this.id,
    required this.category,
    required this.limitAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category': category,
      'limit_amount': limitAmount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as int?,
      category: map['category'] as String,
      limitAmount: map['limit_amount'] as int,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  BudgetModel copyWith({
    int? id,
    String? category,
    int? limitAmount,
    String? createdAt,
    String? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      category: category ?? this.category,
      limitAmount: limitAmount ?? this.limitAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
