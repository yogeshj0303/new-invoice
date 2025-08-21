class Item {
  final int id;
  final String itemName;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ItemPricing> pricings;
  final List<ItemStock> stocks;
  final List<ItemImage> otherImages;
  final ItemDetails details;

  Item({
    required this.id,
    required this.itemName,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.pricings,
    required this.stocks,
    required this.otherImages,
    required this.details,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? 0,
      itemName: json['item_name'] ?? '',
      userId: json['user_id'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      pricings: (json['pricings'] as List<dynamic>?)
          ?.map((pricing) => ItemPricing.fromJson(pricing))
          .toList() ?? [],
      stocks: (json['stocks'] as List<dynamic>?)
          ?.map((stock) => ItemStock.fromJson(stock))
          .toList() ?? [],
      otherImages: (json['other_images'] as List<dynamic>?)
          ?.map((image) => ItemImage.fromJson(image))
          .toList() ?? [],
      details: ItemDetails.fromJson(json['details'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_name': itemName,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'pricings': pricings.map((pricing) => pricing.toJson()).toList(),
      'stocks': stocks.map((stock) => stock.toJson()).toList(),
      'other_images': otherImages.map((image) => image.toJson()).toList(),
      'details': details.toJson(),
    };
  }

  // Convenience getters
  String get name => itemName;
  String get description => details.itemDescription ?? '';
  double get salesPrice => pricings.isNotEmpty ? double.tryParse(pricings.first.salespriceAmount ?? '0') ?? 0.0 : 0.0;
  double get purchasePrice => pricings.isNotEmpty ? double.tryParse(pricings.first.purchesPriceAmount ?? '0') ?? 0.0 : 0.0;
  String get category => details.itemCategoryId?.toString() ?? '';
  String get unit => pricings.isNotEmpty ? pricings.first.unit ?? '' : '';
  int get stockQuantity => stocks.isNotEmpty ? stocks.first.openingStock ?? 0 : 0;
  bool get isLowStock => stockQuantity < 10;
  bool get isOutOfStock => stockQuantity <= 0;

  // Sample items for testing
  static List<Item> getSampleItems() {
    return [
      Item(
        id: 1,
        itemName: 'Butter',
        userId: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        pricings: [
          ItemPricing(
            id: 1,
            itemId: 1,
            unit: 'BOX',
            salespriceAmount: '220.00',
            salespriceTax: 1,
            purchesPriceAmount: '190.00',
            purchesPriceTax: 1,
            mrpPrice: '250.00',
            gst: '18.00',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
        stocks: [
          ItemStock(
            id: 1,
            itemId: 1,
            openingStock: 5,
            asOfDate: DateTime.now().subtract(const Duration(days: 1)),
            itemName: 'Butter',
            lowAlertStatus: 'true',
            lowAlertQuantity: 10,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
        otherImages: [],
        details: ItemDetails(
          id: 1,
          itemId: 1,
          itemCategoryId: 1,
          itemDescription: 'Amul Butter 500gm',
          showOnlineStore: 'false',
          userId: 1,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ),
    ];
  }
}

class ItemPricing {
  final int id;
  final int itemId;
  final String unit;
  final String? salespriceAmount;
  final int salespriceTax;
  final String? purchesPriceAmount;
  final int purchesPriceTax;
  final String? mrpPrice;
  final String? gst;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemPricing({
    required this.id,
    required this.itemId,
    required this.unit,
    this.salespriceAmount,
    required this.salespriceTax,
    this.purchesPriceAmount,
    required this.purchesPriceTax,
    this.mrpPrice,
    this.gst,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemPricing.fromJson(Map<String, dynamic> json) {
    return ItemPricing(
      id: json['id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      unit: json['unit'] ?? '',
      salespriceAmount: json['salesprice_amount'],
      salespriceTax: json['salesprice_tax'] ?? 0,
      purchesPriceAmount: json['purches_price_amount'],
      purchesPriceTax: json['purches_price_tax'] ?? 0,
      mrpPrice: json['mrp_price'],
      gst: json['gst'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'unit': unit,
      'salesprice_amount': salespriceAmount,
      'salesprice_tax': salespriceTax,
      'purches_price_amount': purchesPriceAmount,
      'purches_price_tax': purchesPriceTax,
      'mrp_price': mrpPrice,
      'gst': gst,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ItemStock {
  final int id;
  final int itemId;
  final int openingStock;
  final DateTime? asOfDate;
  final String itemName;
  final String lowAlertStatus;
  final int? lowAlertQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemStock({
    required this.id,
    required this.itemId,
    required this.openingStock,
    this.asOfDate,
    required this.itemName,
    required this.lowAlertStatus,
    this.lowAlertQuantity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemStock.fromJson(Map<String, dynamic> json) {
    return ItemStock(
      id: json['id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      openingStock: json['opening_stock'] ?? 0,
      asOfDate: json['as_of_date'] != null ? DateTime.tryParse(json['as_of_date']) : null,
      itemName: json['item_name'] ?? '',
      lowAlertStatus: json['low_alert_status'] ?? 'false',
      lowAlertQuantity: json['low_alert_quantity'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'opening_stock': openingStock,
      'as_of_date': asOfDate?.toIso8601String(),
      'item_name': itemName,
      'low_alert_status': lowAlertStatus,
      'low_alert_quantity': lowAlertQuantity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ItemImage {
  final int id;
  final int itemId;
  final String imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemImage({
    required this.id,
    required this.itemId,
    required this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemImage.fromJson(Map<String, dynamic> json) {
    return ItemImage(
      id: json['id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      imagePath: json['image_path'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ItemDetails {
  final int id;
  final int itemId;
  final int? itemCategoryId;
  final String? itemDescription;
  final String showOnlineStore;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemDetails({
    required this.id,
    required this.itemId,
    this.itemCategoryId,
    this.itemDescription,
    required this.showOnlineStore,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemDetails.fromJson(Map<String, dynamic> json) {
    // Handle both string and int types for showOnlineStore
    String showOnlineStore;
    if (json['show_online_store'] != null) {
      if (json['show_online_store'] is int) {
        showOnlineStore = json['show_online_store'] == 1 ? 'true' : 'false';
      } else {
        showOnlineStore = json['show_online_store'].toString();
      }
    } else {
      showOnlineStore = 'false';
    }
    
    return ItemDetails(
      id: json['id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      itemCategoryId: json['item_category_id'],
      itemDescription: json['item_description'],
      showOnlineStore: showOnlineStore,
      userId: json['user_id'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'item_category_id': itemCategoryId,
      'item_description': itemDescription,
      'show_online_store': showOnlineStore,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
