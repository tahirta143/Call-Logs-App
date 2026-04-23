import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinity/Provider/auth/access_control_provider.dart';
import 'package:provider/provider.dart';
import '../../Provider/stock/StockProvider.dart';
import '../../compoents/app_theme.dart';
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
      Provider.of<StockProvider>(context, listen: false).fetchQuotations();
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.shield_cross, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text("Access Denied", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("You don't have permission to view quotations.",
                style: TextStyle(color: Colors.grey.shade600)),
          ],
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
                  prefixIcon: Icons.search,
                  onChanged: (v) {
                    Provider.of<StockProvider>(context, listen: false)
                        .fetchQuotations(search: v);
                  },
                ),
              ),
              if (canCreate) ...[
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => _openDialog(),
                    icon: const Icon(Icons.add, color: Colors.white),
                    tooltip: 'New Quotation',
                  ),
                ),
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.document_text, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No quotations found', style: TextStyle(color: Colors.grey.shade500)),
                      if (canCreate) ...[
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => _openDialog(),
                          icon: const Icon(Icons.add),
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
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: sp.quotations.length,
                itemBuilder: (context, index) {
                  final item = sp.quotations[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: StockCard(
                      title: item.quotationNo ?? 'No. N/A',
                      subtitle: '${item.company ?? '-'} | ${item.forProduct ?? '-'}',
                      icon: Iconsax.document_text,
                      trailing: 'PKR ${item.itemsTotal ?? '0'}',
                      onTap: canUpdate ? () => _openDialog(item) : null,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
