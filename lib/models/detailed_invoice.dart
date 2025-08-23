class DetailedInvoice {
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
  final List<InvoiceItem> items;
  final List<InvoiceCharge> charges;
  final InvoiceCustomer customer;

  DetailedInvoice({
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
    required this.items,
    required this.charges,
    required this.customer,
  });

  factory DetailedInvoice.fromJson(Map<String, dynamic> json) {
    return DetailedInvoice(
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
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => InvoiceItem.fromJson(item))
          .toList() ?? [],
      charges: (json['charges'] as List<dynamic>?)
          ?.map((charge) => InvoiceCharge.fromJson(charge))
          .toList() ?? [],
      customer: InvoiceCustomer.fromJson(json['customer'] ?? {}),
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
      'items': items.map((item) => item.toJson()).toList(),
      'charges': charges.map((charge) => charge.toJson()).toList(),
      'customer': customer.toJson(),
    };
  }
}

class InvoiceItem {
  final int id;
  final int invoiceId;
  final int itemId;
  final int quantity;
  final String price;
  final String total;
  final String createdAt;
  final String updatedAt;
  final InvoiceItemDetails item;

  InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.itemId,
    required this.quantity,
    required this.price,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    required this.item,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] ?? 0,
      invoiceId: json['invoice_id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: json['price'] ?? '0.00',
      total: json['total'] ?? '0.00',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      item: InvoiceItemDetails.fromJson(json['item'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'item_id': itemId,
      'quantity': quantity,
      'price': price,
      'total': total,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'item': item.toJson(),
    };
  }
}

class InvoiceItemDetails {
  final int id;
  final String itemName;
  final int userId;
  final String createdAt;
  final String updatedAt;

  InvoiceItemDetails({
    required this.id,
    required this.itemName,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvoiceItemDetails.fromJson(Map<String, dynamic> json) {
    return InvoiceItemDetails(
      id: json['id'] ?? 0,
      itemName: json['item_name'] ?? '',
      userId: json['user_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_name': itemName,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class InvoiceCharge {
  final int id;
  final int invoiceId;
  final String chargeName;
  final String price;
  final String createdAt;
  final String updatedAt;

  InvoiceCharge({
    required this.id,
    required this.invoiceId,
    required this.chargeName,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvoiceCharge.fromJson(Map<String, dynamic> json) {
    return InvoiceCharge(
      id: json['id'] ?? 0,
      invoiceId: json['invoice_id'] ?? 0,
      chargeName: json['charge_name'] ?? '',
      price: json['price'] ?? '0.00',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'charge_name': chargeName,
      'price': price,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class InvoiceCustomer {
  final int id;
  final String customerName;
  final String companyName;
  final String email;
  final String phone;
  final String gst;
  final String gstTreatment;
  final String placeOfSupply;
  final String state;
  final int userId;
  final String createdAt;
  final String updatedAt;

  InvoiceCustomer({
    required this.id,
    required this.customerName,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.gst,
    required this.gstTreatment,
    required this.placeOfSupply,
    required this.state,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvoiceCustomer.fromJson(Map<String, dynamic> json) {
    return InvoiceCustomer(
      id: json['id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      companyName: json['company_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gst: json['gst'] ?? '',
      gstTreatment: json['gst_treatment'] ?? '',
      placeOfSupply: json['place_of_supply'] ?? '',
      state: json['state'] ?? '',
      userId: json['user_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'company_name': companyName,
      'email': email,
      'phone': phone,
      'gst': gst,
      'gst_treatment': gstTreatment,
      'place_of_supply': placeOfSupply,
      'state': state,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
