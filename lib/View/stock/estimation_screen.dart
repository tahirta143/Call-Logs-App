import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../Provider/stock/StockProvider.dart';
import '../../Provider/auth/access_control_provider.dart';
import '../../compoents/app_theme.dart';
import '../../compoents/app_text_field.dart';
import '../../compoents/responsive_helper.dart';
import '../../model/stock/stock_models.dart';
import '../../constants/permission_keys.dart';
import 'components/stock_card.dart';
import 'components/estimation_form_dialog.dart';

class EstimationScreen extends StatefulWidget {
  const EstimationScreen({super.key});

  @override
  State<EstimationScreen> createState() => _EstimationScreenState();
}

class _EstimationScreenState extends State<EstimationScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sp = Provider.of<StockProvider>(context, listen: false);
      sp.fetchEstimations();
      sp.loadSetupOptions();
    });
  }

  void _openForm([EstimationData? estimation]) {
    AppTheme.showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      child: EstimationFormDialog(estimation: estimation),
    ).then((_) {
      if (mounted) {
        Provider.of<StockProvider>(context, listen: false).fetchEstimations(search: _searchController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final acp = Provider.of<AccessControlProvider>(context);
    final String resource = PermissionKeys.estimation;
    final bool canRead = acp.canRead(resource);
    final bool canCreate = acp.canCreate(resource);

    if (!canRead) {
      return _buildAccessDenied();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Summary Cards Section
          _buildSummarySection(),

          // Search and Add Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: AppTextField(
                      label: 'Search Estimations',
                      controller: _searchController,
                      prefixIcon: Iconsax.search_normal,
                      onChanged: (v) {
                        Provider.of<StockProvider>(context, listen: false).fetchEstimations(search: v);
                      },
                    ),
                  ),
                ),
                if (canCreate) ...[
                  const SizedBox(width: 12),
                  _buildAddButton(),
                ],
              ],
            ),
          ),

          // List Section
          Expanded(
            child: Consumer<StockProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.estimations.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.estimations.isEmpty) {
                  return _buildEmptyState();
                }
                return AnimationLimiter(
                  child: RefreshIndicator(
                    onRefresh: () => provider.fetchEstimations(search: _searchController.text),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: provider.estimations.length,
                      itemBuilder: (context, index) {
                        final item = provider.estimations[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: StockCard(
                                  title: item.estimateId ?? 'No ID',
                                  subtitle: '${item.customerName ?? "No Customer"} | ${item.serviceName ?? "No Service"}',
                                  icon: Iconsax.document_text,
                                  trailing: 'PKR ${item.finalTotal ?? "0.00"}',
                                  status: item.status,
                                  onTap: () => _openForm(item),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () => _openForm(),
        icon: const Icon(Iconsax.add, color: Colors.white),
        tooltip: 'New Estimation',
      ),
    );
  }

  Widget _buildSummarySection() {
    return Consumer<StockProvider>(
      builder: (context, provider, child) {
        final summary = provider.estimationSummary;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: AnimationLimiter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    _buildSummaryCard('Purchases', summary['totalPurchases'] ?? 0, Iconsax.box),
                    _buildSummaryCard('Discount', summary['totalDiscount'] ?? 0, Iconsax.ticket_discount),
                    _buildSummaryCard('Revenue', summary['totalFinal'] ?? 0, Iconsax.receipt_2),
                    _buildSummaryCard('Profit', summary['profit'] ?? 0, Iconsax.trend_up),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, dynamic value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppTheme.primaryColor;
    final displayValue = double.tryParse(value.toString()) ?? 0.0;

    final cardWidth = Responsive.isSmallScreen(context) ? 160.0 : 200.0;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[100]!),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(
            'PKR ${displayValue.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: isDark ? Colors.white : Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.shield_cross, size: 80, color: Colors.red.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text("Access Denied", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("You don't have permission to view this module.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.document_text, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text("No Estimations Found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text("Start by creating your first estimation.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
