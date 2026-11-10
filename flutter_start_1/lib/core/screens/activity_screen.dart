import 'package:flutter/material.dart';
import '../network/api_client.dart';
import '../storage/storage_service.dart';
import '../screens/qiamuddin_design.dart'; // ✅ Added QiamuddinDesign

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  
  // Raw data from API
  List<dynamic> _rawUsers = [];
  List<dynamic> _rawSales = [];
  List<dynamic> _rawPurchases = [];

  @override
  void initState() {
    super.initState();
    _loadActivity();

    // Listen to search input
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadActivity() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await StorageService.getAdminToken();
      final response = await _apiClient.get('/admin/activity', token: token);
      
      if (!mounted) return;

      setState(() {
        _rawUsers = response['new_users'] ?? [];
        _rawSales = response['new_sales'] ?? [];
        _rawPurchases = response['new_purchases'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ✅ Filter Logic
  List<dynamic> get _filteredUsers {
    if (_searchQuery.isEmpty) return _rawUsers;
    return _rawUsers.where((u) {
      final name = (u['name'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery);
    }).toList();
  }

  List<dynamic> get _filteredSales {
    if (_searchQuery.isEmpty) return _rawSales;
    return _rawSales.where((s) {
      final invoice = (s['invoice_no'] ?? '').toString().toLowerCase();
      final userName = (s['user_name'] ?? '').toString().toLowerCase();
      return invoice.contains(_searchQuery) || userName.contains(_searchQuery);
    }).toList();
  }

  List<dynamic> get _filteredPurchases {
    if (_searchQuery.isEmpty) return _rawPurchases;
    return _rawPurchases.where((p) {
      final invoice = (p['invoice_no'] ?? '').toString().toLowerCase();
      final userName = (p['user_name'] ?? '').toString().toLowerCase();
      return invoice.contains(_searchQuery) || userName.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: const Text(
          'System Activity',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActivity,
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ QIAMUDDIN SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: QiamuddinDesign.searchBar(
              context: context,
              controller: _searchController,
              hintText: 'Search by name, invoice, etc...',
              onClear: () => _searchController.clear(),
              hasText: _searchQuery.isNotEmpty,
            ),
          ),

          // BODY
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Error loading activity: $_error',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadActivity,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            // ==========================================
                            // NEWEST USERS
                            // ==========================================
                            _buildSectionHeader(
                              title: "Newest Users",
                              icon: Icons.people_alt_rounded,
                              color: Colors.blue,
                              theme: theme,
                            ),
                            if (_filteredUsers.isEmpty)
                              _buildEmptyState("No matching users found.", theme)
                            else
                              ..._filteredUsers.map((u) => _buildActivityCard(
                                    theme: theme,
                                    icon: Icons.person_add_rounded,
                                    iconColor: Colors.blue,
                                    title: u['name']?.toString() ?? 'Unknown User',
                                    subtitle: "Joined on ${_formatDate(u['created_at'])}",
                                  )),

                            const SizedBox(height: 24),

                            // ==========================================
                            // LATEST SALES
                            // ==========================================
                            _buildSectionHeader(
                              title: "Latest Sales",
                              icon: Icons.point_of_sale_rounded,
                              color: Colors.green,
                              theme: theme,
                            ),
                            if (_filteredSales.isEmpty)
                              _buildEmptyState("No matching sales found.", theme)
                            else
                              ..._filteredSales.map((s) => _buildActivityCard(
                                    theme: theme,
                                    icon: Icons.receipt_long_rounded,
                                    iconColor: Colors.green,
                                    title: "Invoice: ${s['invoice_no'] ?? 'Sale #${s['sale_id']}'}",
                                    subtitle: "By: ${s['user_name'] ?? 'Unknown'} • ${_formatDate(s['sale_date'])}",
                                  )),

                            const SizedBox(height: 24),

                            // ==========================================
                            // LATEST PURCHASES
                            // ==========================================
                            _buildSectionHeader(
                              title: "Latest Purchases",
                              icon: Icons.shopping_bag_rounded,
                              color: Colors.orange,
                              theme: theme,
                            ),
                            if (_filteredPurchases.isEmpty)
                              _buildEmptyState("No matching purchases found.", theme)
                            else
                              ..._filteredPurchases.map((p) => _buildActivityCard(
                                    theme: theme,
                                    icon: Icons.shopping_cart_rounded,
                                    iconColor: Colors.orange,
                                    title: "Invoice: ${p['invoice_no'] ?? 'Purchase #${p['purchase_id']}'}",
                                    subtitle: "By: ${p['user_name'] ?? 'Unknown'} • ${_formatDate(p['purchase_date'])}",
                                  )),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPERS
  // ==========================================

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown date';
    final str = date.toString();
    return str.split('T').first; // Shows only YYYY-MM-DD
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: theme.hintColor, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        message,
        style: TextStyle(color: theme.hintColor),
      ),
    );
  }
}