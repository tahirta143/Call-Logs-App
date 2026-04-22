class ItemData {
  final String? id;
  final String? code;
  final String? itemName;
  String? get name => itemName;
  final String? itemType;
  final String? category;
  final String? subCategory;
  final String? manufacturer;
  final String? supplier;
  final String? unit;
  final String? unitQty;
  final String? minLevelQty;
  final String? location;
  final String? itemSpecification;
  final String? purchasePrice;
  final String? salePrice;
  final String? primaryBarcode;
  final String? secondaryBarcode;
  final String? expirable;
  final String? expiryDays;
  final String? costItem;
  final String? stopSale;
  final String? imageName;
  final String? status;

  ItemData({
    this.id,
    this.code,
    this.itemName,
    this.itemType,
    this.category,
    this.subCategory,
    this.manufacturer,
    this.supplier,
    this.unit,
    this.unitQty,
    this.minLevelQty,
    this.location,
    this.itemSpecification,
    this.purchasePrice,
    this.salePrice,
    this.primaryBarcode,
    this.secondaryBarcode,
    this.expirable,
    this.expiryDays,
    this.costItem,
    this.stopSale,
    this.imageName,
    this.status,
  });

  factory ItemData.fromJson(Map<String, dynamic> json) {
    return ItemData(
      id: (json['id'] ?? json['_id'] ?? json['uuid'])?.toString(),
      code: (json['item_code'] ?? json['code'])?.toString(),
      itemName: (json['item_name'] ?? json['itemName'] ?? json['name'])?.toString(),
      itemType: (json['item_type_name'] ?? json['itemType'] ?? json['item_type'])?.toString(),
      category: (json['category_name'] ?? json['category'])?.toString(),
      subCategory: (json['sub_category_name'] ?? json['subCategory'] ?? json['sub_category'])?.toString(),
      manufacturer: (json['manufacturer_name'] ?? json['manufacturer'])?.toString(),
      supplier: (json['supplier_name'] ?? json['supplier'])?.toString(),
      unit: (json['unit_name'] ?? json['unit'])?.toString(),
      unitQty: (json['unit_qty'] ?? json['unitQty'])?.toString(),
      minLevelQty: (json['reorder_level'] ?? json['minLevelQty'] ?? json['min_level_qty'])?.toString(),
      location: (json['location_name'] ?? json['location'])?.toString(),
      itemSpecification: (json['item_specification'] ?? json['itemSpecification'])?.toString(),
      purchasePrice: (json['purchase_price'] ?? json['purchasePrice'])?.toString(),
      salePrice: (json['sale_price'] ?? json['salePrice'])?.toString(),
      primaryBarcode: (json['primary_barcode'] ?? json['primaryBarcode'])?.toString(),
      secondaryBarcode: (json['secondary_barcode'] ?? json['secondaryBarcode'])?.toString(),
      expirable: (json['is_expirable'] ?? json['expirable'])?.toString(),
      expiryDays: (json['expiry_days'] ?? json['expiryDays'])?.toString(),
      costItem: (json['is_cost_item'] ?? json['costItem'])?.toString(),
      stopSale: (json['stop_sale'] ?? json['stopSale'])?.toString(),
      imageName: (json['image'] ?? json['image_path'] ?? json['imageName'])?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'itemName': itemName,
      'itemType': itemType,
      'category': category,
      'subCategory': subCategory,
      'manufacturer': manufacturer,
      'supplier': supplier,
      'unit': unit,
      'unitQty': unitQty,
      'minLevelQty': minLevelQty,
      'location': location,
      'itemSpecification': itemSpecification,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'primaryBarcode': primaryBarcode,
      'secondaryBarcode': secondaryBarcode,
      'expirable': expirable,
      'expiryDays': expiryDays,
      'costItem': costItem,
      'stopSale': stopSale,
      'imageName': imageName,
      'status': status,
    };
  }
}
