import 'package:flutter/material.dart';
import 'package:infinity/Provider/auth/access_control_provider.dart';
import 'package:provider/provider.dart';
import '../../Provider/stock/StockProvider.dart';
import '../../compoents/premium_card.dart';
import '../../compoents/app_theme.dart';
import '../../compoents/app_text_field.dart';
import '../../compoents/app_button.dart';
import '../../model/stock/stock_models.dart';
import '../../constants/permission_keys.dart';
import 'components/stock_card.dart';

class ItemRateScreen extends StatefulWidget {
  const ItemRateScreen({super.key});

  @override
  State<ItemRateScreen> createState() => _ItemRateScreenState();
}

class _ItemRateScreenState extends State<ItemRateScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StockProvider>(context, listen: false).fetchItemRates();
      Provider.of<StockProvider>(context, listen: false).fetchUsdRate();
      Provider.of<StockProvider>(context, listen: false).loadSetupOptions();
    });
  }

  void _showForm([ItemRateData? itemRate]) {
    showDialog(
      context: context,
      builder: (context) => ItemRateFormDialog(itemRate: itemRate),
    ).then((_) => Provider.of<StockProvider>(context, listen: false).fetchItemRates());
  }

  @override
  Widget build(BuildContext context) {
    final acp = Provider.of<AccessControlProvider>(context);

    final String resource = PermissionKeys.itemRate;
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
            Text("You don't have permission to view item rates.", style: TextStyle(color: Colors.grey.shade600)),
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
                  label: 'Search Item',
                  controller: _searchController,
                  prefixIcon: Icons.search,
                  onChanged: (v) {
                    Provider.of<StockProvider>(context, listen: false).fetchItemRates(search: v);
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
                    onPressed: () => _showForm(),
                    icon: const Icon(Icons.add, color: Colors.white),
                    tooltip: 'Add Item Rate',
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: Consumer<StockProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.itemRates.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: provider.itemRates.length,
                itemBuilder: (context, index) {
                  final item = provider.itemRates[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: StockCard(
                      title: item.item ?? 'Unnamed',
                      subtitle: 'Reseller: ${item.reseller} | Sale: ${item.sale}',
                      icon: Icons.price_change,
                      trailing: item.category,
                      onTap: canUpdate ? () => _showForm(item) : null,
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

class ItemRateFormDialog extends StatefulWidget {
  final ItemRateData? itemRate;
  const ItemRateFormDialog({super.key, this.itemRate});

  @override
  State<ItemRateFormDialog> createState() => _ItemRateFormDialogState();
}

class _ItemRateFormDialogState extends State<ItemRateFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  String? selectedItem;
  String? selectedSupplier;
  String? selectedLocation;
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedUnit;

  final TextEditingController _usdPriceController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _iTaxController = TextEditingController();
  final TextEditingController _profitController = TextEditingController();
  final TextEditingController _pkrBaseController = TextEditingController();
  final TextEditingController _resellerPriceController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<StockProvider>(context, listen: false);
    _rateController.text = provider.usdToPkrRate.toString();
    _iTaxController.text = "0";
    _profitController.text = "0";

    if (widget.itemRate != null) {
      final raw = widget.itemRate!.raw ?? {};
      selectedItem = widget.itemRate!.item;
      selectedSupplier = raw['supplier'];
      selectedCategory = widget.itemRate!.category;
      selectedSubCategory = widget.itemRate!.subCategory;
      _usdPriceController.text = raw['purchasePriceUsd']?.toString() ?? "";
      _rateController.text = raw['usdRate']?.toString() ?? provider.usdToPkrRate.toString();
      _iTaxController.text = raw['iTaxPercentage']?.toString() ?? "0";
      _profitController.text = raw['profitPercentage']?.toString() ?? "0";
      _resellerPriceController.text = widget.itemRate!.reseller ?? "";
      _salePriceController.text = widget.itemRate!.sale ?? "";
      _calculate();
    }
  }

  void _calculate() {
    double usd = double.tryParse(_usdPriceController.text) ?? 0;
    double rate = double.tryParse(_rateController.text) ?? 0;
    double itaxPer = double.tryParse(_iTaxController.text) ?? 0;
    double profitPer = double.tryParse(_profitController.text) ?? 0;

    double pkrBase = usd * rate;
    double itaxAmt = (pkrBase * itaxPer) / 100;
    double profitAmt = (pkrBase * profitPer) / 100;
    double reseller = pkrBase + itaxAmt + profitAmt;

    setState(() {
      _pkrBaseController.text = pkrBase.toStringAsFixed(2);
      _resellerPriceController.text = reseller.toStringAsFixed(2);
      // Sale defaults to Reseller if not manually set, or we can leave it for custom input
      if (_salePriceController.text.isEmpty) {
        _salePriceController.text = reseller.toStringAsFixed(2);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);
    final acp = Provider.of<AccessControlProvider>(context);
    final canDelete = acp.canDelete(PermissionKeys.itemRate);
    final canUpdate = acp.canUpdate(PermissionKeys.itemRate);
    final canCreate = acp.canCreate(PermissionKeys.itemRate);

    final bool isEdit = widget.itemRate != null;
    final bool hasPermission = isEdit ? canUpdate : canCreate;
    
    return AlertDialog(
      title: Text(widget.itemRate == null ? 'Add Item Rate' : 'Edit Item Rate'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDropdown('Item', selectedItem, provider.items.map((e) => e.name ?? "").toList(), (v) => setState(() => selectedItem = v)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDropdown('Category', selectedCategory, provider.categories, (v) => setState(() => selectedCategory = v))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDropdown(
                      'Sub Category',
                      selectedSubCategory,
                      provider.subCategories.map((s) => s['name'] as String).toList(),
                      (v) => setState(() => selectedSubCategory = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDropdown('Supplier', selectedSupplier, provider.manufacturers, (v) => setState(() => selectedSupplier = v)),
              const SizedBox(height: 20),
              const Text('Calculations', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Price (USD)',
                      controller: _usdPriceController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculate(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppTextField(
                      label: 'Rate (PKR)',
                      controller: _rateController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculate(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'ITax (%)',
                      controller: _iTaxController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculate(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppTextField(
                      label: 'Profit (%)',
                      controller: _profitController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculate(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Base (PKR)',
                controller: _pkrBaseController,
                readOnly: true,
                filled: true,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Reseller Price',
                controller: _resellerPriceController,
                readOnly: true,
                filled: true,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Final Sale Price',
                controller: _salePriceController,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (isEdit && canDelete)
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: Text('Are you sure you want to delete rate for "${widget.itemRate!.item}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        provider.deleteItemRate(widget.itemRate!.id!);
                        Navigator.pop(context); // Close confirm
                        Navigator.pop(context); // Close form
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        AppButton(
          text: !hasPermission ? 'No Permission' : 'Save',
          onPressed: hasPermission ? () async {
            if (_formKey.currentState!.validate()) {
              final data = {
                'item': selectedItem,
                'category': selectedCategory,
                'subCategory': selectedSubCategory,
                'supplier': selectedSupplier,
                'purchasePriceUsd': _usdPriceController.text,
                'usdRate': _rateController.text,
                'iTaxPercentage': _iTaxController.text,
                'profitPercentage': _profitController.text,
                'reseller': _resellerPriceController.text,
                'sale': _salePriceController.text,
              };
              final success = await provider.saveItemRate(data: data, id: widget.itemRate?.id);
              if (success && mounted) {
                Navigator.pop(context);
              }
            }
          } : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
