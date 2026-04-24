import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:infinity/Provider/auth/access_control_provider.dart';
import '../../Provider/stock/StockProvider.dart';
import '../../compoents/app_theme.dart';
import '../../compoents/responsive_helper.dart';
import '../../model/stock/stock_models.dart';
import 'components/stock_card.dart';
import 'components/quotation_form_dialog.dart';
import '../../compoents/app_text_field.dart';
import '../../constants/permission_keys.dart';

class QuotationScreen extends StatefulWidget {
  const QuotationScreen({super.key});

  @override
  State<QuotationScreen> createState() => _QuotationScreenState();
}

class _QuotationScreenState extends State<QuotationScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StockProvider>(context, listen: false).fetchQuotations();
    });
  }

  void _openDialog([QuotationData? quotation]) async {
    await showQuotationFormDialog(context, quotation: quotation);
    if (mounted) {
      Provider.of<StockProvider>(context, listen: false).fetchQuotations(search: _searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final acp = Provider.of<AccessControlProvider>(context);

    final String resource = PermissionKeys.quotation;
    final bool canRead = acp.canRead(resource);
    final bool canCreate = acp.canCreate(resource);
    final bool canUpdate = acp.canUpdate(resource);

    if (!canRead) {
      return Center(
        child: AnimationConfiguration.synchronized(
          child: FadeInAnimation(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.shield_cross, size: 80, color: Colors.red.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                const Text("Access Denied", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("You don't have permission to view quotations.", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Search Quotation',
                  controller: _searchController,
                  prefixIcon: Iconsax.search_normal,
                  onChanged: (v) {
                    Provider.of<StockProvider>(context, listen: false).fetchQuotations(search: v);
                  },
                ),
              ),
              if (canCreate) ...[
                const SizedBox(width: 12),
                _buildAddButton(),
              ],
            ],
          ),
        ),
        Expanded(
          child: Consumer<StockProvider>(
            builder: (context, sp, _) {
              if (sp.isLoading && sp.quotations.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (sp.quotations.isEmpty) {
                return _buildEmptyState(canCreate);
              }
              return AnimationLimiter(
                child: RefreshIndicator(
                  onRefresh: () => sp.fetchQuotations(search: _searchController.text),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: sp.quotations.length,
                    itemBuilder: (context, index) {
                      final item = sp.quotations[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: StockCard(
                                title: item.quotationNo ?? 'No. N/A',
                                subtitle: '${item.company ?? '-'} | ${item.forProduct ?? '-'}',
                                icon: Iconsax.document_text,
                                trailing: 'PKR ${item.itemsTotal ?? '0'}',
                                onTap: canUpdate ? () => _openDialog(item) : null,
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
        onPressed: () => _openDialog(),
        icon: const Icon(Iconsax.add, color: Colors.white),
        tooltip: 'New Quotation',
      ),
    );
  }

  Widget _buildEmptyState(bool canCreate) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.document_text, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text("No Quotations Found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text("Start by creating your first quotation.", style: TextStyle(color: Colors.grey)),
          if (canCreate) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openDialog(),
              icon: const Icon(Iconsax.add),
              label: const Text('New Quotation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
