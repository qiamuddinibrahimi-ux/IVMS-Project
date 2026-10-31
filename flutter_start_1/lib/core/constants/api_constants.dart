class ApiConstants {
  // ======================================================
  // BASE URL
  // ======================================================

  static const String baseUrl =
      "http://192.168.100.47:5000/api";

  // ======================================================
  // USER AUTH
  // ======================================================

  static const String userRegister = "/auth/register";

static const String userLogin = "/auth/login";

static const String userRefresh = "/auth/refresh";

static const String userLogout = "/auth/logout";

static const String userLogoutAll = "/auth/logout-all";

static const String userMe = "/users/me";

  // ======================================================
  // ADMIN
  // ======================================================

  static const String adminLogin =
      "/admin/login";

  static const String adminMe =
      "/admin/me";

  static const String adminChangePassword =
      "/admin/me/password";

  static const String adminDeactivate =
      "/admin/me/deactivate";

  static const String adminLogout =
      "/admin/logout";

      static const String categories = "/categories";

      static const String currencies = "/currencies";
      static const String customers = "/customers";
    
    static const String customerPayments = "/customer-payments";
    static const String exchangeRates = "/exchange-rates";
    static const String items = "/items";
    static const String units = '/units';
    static const String purchases = '/purchases';
    static const String vendors = '/vendors';
    static const String purchasePayments ='/purchase-payments';
    static const String sales = '/sales';



static const String stockMovements = '/stock-movements';

    // ============================================================



    static const String salesPurchaseAllocations =
    '/sales-purchase-allocations';
    static const String inventory = '/inventory';



  // ======================================================
  // REPORTS — READ ONLY
  // ======================================================

  static const String salesReport = '/reports/sales';
  static const String purchasesReport = '/reports/purchases';

  static const String customerPaymentsReport =
      '/reports/customer-payments';

  static const String vendorPaymentsReport =
      '/reports/vendor-payments';

  static const String customerBalancesReport =
      '/reports/customer-balances';

  static const String vendorBalancesReport =
      '/reports/vendor-balances';

  static const String inventoryReport = '/reports/inventory';

  static const String itemSalesReport = '/reports/item-sales';

  static const String itemPurchasesReport =
      '/reports/item-purchases';

  static const String profitReport = '/reports/profit';

  static const String dailySummaryReport =
      '/reports/daily-summary';


}