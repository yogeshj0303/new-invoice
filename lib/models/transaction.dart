class Transaction {
  final int id;
  final int invoiceId;
  final int userId;
  final String customerName;
  final String date;
  final String status;
  final String createdAt;
  final String updatedAt;
  final Invoice invoice;

  Transaction({
    required this.id,
    required this.invoiceId,
    required this.userId,
    required this.customerName,
    required this.date,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.invoice,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      invoiceId: json['invoice_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      invoice: Invoice.fromJson(json['invoice'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'user_id': userId,
      'customer_name': customerName,
      'date': date,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'invoice': invoice.toJson(),
    };
  }

  Transaction copyWith({
    int? id,
    int? invoiceId,
    int? userId,
    String? customerName,
    String? date,
    String? status,
    String? createdAt,
    String? updatedAt,
    Invoice? invoice,
  }) {
    return Transaction(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      date: date ?? this.date,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      invoice: invoice ?? this.invoice,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, invoiceId: $invoiceId, customerName: $customerName, status: $status, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Invoice {
  final int id;
  final int userId;
  final int customerId;
  final String customerName;
  final String customerNumber;
  final String paymentType;
  final String discountPercent;
  final String discountAmount;
  final String roundOff;
  final String totalAmount;
  final String amountReceived;
  final String note;
  final String createdAt;
  final String updatedAt;
  final String recycleStatus;

  Invoice({
    required this.id,
    required this.userId,
    required this.customerId,
    required this.customerName,
    required this.customerNumber,
    required this.paymentType,
    required this.discountPercent,
    required this.discountAmount,
    required this.roundOff,
    required this.totalAmount,
    required this.amountReceived,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.recycleStatus,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      customerNumber: json['customer_number'] ?? '',
      paymentType: json['payment_type'] ?? '',
      discountPercent: json['discount_percent'] ?? '0.00',
      discountAmount: json['discount_amount'] ?? '0.00',
      roundOff: json['round_off'] ?? '0.00',
      totalAmount: json['total_amount'] ?? '0.00',
      amountReceived: json['amount_received'] ?? '0.00',
      note: json['note'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      recycleStatus: json['recycle_status'] ?? 'none',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_number': customerNumber,
      'payment_type': paymentType,
      'discount_percent': discountPercent,
      'discount_amount': discountAmount,
      'round_off': roundOff,
      'total_amount': totalAmount,
      'amount_received': amountReceived,
      'note': note,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'recycle_status': recycleStatus,
    };
  }

  Invoice copyWith({
    int? id,
    int? userId,
    int? customerId,
    String? customerName,
    String? customerNumber,
    String? paymentType,
    String? discountPercent,
    String? discountAmount,
    String? roundOff,
    String? totalAmount,
    String? amountReceived,
    String? note,
    String? createdAt,
    String? updatedAt,
    String? recycleStatus,
  }) {
    return Invoice(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerNumber: customerNumber ?? this.customerNumber,
      paymentType: paymentType ?? this.paymentType,
      discountPercent: discountPercent ?? this.discountPercent,
      discountAmount: discountAmount ?? this.discountAmount,
      roundOff: roundOff ?? this.roundOff,
      totalAmount: totalAmount ?? this.totalAmount,
      amountReceived: amountReceived ?? this.amountReceived,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      recycleStatus: recycleStatus ?? this.recycleStatus,
    );
  }

  @override
  String toString() {
    return 'Invoice(id: $id, customerName: $customerName, totalAmount: $totalAmount, status: $paymentType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Invoice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
