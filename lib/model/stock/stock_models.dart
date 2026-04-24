class OpeningStockData {
  final String? id;
  final String? code;
  final String? itemName;
  final String? itemType;
  final String? category;
  final String? subCategory;
  final String? purchasePrice;
  final String? salePrice;
  final String? stock;
  final String? imageName;

  OpeningStockData({
    this.id,
    this.code,
    this.itemName,
    this.itemType,
    this.category,
    this.subCategory,
    this.purchasePrice,
    this.salePrice,
    this.stock,
    this.imageName,
  });

  factory OpeningStockData.fromJson(Map<String, dynamic> json) {
    return OpeningStockData(
      id: (json['id'] ?? json['_id'])?.toString(),
      code: (json['item_code'] ?? json['code'])?.toString(),
      itemName: (json['item_name'] ?? json['itemName'] ?? json['name'])?.toString(),
      itemType: (json['item_type_name'] ?? json['itemType'])?.toString(),
      category: (json['category_name'] ?? json['category'])?.toString(),
      subCategory: (json['sub_category_name'] ?? json['subCategory'])?.toString(),
      purchasePrice: (json['purchase_price'] ?? json['purchasePrice'])?.toString(),
      salePrice: (json['sale_price'] ?? json['salePrice'])?.toString(),
      stock: (json['stock'] ?? json['unit_qty'] ?? json['unitQty'])?.toString(),
      imageName: (json['image'] ?? json['image_url'] ?? json['imageName'])?.toString(),
    );
  }
}

class ItemRateData {
  final String? id;
  final String? item;
  final String? category;
  final String? subCategory;
  final String? supplier;
  final String? reseller;
  final String? sale;
  final String? salePrice;
  final String? itemSpecification;
  final String? specification;
  final String? description;
  final String? manufacturer;
  final Map<String, dynamic>? raw;

  ItemRateData({
    this.id,
    this.item,
    this.category,
    this.subCategory,
    this.supplier,
    this.reseller,
    this.sale,
    this.salePrice,
    this.itemSpecification,
    this.specification,
    this.description,
    this.manufacturer,
    this.raw,
  });

  factory ItemRateData.fromJson(Map<String, dynamic> json) {
    return ItemRateData(
      id: (json['id'] ?? json['_id'])?.toString(),
      item: (json['item_name'] ?? json['itemName'] ?? json['item'] ?? json['item_definition_name'] ?? json['itemDefinitionName'])?.toString(),
      category: (json['category_name'] ?? json['categoryName'] ?? json['category'])?.toString(),
      subCategory: (json['sub_category_name'] ?? json['subCategoryName'] ?? json['subCategory'])?.toString(),
      supplier: (json['supplier_name'] ?? json['supplierName'] ?? json['supplier'])?.toString(),
      reseller: (json['reseller_price'] ?? json['resellerPrice'] ?? json['reseller_rate'] ?? json['reseller'])?.toString(),
      sale: (json['sale_price'] ?? json['salePrice'] ?? json['sale'])?.toString(),
      salePrice: (json['sale_price'] ?? json['salePrice'] ?? json['sale'])?.toString(),
      itemSpecification: (json['item_specification'] ?? json['itemSpecification'] ?? json['specification'] ?? json['description'])?.toString(),
      specification: (json['item_specification'] ?? json['itemSpecification'] ?? json['specification'])?.toString(),
      description: (json['item_specification'] ?? json['itemSpecification'] ?? json['specification'] ?? json['description'])?.toString(),
      manufacturer: (json['manufacturer_name'] ?? json['manufacturerName'] ?? json['manufacturer'])?.toString(),
      raw: json['raw'] ?? json,
    );
  }
}

class QuotationData {
  final String? id;
  final String? quotationNo;
  final String? customerId;
  final String? company;
  final String? person;
  final String? designation;
  final String? department;
  final String? taxMode;
  final String? letterType;
  final String? forProduct;
  final String? serviceId;
  final String? estimationId;
  final String? revisionId;
  final String? itemsTotal;
  final String? status;
  final String? createdBy;
  final List<dynamic>? items;
  final String? day;
  final String? month;
  final String? year;

  QuotationData({
    this.id,
    this.quotationNo,
    this.customerId,
    this.company,
    this.person,
    this.designation,
    this.department,
    this.taxMode,
    this.letterType,
    this.forProduct,
    this.serviceId,
    this.estimationId,
    this.revisionId,
    this.itemsTotal,
    this.status,
    this.createdBy,
    this.items,
    this.day,
    this.month,
    this.year,
  });

  factory QuotationData.fromJson(Map<String, dynamic> json) {
    return QuotationData(
      id: (json['id'] ?? json['_id'])?.toString(),
      quotationNo: (json['quotation_no'] ?? json['quotationNo'])?.toString(),
      customerId: (json['customer_id'] ?? json['customerId'])?.toString(),
      company: (json['company_name'] ?? json['company'])?.toString(),
      person: (json['person'] ?? json['contact_person'])?.toString(),
      designation: json['designation']?.toString(),
      department: json['department']?.toString(),
      taxMode: json['tax_mode']?.toString(),
      letterType: json['letter_type']?.toString(),
      forProduct: (json['for_product'] ?? json['forProduct'] ?? json['product'])?.toString(),
      serviceId: (json['service_id'] ?? json['serviceId'])?.toString(),
      estimationId: (json['estimation_id'] ?? json['estimationId'])?.toString(),
      revisionId: (json['revision_id'] ?? json['revisionId'] ?? json['docId'])?.toString(),
      itemsTotal: (json['items_total'] ?? json['itemsTotal'])?.toString(),
      status: json['status']?.toString(),
      createdBy: (json['created_by'] ?? json['createdBy'])?.toString(),
      items: json['items'],
      day: json['day']?.toString(),
      month: json['month']?.toString(),
      year: json['year']?.toString(),
    );
  }
}

class CustomerData {
  final String? id;
  final String? code;
  final String? name;
  final String? company;
  final String? person;
  final String? designation;
  final String? department;
  final String? email;
  final String? mobile;

  CustomerData({
    this.id,
    this.code,
    this.name,
    this.company,
    this.person,
    this.designation,
    this.department,
    this.email,
    this.mobile,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      id: (json['id'] ?? json['_id'] ?? json['uuid'])?.toString(),
      code: (json['customer_code'] ?? json['code'] ?? json['customerCode'])?.toString(),
      name: (json['customer_name'] ?? json['name'] ?? json['company'] ?? json['customerName'])?.toString(),
      company: (json['company'] ?? json['customer_name'] ?? json['name'] ?? json['customerCompany'])?.toString(),
      person: (json['person'] ?? json['contact_person'] ?? json['customer_person'] ?? json['customerPerson'] ?? json['representative'])?.toString(),
      designation: (json['designation'] ?? json['customer_designation'] ?? json['customerDesignation'])?.toString(),
      department: (json['department'] ?? json['customer_department'] ?? json['customerDepartment'])?.toString(),
      email: json['email']?.toString(),
      mobile: (json['mobile'] ?? json['phone'] ?? json['office_phone'] ?? json['officePhone'])?.toString(),
    );
  }
}

class EstimationData {
  final String? id;
  final String? estimateId;
  final String? estimateDate;
  final String? customerName;
  final String? company;
  final String? customerId;
  final String? person;
  final String? designation;
  final String? department;
  final String? serviceName;
  final String? serviceId;
  final String? discountTotal;
  final String? finalTotal;
  final String? status;
  final List<dynamic>? items;

  EstimationData({
    this.id,
    this.estimateId,
    this.estimateDate,
    this.customerName,
    this.company,
    this.customerId,
    this.person,
    this.designation,
    this.department,
    this.serviceName,
    this.serviceId,
    this.discountTotal,
    this.finalTotal,
    this.status,
    this.items,
  });

  factory EstimationData.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] is Map ? json['customer'] : {};
    final service = json['service'] is Map ? json['service'] : {};

    return EstimationData(
      id: (json['id'] ?? json['_id'] ?? json['uuid'])?.toString(),
      estimateId: (json['estimate_id'] ?? json['estimateId'])?.toString(),
      estimateDate: (json['estimate_date'] ?? json['estimateDate'])?.toString(),
      customerName: (json['customerCompany'] ?? json['customer_name'] ?? json['customerName'] ?? customer['company'] ?? customer['customer_name'])?.toString(),
      company: (json['company'] ?? json['company_name'] ?? json['customer_name'] ?? json['customerName'] ?? customer['company'])?.toString(),
      customerId: (json['customer_id'] ?? json['customerId'])?.toString(),
      person: (json['person'] ?? json['customer_person'] ?? json['customerPerson'] ?? json['contact_person'])?.toString(),
      designation: (json['designation'] ?? json['customer_designation'] ?? json['customerDesignation'])?.toString(),
      department: (json['department'] ?? json['customer_department'] ?? json['customerDepartment'] ?? customer['department'])?.toString(),
      serviceName: (json['service'] ?? json['service_name'] ?? json['serviceName'] ?? service['service_name'])?.toString(),
      serviceId: (json['service_id'] ?? json['serviceId'])?.toString(),
      discountTotal: (json['discount_total'] ?? json['discountTotal'] ?? json['total_discount'] ?? json['totalDiscount'])?.toString(),
      finalTotal: (json['final_total'] ?? json['finalTotal'] ?? json['total_final'] ?? json['totalFinal'])?.toString(),
      status: (json['status'] ?? 'active')?.toString(),
      items: json['items'],
    );
  }
}
