class ApiConfig {
  // Use 10.0.2.2 for Android Emulator, localhost for Windows/iOS/Web
  // If using a physical phone, use your machine's IP (e.g., http://192.168.1.100:5000/api)
  static const String baseUrl = 'http://10.0.2.2:5000/api'; 
  // static const String baseUrl = 'http://localhost:5000/api'; 

  // Auth endpoints
  static const String loginUrl = '$baseUrl/auth/login';
  // Resource endpoints
  static const String employeesUrl = '$baseUrl/employees';
  static const String itemDefinitionsUrl = '$baseUrl/item-definitions';
  static const String servicesUrl = '$baseUrl/services';
  static const String openingStockUrl = '$baseUrl/opening-stock';
  static const String itemRatesUrl = '$baseUrl/item-rates';
  static const String quotationsUrl = '$baseUrl/quotations';
  static const String estimationsUrl = '$baseUrl/estimations';
  static const String customersUrl = '$baseUrl/customers';

  // Quotation Helpers
  static const String quotationsNextNoUrl = '$quotationsUrl/next-no';
  static const String quotationsNextRevisionUrl = '$quotationsUrl/next-revision';
  static const String quotationsRevisionUrl = '$quotationsUrl/revision';

  // Setup options for Stock
  static const String itemTypesUrl = '$baseUrl/item-types';
  static const String categoriesUrl = '$baseUrl/categories';
  static const String subCategoriesUrl = '$baseUrl/sub-categories';
  static const String manufacturersUrl = '$baseUrl/manufacturers';
  static const String suppliersUrl = '$baseUrl/suppliers';
  static const String unitsUrl = '$baseUrl/units';
  static const String locationsUrl = '$baseUrl/locations';
  static const String productsUrl = '$baseUrl/products';
  static const String dashboardUrl = '$baseUrl/dashboard';

  // Setup options for Staff
  static const String departmentsUrl = '$baseUrl/departments';
  static const String designationsUrl = '$baseUrl/designations';
  static const String employeeTypesUrl = '$baseUrl/employee-types';
  static const String dutyShiftsUrl = '$baseUrl/duty-shifts';
  static const String banksUrl = '$baseUrl/banks';

  // Item Rate Helpers
  static const String itemDetailsUrl = '$baseUrl/item-definitions'; // GET /item-definitions/:id
  static const String itemQuotationUrl = '$baseUrl/item-rates/quotation-id'; // GET /item-rates/quotation-id?supplierId=...&itemId=...
  static const String exchangeRateUrl = 'https://v6.exchangerate-api.com/v6/9609f0d93ee61c0884cde4e6/pair/USD/PKR';

  // Image helpers
  static const String uploadsUrl = 'http://10.0.2.2:5000'; // Base URL for public files

  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith('http')) return path;
    // Normalize path and join with uploadsUrl
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$uploadsUrl$cleanPath';
  }
}
