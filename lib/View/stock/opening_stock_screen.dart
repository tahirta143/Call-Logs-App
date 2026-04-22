import 'package:flutter/material.dart';
import 'package:infinity/Provider/auth/access_control_provider.dart';
import 'package:provider/provider.dart';
import '../../Provider/stock/StockProvider.dart';
import '../../compoents/premium_card.dart';
import '../../compoents/app_theme.dart';
import '../../compoents/app_text_field.dart';
import '../../helpers/permission_helper.dart';
import '../../compoents/app_button.dart';
import '../../constants/api_config.dart';
import '../../model/stock/stock_models.dart';

class OpeningStockScreen extends StatefulWidget {
  const OpeningStockScreen({super.key});

  @override
  State<OpeningStockScreen> createState() => _OpeningStockScreenState();
}

class _OpeningStockScreenState extends State<OpeningStockScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? selectedType;
  String? selectedCategory;
  String? selectedSubCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<StockProvider>(context, listen: false);
      provider.fetchOpeningStock();
      provider.loadSetupOptions();
    });
  }

  void _onFilter() {
    Provider.of<StockProvider>(context, listen: false).fetchOpeningStock(
      search: _searchController.text,
      type: selectedType,
      category: selectedCategory,
      subCategory: selectedSubCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    final acp = Provider.of<AccessControlProvider>(context);

    if (acp.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    const String resource = 'INVENTORY.OPENING_STOCK';
    final bool canRead = acp.canRead(resource);
    final bool canUpdate = acp.canUpdate(resource);

    if (!canRead) {
      return Scaffold(
        appBar: AppBar(title: const Text('Opening Stock')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("Access Denied", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("You don't have permission to view opening stock.", style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opening Stock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onFilter,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PremiumCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AppTextField(
                    label: 'Search Item',
                    controller: _searchController,
                    prefixIcon: Icons.search,
                    onChanged: (v) => _onFilter(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          'Type',
                          selectedType,
                          Provider.of<StockProvider>(context).itemTypes,
                          (v) {
                            setState(() => selectedType = v);
                            _onFilter();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          'Category',
                          selectedCategory,
                          Provider.of<StockProvider>(context).categories,
                          (v) {
                            setState(() => selectedCategory = v);
                            _onFilter();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // List
          Expanded(
            child: Consumer<StockProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.openingStock.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.openingStock.isEmpty) {
                  return const Center(child: Text('No items found.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.openingStock.length,
                  itemBuilder: (context, index) {
                    final item = provider.openingStock[index];
                    return OpeningStockCard(item: item, canUpdate: canUpdate);
                  },
                );
              },
            ),
          ),
        ],
      ),
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
              hint: const Text('All'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ...options.map((e) => DropdownMenuItem(value: e, child: Text(e))),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class OpeningStockCard extends StatefulWidget {
  final OpeningStockData item;
  final bool canUpdate;
  const OpeningStockCard({super.key, required this.item, this.canUpdate = true});

  @override
  State<OpeningStockCard> createState() => _OpeningStockCardState();
}

class _OpeningStockCardState extends State<OpeningStockCard> {
  late TextEditingController _purchaseController;
  late TextEditingController _saleController;
  late TextEditingController _stockController;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _purchaseController = TextEditingController(text: widget.item.purchasePrice ?? '');
    _saleController = TextEditingController(text: widget.item.salePrice ?? '');
    _stockController = TextEditingController(text: widget.item.stock ?? '');
  }

  Future<void> _handleSave() async {
    setState(() => isSaving = true);
    final provider = Provider.of<StockProvider>(context, listen: false);
    final success = await provider.updateOpeningStock(widget.item.id!, {
      'purchase_price': _purchaseController.text,
      'sale_price': _saleController.text,
      'unit_qty': _stockController.text,
    });
    setState(() => isSaving = false);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Stock updated successfully'),
            backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: widget.item.imageName != null
                    ? Image.network(ApiConfig.getImageUrl(widget.item.imageName!), errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2))
                    : const Icon(Icons.inventory_2, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.itemName ?? 'Unnamed Item', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${widget.item.category} > ${widget.item.subCategory}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              if (widget.canUpdate) 
                isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : IconButton(
                        icon: const Icon(Icons.save, color: AppTheme.primaryColor),
                        onPressed: _handleSave,
                      ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Pur. Price',
                  controller: _purchaseController,
                  keyboardType: TextInputType.number,
                  readOnly: !widget.canUpdate,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppTextField(
                  label: 'Sale Price',
                  controller: _saleController,
                  keyboardType: TextInputType.number,
                  readOnly: !widget.canUpdate,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppTextField(
                  label: 'Stock',
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  readOnly: !widget.canUpdate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
