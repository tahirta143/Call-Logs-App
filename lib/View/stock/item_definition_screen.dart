import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../Provider/stock/StockProvider.dart';
import '../../../Provider/auth/access_control_provider.dart';
import '../../../compoents/app_theme.dart';
import '../../../compoents/responsive_helper.dart';
import '../../../model/stock/item_model.dart';
import '../../../constants/api_config.dart';
import '../../compoents/app_button.dart';
import '../../compoents/app_text_field.dart';
import '../../../constants/permission_keys.dart';
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

    final String resource = PermissionKeys.itemDefinition;
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
                const Text("You don't have permission to view items.", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    final provider = Provider.of<StockProvider>(context);

    return Column(
      children: [
        // Search Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _searchController,
                  label: 'Search items...',
                  prefixIcon: Iconsax.search_normal,
                  onChanged: (v) => provider.fetchItems(search: v),
                ),
              ),
              if (canCreate) ...[
                const SizedBox(width: 12),
                _buildAddButton(),
              ],
            ],
          ),
        ),
        
        // List
        Expanded(
          child: provider.isLoading && provider.items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : AnimationLimiter(
                  child: RefreshIndicator(
                    onRefresh: () => provider.fetchItems(search: _searchController.text),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: provider.items.length,
                      itemBuilder: (context, index) {
                        final item = provider.items[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: StockCard(
                                  title: item.itemName ?? 'N/A',
                                  subtitle: "Type: ${item.itemType ?? 'N/A'} | Cat: ${item.category ?? 'N/A'}",
                                  trailing: item.salePrice != null ? "Rs ${item.salePrice}" : null,
                                  icon: Iconsax.box,
                                  imageUrl: ApiConfig.getImageUrl(item.imageName),
                                  onTap: canUpdate ? () => _openItemDialog(item) : null,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
        onPressed: () => _openItemDialog(null),
        icon: const Icon(Iconsax.add, color: Colors.white),
        tooltip: 'Add Item',
      ),
    );
  }

  void _openItemDialog(ItemData? item) {
    AppTheme.showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      child: _ItemFormDialog(item: item),
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
  bool _isSaving = false;

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
        final provider = Provider.of<StockProvider>(context, listen: false);
        provider.clearItemImage();
        
        // Auto-generate code and barcode for new items
        final nextCode = _generateNextCode(provider.items);
        codeController.text = nextCode;
        primaryBarcodeController.text = _buildPrimaryBarcode(nextCode);
      });
    }
  }

  String _generateNextCode(List<ItemData> items) {
    int maxNum = 0;
    for (var item in items) {
      final code = item.code ?? '';
      final numericStr = code.replaceAll(RegExp(r'\D'), '');
      if (numericStr.isNotEmpty) {
        final num = int.tryParse(numericStr) ?? 0;
        if (num > maxNum) maxNum = num;
      }
    }
    return 'item-${(maxNum + 1).toString().padLeft(4, '0')}';
  }

  String _buildPrimaryBarcode(String itemCode) {
    final seed = (1000 + (DateTime.now().millisecond % 9000)).toString();
    final numericPart = itemCode.replaceAll(RegExp(r'[^\d]'), '');
    return '$seed$numericPart';
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
    final acp = Provider.of<AccessControlProvider>(context);
    final canDelete = acp.canDelete(PermissionKeys.itemDefinition);
    final canUpdate = acp.canUpdate(PermissionKeys.itemDefinition);
    final canCreate = acp.canCreate(PermissionKeys.itemDefinition);
    
    final bool isEdit = widget.item != null;
    final bool hasPermission = isEdit ? canUpdate : canCreate;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter subcategories based on selected category
    List<Map<String, String>> filteredSubCats = provider.subCategories
        .where((s) => selectedCategory == null || s['categoryName'] == selectedCategory || s['categoryId'] == selectedCategory)
        .toList();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 800),
        child: Container(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
                  border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.item == null ? Iconsax.add_square : Iconsax.edit, color: AppTheme.primaryColor, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.item == null ? 'Define New Item' : 'Edit Item', 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          Text(widget.item == null ? 'Enter details to create a new stock item' : 'Update the existing item information',
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.grey[600])),
                        ],
                      ),
                    ),
                    if (isEdit && canDelete)
                      IconButton(
                        onPressed: _isSaving ? null : () => _handleDelete(provider),
                        icon: const Icon(Iconsax.trash, color: Colors.red, size: 20),
                        tooltip: 'Delete Item',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                          padding: const EdgeInsets.all(10),
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Image Picker
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3), width: 2)),
                            child: ClipOval(
                              child: provider.selectedItemImage != null
                                  ? Image.file(provider.selectedItemImage!, fit: BoxFit.cover)
                                  : (widget.item?.imageName != null
                                      ? Image.network(ApiConfig.getImageUrl(widget.item!.imageName), fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Iconsax.image, size: 40, color: Colors.grey))
                                      : const Icon(Iconsax.image, size: 40, color: Colors.grey)),
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: GestureDetector(
                              onTap: provider.pickItemImage,
                              child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle), child: const Icon(Iconsax.camera, color: Colors.white, size: 16)),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSection('Basic Information'),
                    Row(
                      children: [
                        Expanded(child: AppTextField(controller: codeController, label: 'Code', prefixIcon: Iconsax.code, readOnly: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('Type', provider.itemTypes, selectedType, (v) => setState(() => selectedType = v), isRequired: true)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(controller: nameController, label: 'Item Name', prefixIcon: Iconsax.box, isRequired: true, validator: (v) => v!.isEmpty ? 'Required' : null),
                    
                    const SizedBox(height: 24),
                    _buildSection('Classification'),
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('Category', provider.categories, selectedCategory, (v) {
                          setState(() { selectedCategory = v; selectedSubCategory = null; });
                        }, isRequired: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('Sub Category', filteredSubCats, selectedSubCategory, (v) => setState(() => selectedSubCategory = v))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(flex: 2, child: _buildDropdown('Unit', provider.units, selectedUnit, (v) {
                          setState(() {
                            selectedUnit = v;
                            if (v != null && (unitQtyController.text.isEmpty || unitQtyController.text == '0')) {
                              unitQtyController.text = '1';
                            }
                          });
                        }, isRequired: true)),
                        const SizedBox(width: 12),
                        Expanded(child: AppTextField(controller: unitQtyController, label: 'Unit Qty', prefixIcon: Iconsax.weight_1, keyboardType: TextInputType.number)),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _buildSection('Inventory & Pricing'),
                    Row(
                      children: [
                        Expanded(child: AppTextField(
                          controller: purchasePriceController, 
                          label: 'Purchase Price', 
                          prefixIcon: Iconsax.money_recive, 
                          keyboardType: TextInputType.number,
                          onChanged: (v) => setState(() {}),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: AppTextField(
                          controller: salePriceController, 
                          label: 'Sale Price', 
                          prefixIcon: Iconsax.money_send, 
                          keyboardType: TextInputType.number,
                          onChanged: (v) => setState(() {}),
                          validator: (v) {
                            if (v != null && v.isNotEmpty && purchasePriceController.text.isNotEmpty) {
                              final p = double.tryParse(purchasePriceController.text) ?? 0;
                              final s = double.tryParse(v) ?? 0;
                              if (s <= p) return 'Must be > Purchase';
                            }
                            return null;
                          },
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: AppTextField(controller: minLevelQtyController, label: 'Reorder Level', prefixIcon: Iconsax.arrow_down, keyboardType: TextInputType.number, isRequired: true, validator: (v) => v!.isEmpty ? 'Required' : null)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('Location', provider.locations, selectedLocation, (v) => setState(() => selectedLocation = v))),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _buildSection('Barcodes'),
                    AppTextField(controller: primaryBarcodeController, label: 'Primary Barcode', prefixIcon: Iconsax.barcode),
                    const SizedBox(height: 16),
                    AppTextField(controller: secondaryBarcodeController, label: 'Secondary Barcode', prefixIcon: Iconsax.barcode),

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
                        Expanded(child: AppTextField(controller: expiryDaysController, label: 'Expiry Days', prefixIcon: Iconsax.timer_1, keyboardType: TextInputType.number, isRequired: true, validator: (v) => expirable == 'yes' && (v == null || v.isEmpty) ? 'Required' : null)),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: hasPermission && !_isSaving ? () async {
                        if (!_formKey.currentState!.validate()) return;

                        setState(() => _isSaving = true);
                        String? findId(List<Map<String, String>> list, String? name) {
                          if (name == null || name.isEmpty) return '';
                          try {
                            return list.firstWhere((e) => e['name'] == name)['id'];
                          } catch (_) {
                            return '';
                          }
                        }

                        final success = await provider.saveItem(
                          id: widget.item?.id,
                          data: {
                            'item_code': codeController.text,
                            'item_name': nameController.text.trim(),
                            'item_type_id': findId(provider.itemTypes, selectedType) ?? '',
                            'category_id': findId(provider.categories, selectedCategory) ?? '',
                            'sub_category_id': findId(provider.subCategories, selectedSubCategory) ?? '',
                            'manufacturer_id': findId(provider.manufacturers, selectedManufacturer) ?? '',
                            'supplier_id': findId(provider.suppliers, selectedSupplier) ?? '',
                            'unit_id': findId(provider.units, selectedUnit) ?? '',
                            'unit_qty': unitQtyController.text,
                            'reorder_level': minLevelQtyController.text,
                            'location_id': findId(provider.locations, selectedLocation) ?? '',
                            'item_specification': specController.text.trim(),
                            'purchase_price': purchasePriceController.text,
                            'sale_price': salePriceController.text,
                            'primary_barcode': primaryBarcodeController.text,
                            'secondary_barcode': secondaryBarcodeController.text,
                            'is_expirable': expirable == 'yes' ? '1' : '0',
                            'expiry_days': expiryDaysController.text,
                            'is_cost_item': costItem == 'yes' ? '1' : '0',
                            'stop_sale': stopSale == 'yes' ? '1' : '0',
                            'status': status,
                          },
                        );
                        setState(() => _isSaving = false);
                        if (success && mounted) Navigator.pop(context);
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: _isSaving 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(isEdit ? 'Update Item' : 'Save Item', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }

  Future<void> _handleDelete(StockProvider provider) async {
    final confirmed = await AppTheme.showAnimatedDialog<bool>(
      context: context,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${widget.item!.itemName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isSaving = true);
      final success = await provider.deleteItem(widget.item!.id!);
      setState(() => _isSaving = false);
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
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

  Widget _buildDropdown(String label, List<Map<String, String>> options, String? value, Function(String?) onChanged, {bool isRequired = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<String> names = options.map((e) => e['name']!).toList();
    return DropdownButtonFormField<String>(
      value: names.contains(value) ? value : null,
      dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      decoration: InputDecoration(
        label: isRequired 
            ? RichText(
                text: TextSpan(
                  text: label,
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14),
                  children: const [
                    TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            : Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true,
        fillColor: isDark ? Colors.black26 : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor)),
      ),
      icon: const Icon(Iconsax.arrow_down_1, size: 16),
      items: names.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black87), overflow: TextOverflow.ellipsis))).toList(),
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
            Radio<String>(value: 'yes', groupValue: value, onChanged: (v) => onChanged(v!), activeColor: AppTheme.primaryColor, visualDensity: VisualDensity.compact),
            const Text('Yes', style: TextStyle(fontSize: 12)),
            Radio<String>(value: 'no', groupValue: value, onChanged: (v) => onChanged(v!), activeColor: AppTheme.primaryColor, visualDensity: VisualDensity.compact),
            const Text('No', style: TextStyle(fontSize: 12)),
          ],
        )
      ],
    );
  }
}
