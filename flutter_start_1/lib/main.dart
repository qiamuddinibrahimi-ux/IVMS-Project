import 'package:flutter_start_1/core/screens/splash_screen.dart';

import 'core/network/api_client.dart';
import 'core/services/sales_detail_service.dart';
import 'core/providers/sales_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ✅ Localization imports
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_localizations.dart';
import 'core/providers/locale_provider.dart';

// ✅ ADDED: Theme provider for Light / Dark / System
import 'core/providers/theme_provider.dart';

import 'core/services/inventory_service.dart';
import 'core/repositories/inventory_repository.dart';
import 'core/providers/inventory_provider.dart';
import 'core/services/stock_movement_service.dart';
import 'core/repositories/stock_movement_repository.dart';
import 'core/providers/stock_movement_provider.dart';
import 'core/services/report_service.dart';
import 'core/repositories/report_repository.dart';
import 'core/providers/report_provider.dart';
import 'core/services/purchase_detail_service.dart';
import 'core/providers/purchase_detail_provider.dart';

// ======================================================
// CORE
// ======================================================
import 'core/storage/storage_service.dart';

// ======================================================
// SERVICES
// ======================================================
import 'core/services/admin_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/user_service.dart';
import 'core/services/category_service.dart';
import 'core/services/currency_service.dart';
import 'core/services/customer_service.dart';
import 'core/services/customer_payment_service.dart';
import 'core/services/exchange_rate_service.dart';
import 'core/services/item_service.dart';
import 'core/services/unit_service.dart';
import 'core/services/vendor_service.dart';
import 'core/services/purchase_service.dart';
import 'core/services/purchase_payment_service.dart';
import 'core/services/sale_service.dart';
import 'core/services/sales_purchase_allocation_service.dart';

// ======================================================
// REPOSITORIES
// ======================================================
import 'core/repositories/admin_repository.dart';
import 'core/repositories/auth_repository.dart';
import 'core/repositories/category_repository.dart';
import 'core/repositories/currency_repository.dart';
import 'core/repositories/customer_repository.dart';
import 'core/repositories/customer_payment_repository.dart';
import 'core/repositories/exchange_rate_repository.dart';
import 'core/repositories/item_repository.dart';
import 'core/repositories/unit_repository.dart';
import 'core/repositories/vendor_repository.dart';
import 'core/repositories/purchase_repository.dart';
import 'core/repositories/purchase_payment_repository.dart';
import 'core/repositories/sale_repository.dart';
import 'core/repositories/sales_purchase_allocation_repository.dart';

// ======================================================
// PROVIDERS
// ======================================================
import 'core/providers/admin_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/category_provider.dart';
import 'core/providers/currency_provider.dart';
import 'core/providers/customer_provider.dart';
import 'core/providers/customer_payment_provider.dart';
import 'core/providers/exchange_rate_provider.dart';
import 'core/providers/item_provider.dart';
import 'core/providers/unit_provider.dart';
import 'core/providers/vendor_provider.dart';
import 'core/providers/purchase_provider.dart';
import 'core/providers/purchase_payment_provider.dart';
import 'core/providers/sale_provider.dart';
import 'core/providers/sales_purchase_allocation_provider.dart';

// ======================================================
// SCREENS
// ======================================================
import 'core/screens/auth_gate_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ====================================================
  // SHARED CORE
  // ====================================================
  final apiClient = ApiClient();
  final storageService = StorageService();

  final reportService = ReportService(apiClient: apiClient);
  final reportRepository = ReportRepository(reportService: reportService);

  final stockMovementService = StockMovementService(apiClient: apiClient);
  final stockMovementRepository =
      StockMovementRepository(stockMovementService: stockMovementService);

  final inventoryService = InventoryService(apiClient: apiClient);
  final inventoryRepository =
      InventoryRepository(inventoryService: inventoryService);

  // ====================================================
  // SERVICES
  // ====================================================
  final adminService = AdminService(apiClient: apiClient);
  final authService = AuthService(apiClient: apiClient);
  final userService = UserService(apiClient: apiClient);
  final categoryService = CategoryService(apiClient: apiClient);
  final currencyService = CurrencyService(apiClient: apiClient);
  final customerService = CustomerService(apiClient: apiClient);
  final customerPaymentService =
      CustomerPaymentService(apiClient: apiClient);
  final exchangeRateService = ExchangeRateService(apiClient: apiClient);
  final itemService = ItemService(apiClient: apiClient);
  final unitService = UnitService(apiClient: apiClient);
  final vendorService = VendorService(apiClient: apiClient);
  final purchaseService = PurchaseService(apiClient: apiClient);
  final purchasePaymentService =
      PurchasePaymentService(apiClient: apiClient);
  final saleService = SaleService(apiClient: apiClient);

  final allocationService = SalesPurchaseAllocationService(apiClient);
  final allocationRepository =
      SalesPurchaseAllocationRepository(allocationService);

  // ====================================================
  // REPOSITORIES
  // ====================================================
  final adminRepository = AdminRepository(adminService: adminService);
  final authRepository = AuthRepository(
    authService: authService,
    userService: userService,
  );
  final categoryRepository =
      CategoryRepository(categoryService: categoryService);
  final currencyRepository =
      CurrencyRepository(currencyService: currencyService);
  final customerRepository =
      CustomerRepository(customerService: customerService);
  final customerPaymentRepository = CustomerPaymentRepository(
    customerPaymentService: customerPaymentService,
  );
  final exchangeRateRepository =
      ExchangeRateRepository(exchangeRateService: exchangeRateService);
  final itemRepository = ItemRepository(itemService: itemService);
  final unitRepository = UnitRepository(unitService: unitService);
  final vendorRepository = VendorRepository(vendorService: vendorService);
  final purchaseRepository =
      PurchaseRepository(purchaseService: purchaseService);
  final purchasePaymentRepository = PurchasePaymentRepository(
    service: purchasePaymentService,
  );
  final saleRepository = SaleRepository(service: saleService);

  // ====================================================
  // PROVIDERS + APP
  // ====================================================
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AdminProvider(repository: adminRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(repository: categoryRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CurrencyProvider(repository: currencyRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CustomerProvider(repository: customerRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CustomerPaymentProvider(
            repository: customerPaymentRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ExchangeRateProvider(
            repository: exchangeRateRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ItemProvider(repository: itemRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => UnitProvider(repository: unitRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => VendorProvider(repository: vendorRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => PurchaseProvider(repository: purchaseRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => PurchasePaymentProvider(
            repository: purchasePaymentRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SaleProvider(repository: saleRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => PurchaseDetailProvider(
            service: PurchaseDetailService(apiClient: apiClient),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => StockMovementProvider(
            repository: stockMovementRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SalesPurchaseAllocationProvider(allocationRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => InventoryProvider(repository: inventoryRepository),
        ),
        ChangeNotifierProvider<ReportProvider>(
          create: (_) => ReportProvider(repository: reportRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => SalesDetailProvider(
            service: SalesDetailService(apiClient: apiClient),
          ),
        ),
        // ✅ LocaleProvider for language switching
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        // ✅ ADDED: ThemeProvider for light/dark mode switching
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// ======================================================
// APP
// ======================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Watch LocaleProvider + ThemeProvider
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>(); // ✅ ADDED

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AlMadina Inventory Management System',

      // ============================
      // LOCALIZATION
      // ============================
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ============================
      // LIGHT THEME (unchanged)
      // ============================
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: const Color(0xFF102C4A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF102C4A),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF102C4A),
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF102C4A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),

      // ============================
      // DARK THEME (unchanged)
      // ============================
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF102C4A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF102C4A),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        cardColor: const Color(0xFF2C2C2C),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE0E0E0),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),

      // ============================
      // ✅ DYNAMIC THEME MODE
      //    (light / dark / system from ThemeProvider)
      // ============================
      themeMode: themeProvider.themeMode,

      // ============================
      // ENTRY POINT
      // ============================
      home: const AuthGateScreen(),
    );
  }
}