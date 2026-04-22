import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinity/Provider/auth/access_control_provider.dart';
import 'package:provider/provider.dart';
import '../../../Provider/stock/StockProvider.dart';

import '../../../compoents/app_theme.dart';
import '../../../model/stock/item_model.dart';
import '../../../constants/api_config.dart';
import '../../compoents/app_button.dart';
import '../../compoents/app_text_field.dart';
import '../../helpers/permission_helper.dart';
import 'components/stock_card.dart';

class ItemDefinitionScreen extends StatefulWidget {
  const ItemDefinitionScreen({super.key});

  @override
  State<ItemDefinitionScreen> createState() => _ItemDefinitionScreenState();
}

class _ItemDefinitionScreenState extends State<ItemDefinitionScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<StockProvider>(context, listen: false);
      provider.fetchItems();
      provider.loadSetupOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final acp = Provider.of<AccessControlProvider>(context);

    if (acp.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    const String resource = 'INVENTORY.ITEM_DEFINITION';
    final bool canRead = acp.canRead(resource);
    final bool canCreate = acp.canCreate(resource);
    final bool canUpdate = acp.canUpdate(resource);
    final bool canDelete = acp.canDelete(resource);

    if (!canRead) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.shield_cross, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text("Access Denied", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("You don't have permission to view items.", style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      );
    }

    final provider = Provider.of<StockProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          // Search Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppTextField(
              controller: _searchController,
              label: 'Search items...',
              icon: Iconsax.search_normal,
              onChanged: (v) => provider.fetchItems(search: v),
            ),
          ),
          
          // List
          Expanded(
            child: provider.isLoading && provider.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => provider.fetchItems(search: _searchController.text),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.items.length,
                      itemBuilder: (context, index) {
                        final item = provider.items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: StockCard(
                            title: item.itemName ?? 'N/A',
                            subtitle: "Type: ${item.itemType ?? 'N/A'} | Cat: ${item.category ?? 'N/A'}",
                            trailing: item.salePrice != null ? "Rs ${item.salePrice}" : null,
                            icon: Iconsax.box,
                            imageUrl: ApiConfig.getImageUrl(item.imageName),
                            onEdit: canUpdate ? () => _openItemDialog(item) : null,
                            onDelete: canDelete ? () => _confirmDelete(item) : null,
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: canCreate ? FloatingActionButton(
        onPressed: () => _openItemDialog(null),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }

  void _openItemDialog(ItemData? item) {
    showDialog(
      context: context,
      builder: (context) => _ItemFormDialog(item: item),
    );
  }

  void _confirmDelete(ItemData item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.itemName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Provider.of<StockProvider>(context, listen: false).deleteItem(item.id!);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ItemFormDialog extends StatefulWidget {
  final ItemData? item;
  const _ItemFormDialog({this.item});

  @override
  State<_ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<_ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController nameController;
  late TextEditingController codeController;
  late TextEditingController unitQtyController;
  late TextEditingController minLevelQtyController;
  late TextEditingController purchasePriceController;
  late TextEditingController salePriceController;
  late TextEditingController primaryBarcodeController;
  late TextEditingController secondaryBarcodeController;
  late TextEditingController specController;
  late TextEditingController expiryDaysController;

  String? selectedType;
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedManufacturer;
  String? selectedSupplier;
  String? selectedUnit;
  String? selectedLocation;
  String expirable = 'no';
  String costItem = 'no';
  String stopSale = 'no';
  String status = 'active';

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    nameController = TextEditingController(text: i?.itemName ?? '');
    codeController = TextEditingController(text: i?.code ?? '');
    unitQtyController = TextEditingController(text: i?.unitQty ?? '1');
    minLevelQtyController = TextEditingController(text: i?.minLevelQty ?? '0');
    purchasePriceController = TextEditingController(text: i?.purchasePrice ?? '');
    salePriceController = TextEditingController(text: i?.salePrice ?? '');
    primaryBarcodeController = TextEditingController(text: i?.primaryBarcode ?? '');
    secondaryBarcodeController = TextEditingController(text: i?.secondaryBarcode ?? '');
    specController = TextEditingController(text: i?.itemSpecification ?? '');
    expiryDaysController = TextEditingController(text: i?.expiryDays ?? '');

    selectedType = i?.itemType;
    selectedCategory = i?.category;
    selectedSubCategory = i?.subCategory;
    selectedManufacturer = i?.manufacturer;
    selectedSupplier = i?.supplier;
    selectedUnit = i?.unit;
    selectedLocation = i?.location;
    expirable = i?.expirable ?? 'no';
    costItem = i?.costItem ?? 'no';
    stopSale = i?.stopSale ?? 'no';
    status = i?.status ?? 'active';

    if (widget.item == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<StockProvider>(context, listen: false).clearItemImage();
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose(); codeController.dispose(); unitQtyController.dispose();
    minLevelQtyController.dispose(); purchasePriceController.dispose(); salePriceController.dispose();
    primaryBarcodeController.dispose(); secondaryBarcodeController.dispose();
    specController.dispose(); expiryDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);

    // Filter subcategories based on selected category
    List<String> filteredSubCats = provider.subCategories
        .where((s) => selectedCategory == null || s['categoryName'] == selectedCategory || s['categoryId'] == selectedCategory)
        .map((s) => s['name']!)
        .toList();

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Icon(widget.item == null ? Iconsax.add_square : Iconsax.edit, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(widget.item == null ? 'Define New Item' : 'Edit Item', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Image Picker
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.primaryColor, width: 2)),
                            child: ClipOval(
                              child: provider.selectedItemImage != null
                                  ? Image.file(provider.selectedItemImage!, fit: BoxFit.cover)
                                  : (widget.item?.imageName != null
                                      ? Image.network(ApiConfig.getImageUrl(widget.item!.imageName), fit: BoxFit.cover)
                                      : const Icon(Iconsax.image, size: 30, color: Colors.grey)),
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: GestureDetector(
                              onTap: provider.pickItemImage,
                              child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle), child: const Icon(Iconsax.camera, color: Colors.white, size: 14)),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSection('Basic Information'),
                    Row(
                      children: [
                        Expanded(child: AppTextField(controller: codeController, label: 'Code', icon: Iconsax.code, readOnly: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('Type', provider.itemTypes, selectedType, (v) => setState(() => selectedType = v))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(controller: nameController, label: 'Item Name', icon: Iconsax.box, validator: (v) => v!.isEmpty ? 'Required' : null),
                    
                    const SizedBox(height: 24),
                    _buildSection('Classification'),
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('Category', provider.categories, selectedCategory, (v) {
                          setState(() { selectedCategory = v; selectedSubCategory = null; });
                        })),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('Sub Category', filteredSubCats, selectedSubCategory, (v) => setState(() => selectedSubCategory = v))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(flex: 2, child: _buildDropdown('Unit', provider.units, selectedUnit, (v) => setState(() => selectedUnit = v))),
                        const SizedBox(width: 12),
                        Expanded(child: AppTextField(controller: unitQtyController, label: 'Unit Qty', icon: Iconsax.weight_1, keyboardType: TextInputType.number)),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _buildSection('Inventory & Pricing'),
                    Row(
                      children: [
                        Expanded(child: AppTextField(controller: purchasePriceController, label: 'Purchase Price', icon: Iconsax.money_recive, keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: AppTextField(controller: salePriceController, label: 'Sale Price', icon: Iconsax.money_send, keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: AppTextField(controller: minLevelQtyController, label: 'Min Level Qty', icon: Iconsax.arrow_down, keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('Location', provider.locations, selectedLocation, (v) => setState(() => selectedLocation = v))),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _buildSection('Barcodes'),
                    AppTextField(controller: primaryBarcodeController, label: 'Primary Barcode', icon: Iconsax.barcode),
                    const SizedBox(height: 16),
                    AppTextField(controller: secondaryBarcodeController, label: 'Secondary Barcode', icon: Iconsax.barcode),

                    const SizedBox(height: 24),
                    _buildSection('Manufacturer & Supplier'),
                    _buildDropdown('Manufacturer', provider.manufacturers, selectedManufacturer, (v) => setState(() => selectedManufacturer = v)),
                    const SizedBox(height: 16),
                    _buildDropdown('Supplier', provider.suppliers, selectedSupplier, (v) => setState(() => selectedSupplier = v)),

                    const SizedBox(height: 24),
                    _buildSection('Settings'),
                    Row(
                      children: [
                        Expanded(child: _buildRadio('Expirable', expirable, (v) => setState(() => expirable = v))),
                        if (expirable == 'yes')
                        Expanded(child: AppTextField(controller: expiryDaysController, label: 'Expiry Days', icon: Iconsax.timer_1, keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildRadio('Cost Item', costItem, (v) => setState(() => costItem = v))),
                        Expanded(child: _buildRadio('Stop Sale', stopSale, (v) => setState(() => stopSale = v))),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Cancel'))),
                Expanded(
                  child: AppButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      final success = await provider.saveItem(
                        id: widget.item?.id,
                        data: {
                          'code': codeController.text,
                          'itemName': nameController.text.trim(),
                          'itemType': selectedType ?? '',
                          'category': selectedCategory ?? '',
                          'subCategory': selectedSubCategory ?? '',
                          'manufacturer': selectedManufacturer ?? '',
                          'supplier': selectedSupplier ?? '',
                          'unit': selectedUnit ?? '',
                          'unitQty': unitQtyController.text,
                          'minLevelQty': minLevelQtyController.text,
                          'location': selectedLocation ?? '',
                          'itemSpecification': specController.text.trim(),
                          'purchasePrice': purchasePriceController.text,
                          'salePrice': salePriceController.text,
                          'primaryBarcode': primaryBarcodeController.text,
                          'secondaryBarcode': secondaryBarcodeController.text,
                          'expirable': expirable,
                          'expiryDays': expiryDaysController.text,
                          'costItem': costItem,
                          'stopSale': stopSale,
                          'status': status,
                        },
                      );
                      if (success) {
                        if (mounted) Navigator.pop(context);
                      }
                    },
                    title: provider.isLoading ? 'Saving...' : 'Save Item',
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor.withValues(alpha: 0.8))),
    );
  }

  Widget _buildDropdown(String label, List<String> options, String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      // ignore: deprecated_member_use
      initialValue: options.contains(value) ? value : null,
      decoration: InputDecoration(labelText: label),
      items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildRadio(String label, String value, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Row(
          children: [
            // ignore: deprecated_member_use
            Radio<String>(value: 'yes', groupValue: value, onChanged: (v) => onChanged(v!), activeColor: AppTheme.primaryColor, visualDensity: VisualDensity.compact),
            const Text('Yes', style: TextStyle(fontSize: 12)),
            // ignore: deprecated_member_use
            Radio<String>(value: 'no', groupValue: value, onChanged: (v) => onChanged(v!), activeColor: AppTheme.primaryColor, visualDensity: VisualDensity.compact),
            const Text('No', style: TextStyle(fontSize: 12)),
          ],
        )
      ],
    );
  }
}
