class PermissionKeys {
  // Modules
  static const String moduleEmployee = 'EMPLOYEE';
  static const String moduleInventory = 'INVENTORY';
  static const String moduleServices = 'SERVICES';
  static const String moduleAccess = 'ACCESS';

  // Sub-Modules: Employee
  static const String employee = 'EMPLOYEE.EMPLOYEE';
  static const String department = 'EMPLOYEE.DEPARTMENT';
  static const String designation = 'EMPLOYEE.DESIGNATION';
  static const String employeeType = 'EMPLOYEE.EMPLOYEE_TYPE';
  static const String dutyShift = 'EMPLOYEE.DUTY_SHIFT';
  static const String bank = 'EMPLOYEE.BANK';

  // Sub-Modules: Inventory
  static const String itemDefinition = 'INVENTORY.ITEM_DEFINITION';
  static const String itemRate = 'INVENTORY.ITEM_RATE';
  static const String estimation = 'INVENTORY.ESTIMATION';
  static const String openingStock = 'INVENTORY.OPENING_STOCK';
  static const String customer = 'INVENTORY.CUSTOMER';
  static const String customerGroup = 'INVENTORY.CUSTOMER_GROUP';
  static const String itemReport = 'INVENTORY.ITEM_REPORT';
  static const String quotation = 'INVENTORY.QUOTATION';

  // Sub-Modules: Services
  static const String service = 'SERVICES.SERVICE';

  // Sub-Modules: Access
  static const String users = 'ACCESS.USERS';
  static const String groups = 'ACCESS.GROUPS';
  static const String permissions = 'ACCESS.PERMISSIONS';
}
