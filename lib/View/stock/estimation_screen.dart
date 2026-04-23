import 'package:flutter/material.dart';
import 'package:infinity/Provider/auth/access_control_provider.dart';
import 'package:provider/provider.dart';
import '../../Provider/stock/StockProvider.dart';
import '../../compoents/premium_card.dart';
import '../../compoents/app_theme.dart';
import '../../compoents/app_text_field.dart';
import '../../compoents/app_button.dart';
import '../../compoents/searchable_select.dart';
import '../../model/stock/stock_models.dart';
import '../../constants/permission_keys.dart';
import 'components/stock_card.dart';

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
      Provider.of<StockProvider>(context, listen: false).fetchEstimations();
    });
  }

  void _navigateToForm([EstimationData? estimation]) {
    showDialog(
      context: context,
      builder: (context) => EstimationFormDialog(estimation: estimation),
    ).then((_) => Provider.of<StockProvider>(context, listen: false).fetchEstimations());
  }

  @override
  Widget build(BuildContext context) {
    final acp = Provider.of<AccessControlProvider>(context);

    final String resource = PermissionKeys.estimation;
    final bool canRead = acp.canRead(resource);
    final bool canCreate = acp.canCreate(resource);
    final bool canUpdate = acp.canUpdate(resource);

    if (!canRead) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text("Access Denied", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("You don't have permission to view estimations.", style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Summary Cards
        Consumer<StockProvider>(
          builder: (context, provider, child) {
            final summary = provider.estimationSummary;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildSummaryCard('Purchases', 'PKR ${summary['totalPurchases'] ?? 0}', Icons.shopping_basket_outlined, Colors.blue),
                    _buildSummaryCard('Discount', 'PKR ${summary['totalDiscount'] ?? 0}', Icons.loyalty_outlined, Colors.orange),
                    _buildSummaryCard('Revenue', 'PKR ${summary['totalFinal'] ?? 0}', Icons.trending_up, AppTheme.primaryColor),
                    _buildSummaryCard('Profit', 'PKR ${summary['profit'] ?? 0}', Icons.monetization_on_outlined, Colors.green),
                  ],
                ),
              ),
            );
          },
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Search Estimation',
                  controller: _searchController,
                  prefixIcon: Icons.search,
                  onChanged: (v) {
                    Provider.of<StockProvider>(context, listen: false).fetchEstimations(search: v);
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
                    onPressed: () => _navigateToForm(),
                    icon: const Icon(Icons.add, color: Colors.white),
                    tooltip: 'New Estimation',
                  ),
                ),
              ],
            ],
          ),
        ),
        
        Expanded(
          child: Consumer<StockProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.estimations.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: provider.estimations.length,
                itemBuilder: (context, index) {
                  final item = provider.estimations[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: StockCard(
                      title: item.estimateId ?? 'No ID',
                      subtitle: '${item.customerName} | ${item.serviceName}',
                      icon: Icons.assignment_outlined,
                      trailing: 'Net: ${item.finalTotal}',
                      onTap: canUpdate ? () => _navigateToForm(item) : null,
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

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        ],
      ),
    );
  }
}

class EstimationFormDialog extends StatefulWidget {
  final EstimationData? estimation;
  const EstimationFormDialog({super.key, this.estimation});

  @override
  State<EstimationFormDialog> createState() => _EstimationFormDialogState();
}

class _EstimationFormDialogState extends State<EstimationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  String? selectedCustomer;
  String? selectedService;
  
  final TextEditingController _estimateIdController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(text: DateTime.now().toString().split(' ')[0]);
  
  // Item entry
  String? selectedItem;
  final TextEditingController _purPriceController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _discountController = TextEditingController(); // Percentage

  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    Provider.of<StockProvider>(context, listen: false).loadSetupOptions();
    if (widget.estimation != null) {
      _estimateIdController.text = widget.estimation!.estimateId ?? "";
      selectedCustomer = widget.estimation!.customerName;
      selectedService = widget.estimation!.serviceName;
    }
  }

  void _addItem() {
    if (selectedItem == null || _qtyController.text.isEmpty) return;
    
    double sale = double.tryParse(_salePriceController.text) ?? 0.0;
    double pur = double.tryParse(_purPriceController.text) ?? 0.0;
    int qty = int.tryParse(_qtyController.text) ?? 0;
    double discPer = double.tryParse(_discountController.text) ?? 0.0;
    
    double discAmt = (sale * discPer) / 100;
    double finalPrice = sale - discAmt;

    setState(() {
      items.add({
        'item': selectedItem,
        'purchasePrice': pur,
        'salePrice': sale,
        'qty': qty,
        'discountPercent': discPer,
        'finalPrice': finalPrice,
        'finalTotal': finalPrice * qty,
      });
      // Clear
      selectedItem = null;
      _purPriceController.clear();
      _salePriceController.clear();
      _qtyController.clear();
      _discountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);
    final acp = Provider.of<AccessControlProvider>(context);
    final canDelete = acp.canDelete(PermissionKeys.estimation);
    final canUpdate = acp.canUpdate(PermissionKeys.estimation);
    final canCreate = acp.canCreate(PermissionKeys.estimation);

    final bool isEdit = widget.estimation != null;
    final bool hasPermission = isEdit ? canUpdate : canCreate;
    
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Text(
                    widget.estimation == null ? 'New Estimation' : 'Edit Estimation',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
                ],
              ),
            ),
            
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PremiumCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            AppTextField(label: 'Estimate ID', controller: _estimateIdController),
                            const SizedBox(height: 12),
                            AppTextField(label: 'Date', controller: _dateController, prefixIcon: Icons.calendar_today),
                            const SizedBox(height: 12),
                            SearchableSelect(
                              label: 'Customer',
                              value: selectedCustomer,
                              options: provider.customers.map((c) => c.company ?? c.name ?? '').where((s) => s.isNotEmpty).toList(),
                              placeholder: 'Select customer',
                              searchHint: 'Search customer...',
                              onChanged: (v) => setState(() => selectedCustomer = v),
                            ),
                            const SizedBox(height: 12),
                            SearchableSelect(
                              label: 'Service / Product',
                              value: selectedService,
                              options: provider.services.map((s) => s.serviceName ?? '').where((e) => e.isNotEmpty).toList(),
                              placeholder: 'Select service',
                              searchHint: 'Search service...',
                              onChanged: (v) => setState(() => selectedService = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      PremiumCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SearchableSelect(
                              label: 'Item',
                              value: selectedItem,
                              options: provider.itemRates.map((e) => e.item ?? "").where((s) => s.isNotEmpty).toList(),
                              placeholder: 'Select item',
                              searchHint: 'Search item...',
                              onChanged: (v) {
                                final rate = provider.itemRates.firstWhere((r) => r.item == v, orElse: () => ItemRateData());
                                setState(() {
                                  selectedItem = v;
                                  if (rate.sale != null) _salePriceController.text = rate.sale!;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: AppTextField(label: 'Pur. Price', controller: _purPriceController, keyboardType: TextInputType.number)),
                                const SizedBox(width: 8),
                                Expanded(child: AppTextField(label: 'Sale Price', controller: _salePriceController, keyboardType: TextInputType.number)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: AppTextField(label: 'Qty', controller: _qtyController, keyboardType: TextInputType.number)),
                                const SizedBox(width: 8),
                                Expanded(child: AppTextField(label: 'Discount %', controller: _discountController, keyboardType: TextInputType.number)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            AppButton(text: 'Add Item', onPressed: _addItem),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Estimation Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      ...items.map((item) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(item['item']),
                          subtitle: Text('Qty: ${item['qty']} | Sale: ${item['salePrice']} | Disc: ${item['discountPercent']}%'),
                          trailing: Text('Net: ${item['finalTotal']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          leading: IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () => setState(() => items.remove(item)),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),
            
            // Footer
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (isEdit && canDelete)
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: const Text('Are you sure you want to delete this estimation?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () async {
                                  final success = await provider.deleteEstimation(widget.estimation!.id!);
                                  if (mounted) {
                                    Navigator.pop(context); // Close confirm
                                    if (success) Navigator.pop(context); // Close form
                                  }
                                },
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  const Spacer(),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  AppButton(
                    text: !hasPermission ? 'No Permission' : 'Save Estimation',
                    onPressed: hasPermission ? () async {
                      if (_formKey.currentState!.validate() && items.isNotEmpty) {
                        final data = {
                          'estimate_date': _dateController.text,
                          'items': items,
                        };
                        final success = await provider.saveEstimation(data: data, id: widget.estimation?.id);
                        if (success && mounted) {
                          Navigator.pop(context);
                        }
                      }
                    } : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
