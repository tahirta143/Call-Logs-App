import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../Provider/stock/StockProvider.dart';
import '../../Provider/auth/access_control_provider.dart';
import '../../compoents/premium_card.dart';
import '../../compoents/app_theme.dart';
import '../../compoents/app_text_field.dart';
import '../../compoents/app_button.dart';
import '../../compoents/responsive_helper.dart';
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
      final sp = Provider.of<StockProvider>(context, listen: false);
      sp.fetchItemRates();
      sp.fetchItems();
      sp.fetchUsdRate();
      sp.loadSetupOptions();
    });
  }

  void _showForm([ItemRateData? itemRate]) {
    AppTheme.showAnimatedDialog(
      context: context,
      child: ItemRateFormDialog(itemRate: itemRate),
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
        child: AnimationConfiguration.synchronized(
          child: FadeInAnimation(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.shield_cross, size: 80, color: Colors.red.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                const Text("Access Denied", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("You don't have permission to view item rates.", style: TextStyle(color: Colors.grey)),
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
                  label: 'Search Item',
                  controller: _searchController,
                  prefixIcon: Iconsax.search_normal,
                  onChanged: (v) {
                    Provider.of<StockProvider>(context, listen: false).fetchItemRates(search: v);
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
            builder: (context, provider, child) {
              if (provider.isLoading && provider.itemRates.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.itemRates.isEmpty) {
                return _buildEmptyState();
              }
              return AnimationLimiter(
                child: RefreshIndicator(
                  onRefresh: () => provider.fetchItemRates(search: _searchController.text),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: provider.itemRates.length,
                    itemBuilder: (context, index) {
                      final item = provider.itemRates[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: StockCard(
                                title: item.item ?? 'Unnamed',
                                subtitle: 'Reseller: ${item.reseller} | Sale: ${item.sale}',
                                icon: Iconsax.money_3,
                                trailing: item.category,
                                status: 'Active',
                                onTap: canUpdate ? () => _showForm(item) : null,
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
        onPressed: () => _showForm(),
        icon: const Icon(Iconsax.add, color: Colors.white),
        tooltip: 'Add Item Rate',
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
          const Text("No Item Rates Found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text("Start by adding your first item rate.", style: TextStyle(color: Colors.grey)),
        ],
      ),
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
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedManufacturer;
  
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _quotationIdController = TextEditingController();
  final TextEditingController _specController = TextEditingController();
  final TextEditingController _usdPriceController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _pkrPriceController = TextEditingController();
  
  // Taxes
  bool iTaxChecked = false;
  final TextEditingController _iTaxPercentController = TextEditingController();
  final TextEditingController _iTaxAmountController = TextEditingController();
  
  bool othersChecked = false;
  final TextEditingController _othersPercentController = TextEditingController();
  final TextEditingController _othersAmountController = TextEditingController();
  
  bool profitChecked = false;
  final TextEditingController _profitPercentController = TextEditingController();
  final TextEditingController _profitAmountController = TextEditingController();
  
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _salesTaxController = TextEditingController();
  final TextEditingController _totalPriceController = TextEditingController();

  String lastEditedField = 'pkr';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<StockProvider>(context, listen: false);
    _dateController.text = DateTime.now().toString().split(' ')[0];
    _rateController.text = provider.usdToPkrRate.toString();
    
    if (widget.itemRate != null) {
      final raw = widget.itemRate!.raw ?? {};
      selectedItem = widget.itemRate!.item;
      selectedSupplier = raw['supplier'] ?? widget.itemRate!.supplier;
      selectedCategory = widget.itemRate!.category;
      selectedSubCategory = widget.itemRate!.subCategory;
      selectedManufacturer = raw['manufacturer'] ?? widget.itemRate!.manufacturer;
      
      _dateController.text = (raw['rate_date'] ?? raw['rateDate'] ?? '').split('T')[0];
      _quotationIdController.text = raw['quotation_id']?.toString() ?? '';
      _specController.text = raw['item_specification']?.toString() ?? '';
      _usdPriceController.text = raw['reseller_price_usd']?.toString() ?? '';
      _rateController.text = raw['exchange_rate']?.toString() ?? provider.usdToPkrRate.toString();
      _pkrPriceController.text = raw['reseller_price']?.toString() ?? widget.itemRate!.reseller ?? '';
      
      iTaxChecked = (double.tryParse(raw['i_tax_percent']?.toString() ?? '0') ?? 0) > 0;
      _iTaxPercentController.text = raw['i_tax_percent']?.toString() ?? '';
      
      othersChecked = (double.tryParse(raw['other_tax_percent']?.toString() ?? '0') ?? 0) > 0;
      _othersPercentController.text = raw['other_tax_percent']?.toString() ?? '';
      
      profitChecked = (double.tryParse(raw['profit_percent']?.toString() ?? '0') ?? 0) > 0;
      _profitPercentController.text = raw['profit_percent']?.toString() ?? '';
      
      lastEditedField = _usdPriceController.text.isNotEmpty ? 'usd' : 'pkr';
      _calculate();
    }
  }

  Future<void> _onItemChanged(String? name) async {
    if (name == null) return;
    setState(() => selectedItem = name);
    
    final provider = Provider.of<StockProvider>(context, listen: false);
    final item = provider.items.firstWhere((e) => e.name == name);
    if (item.id == null) return;
    
    final details = await provider.fetchItemDetails(item.id!);
    if (details != null) {
      setState(() {
        selectedCategory = details['categoryName'] ?? details['category_name'];
        selectedSubCategory = details['subCategoryName'] ?? details['sub_category_name'];
        selectedManufacturer = details['manufacturerName'] ?? details['manufacturer_name'];
        _specController.text = details['specification'] ?? details['item_specification'] ?? '';
        
        // Pre-fill reseller price from item purchase price if empty
        if (_pkrPriceController.text.isEmpty && details['purchasePrice'] != null) {
          _pkrPriceController.text = details['purchasePrice'].toString();
          lastEditedField = 'pkr';
          _calculate();
        }
      });
      _fetchQuotationId();
    }
  }

  Future<void> _fetchQuotationId() async {
    if (selectedItem == null || selectedSupplier == null) return;
    final provider = Provider.of<StockProvider>(context, listen: false);
    
    final itemId = provider.items.firstWhere((e) => e.name == selectedItem).id;
    final supplierId = provider.suppliers.firstWhere((e) => e['name'] == selectedSupplier)['id'];
    
    if (itemId != null && supplierId != null) {
      final qId = await provider.fetchQuotationId(supplierId, itemId);
      if (qId != null) {
        setState(() => _quotationIdController.text = qId);
      }
    }
  }

  void _calculate() {
    double usd = double.tryParse(_usdPriceController.text) ?? 0;
    double rate = double.tryParse(_rateController.text) ?? 0;
    double pkr = double.tryParse(_pkrPriceController.text) ?? 0;

    // Sync prices
    if (lastEditedField == 'usd' && rate > 0) {
      pkr = usd * rate;
      _pkrPriceController.text = pkr.toStringAsFixed(2);
    } else if (lastEditedField == 'pkr' && rate > 0) {
      usd = pkr / rate;
      _usdPriceController.text = usd.toStringAsFixed(2);
    }

    double basePrice = pkr;
    
    double iTaxPer = iTaxChecked ? (double.tryParse(_iTaxPercentController.text) ?? 0) : 0;
    double iTaxAmt = (basePrice * iTaxPer) / 100;
    _iTaxAmountController.text = iTaxAmt.toStringAsFixed(2);
    
    double otherPer = othersChecked ? (double.tryParse(_othersPercentController.text) ?? 0) : 0;
    double otherAmt = (basePrice * otherPer) / 100;
    _othersAmountController.text = otherAmt.toStringAsFixed(2);
    
    double profitPer = profitChecked ? (double.tryParse(_profitPercentController.text) ?? 0) : 0;
    double profitAmt = (basePrice * profitPer) / 100;
    _profitAmountController.text = profitAmt.toStringAsFixed(2);
    
    double salePrice = basePrice + iTaxAmt + otherAmt + profitAmt;
    _salePriceController.text = salePrice.toStringAsFixed(2);
    
    double salesTax = (salePrice * 18) / 100;
    _salesTaxController.text = salesTax.toStringAsFixed(2);
    
    double totalPrice = salePrice + salesTax;
    _totalPriceController.text = totalPrice.toStringAsFixed(2);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Iconsax.receipt_text, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(isEdit ? 'Edit Item Rate' : 'Add Item Rate', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                    _buildSection('Rate Setup'),
                    Row(
                      children: [
                        Expanded(child: AppTextField(
                          controller: _dateController, 
                          label: 'Date', 
                          prefixIcon: Iconsax.calendar, 
                          isRequired: true,
                          readOnly: true,
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null) {
                              setState(() => _dateController.text = picked.toString().split(' ')[0]);
                            }
                          },
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('Item', provider.items.map((e) => e.name ?? "").toList(), selectedItem, (v) => _onItemChanged(v), isRequired: true)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: AppTextField(controller: TextEditingController(text: selectedCategory), label: 'Category', prefixIcon: Iconsax.category, readOnly: true, filled: true)),
                        const SizedBox(width: 12),
                        Expanded(child: AppTextField(controller: TextEditingController(text: selectedSubCategory), label: 'Sub Category', prefixIcon: Iconsax.menu, readOnly: true, filled: true)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppTextField(controller: TextEditingController(text: selectedManufacturer), label: 'Manufacturer', prefixIcon: Iconsax.building, readOnly: true, filled: true),
                    const SizedBox(height: 12),
                    AppTextField(controller: _specController, label: 'Item Specification', prefixIcon: Iconsax.note, maxLines: 3, readOnly: true, filled: true),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('Supplier', provider.suppliers.map((e) => e['name']!).toList(), selectedSupplier, (v) {
                          setState(() => selectedSupplier = v);
                          _fetchQuotationId();
                        }, isRequired: true)),
                        const SizedBox(width: 12),
                        Expanded(child: AppTextField(controller: _quotationIdController, label: 'Quotation ID', prefixIcon: Iconsax.ticket)),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    _buildSection('Pricing'),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final bool isMobile = constraints.maxWidth < 450;
                        return isMobile 
                          ? Column(
                              children: [
                                _buildPricingFields(provider),
                                const SizedBox(height: 24),
                                _buildTaxSection(),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: _buildPricingFields(provider)),
                                const SizedBox(width: 24),
                                Expanded(flex: 2, child: _buildTaxSection()),
                              ],
                            );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                if (isEdit && canDelete)
                  IconButton(
                    onPressed: _isSaving ? null : () => _handleDelete(provider),
                    icon: const Icon(Iconsax.trash, color: Colors.red),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: hasPermission && !_isSaving ? () async {
                    if (!_formKey.currentState!.validate()) return;
                    
                    setState(() => _isSaving = true);
                    num n(String s) => num.tryParse(s) ?? 0;
                    
                    String? findId(List<Map<String, String>> list, String? name) {
                      if (name == null || name.isEmpty) return null;
                      try { return list.firstWhere((e) => e['name'] == name)['id']; } catch (_) { return null; }
                    }
                    
                    final itemId = provider.items.firstWhere((e) => e.name == selectedItem).id;
                    
                    final Map<String, dynamic> data = {
                      'rate_date': _dateController.text,
                      'supplier_id': findId(provider.suppliers, selectedSupplier),
                      'quotation_id': _quotationIdController.text.trim(),
                      'category_id': findId(provider.categories, selectedCategory),
                      'sub_category_id': findId(provider.subCategories, selectedSubCategory) ?? '',
                      'manufacturer_id': findId(provider.manufacturers, selectedManufacturer) ?? '',
                      'item_definition_id': itemId,
                      'item_specification': _specController.text.trim(),
                      'currency': _usdPriceController.text.isNotEmpty ? 'USD' : 'PKR',
                      'reseller_price_usd': _usdPriceController.text.isNotEmpty ? n(_usdPriceController.text) : null,
                      'exchange_rate': n(_rateController.text),
                      'reseller_price': n(_pkrPriceController.text),
                      'sale_price': n(_salePriceController.text),
                      'sales_tax_percent': 18,
                      'sales_tax_amount': n(_salesTaxController.text),
                      'i_tax_percent': iTaxChecked ? n(_iTaxPercentController.text) : 0,
                      'i_tax_amount': iTaxChecked ? n(_iTaxAmountController.text) : 0,
                      'other_tax_percent': othersChecked ? n(_othersPercentController.text) : 0,
                      'other_tax_amount': othersChecked ? n(_othersAmountController.text) : 0,
                      'profit_percent': profitChecked ? n(_profitPercentController.text) : 0,
                      'profit_amount': profitChecked ? n(_profitAmountController.text) : 0,
                      'status': 'active',
                    };
                    
                    data.removeWhere((key, value) => value == null || value == '');
                    
                    final success = await provider.saveItemRate(data: data, id: widget.itemRate?.id);
                    setState(() => _isSaving = false);
                    if (success && mounted) Navigator.pop(context);
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(160, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(isEdit ? 'Update Rate' : 'Save Rate'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete(StockProvider provider) async {
    final confirmed = await AppTheme.showAnimatedDialog<bool>(
      context: context,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Rate'),
        content: const Text('Are you sure you want to delete this item rate?'),
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
      final success = await provider.deleteItemRate(widget.itemRate!.id!);
      setState(() => _isSaving = false);
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildPricingFields(StockProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: AppTextField(
              controller: _usdPriceController, 
              label: 'Reseller Price US\$', 
              prefixIcon: Iconsax.coin, 
              keyboardType: TextInputType.number,
              isRequired: true,
              onChanged: (v) { lastEditedField = 'usd'; _calculate(); },
            )),
            const SizedBox(width: 12),
            Expanded(child: AppTextField(
              controller: _pkrPriceController, 
              label: 'Reseller Price (PKR)', 
              prefixIcon: Iconsax.money_2, 
              keyboardType: TextInputType.number,
              isRequired: true,
              onChanged: (v) { lastEditedField = 'pkr'; _calculate(); },
            )),
          ],
        ),
        const SizedBox(height: 4),
        Text('1 USD = ${provider.usdToPkrRate.toStringAsFixed(2)} PKR', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 12),
        AppTextField(controller: _salePriceController, label: 'Sale Price', prefixIcon: Iconsax.money_3, readOnly: true, filled: true),
        const SizedBox(height: 12),
        AppTextField(controller: _salesTaxController, label: '18% Sales Tax', prefixIcon: Iconsax.receipt_2, readOnly: true, filled: true),
        const SizedBox(height: 12),
        AppTextField(controller: _totalPriceController, label: 'Sale Price With Tax', prefixIcon: Iconsax.wallet, readOnly: true, filled: true),
      ],
    );
  }

  Widget _buildTaxSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200)
      ),
      child: Column(
        children: [
          _taxRow('I.Tax', iTaxChecked, _iTaxPercentController, _iTaxAmountController, (v) => setState(() { iTaxChecked = v; _calculate(); })),
          const SizedBox(height: 12),
          _taxRow('Others', othersChecked, _othersPercentController, _othersAmountController, (v) => setState(() { othersChecked = v; _calculate(); })),
          const SizedBox(height: 12),
          _taxRow('Profit', profitChecked, _profitPercentController, _profitAmountController, (v) => setState(() { profitChecked = v; _calculate(); })),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryColor.withValues(alpha: 0.8))),
    );
  }

  Widget _buildDropdown(String label, List<String> options, String? value, Function(String?) onChanged, {bool isRequired = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: options.contains(value) ? value : null,
      dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      decoration: InputDecoration(
        label: isRequired 
            ? RichText(text: TextSpan(text: label, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14), children: const [TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))]))
            : Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true,
        fillColor: isDark ? Colors.black26 : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor)),
      ),
      icon: const Icon(Iconsax.arrow_down_1, size: 16),
      items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black87), overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _taxRow(String label, bool checked, TextEditingController percent, TextEditingController amount, Function(bool) onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(value: checked, onChanged: (v) => onToggle(v ?? false), activeColor: AppTheme.primaryColor),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        Row(
          children: [
            Expanded(child: AppTextField(controller: percent, label: '%', keyboardType: TextInputType.number, onChanged: (v) => _calculate())),
            const SizedBox(width: 8),
            Expanded(child: AppTextField(controller: amount, label: 'Amount', readOnly: true, filled: true)),
          ],
        ),
      ],
    );
  }
}
