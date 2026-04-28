import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../Provider/stock/StockProvider.dart';
import '../../../compoents/app_theme.dart';
import '../../../model/stock/stock_models.dart';

class EstimationFormDialog extends StatefulWidget {
  final EstimationData? estimation;
  const EstimationFormDialog({super.key, this.estimation});

  @override
  State<EstimationFormDialog> createState() => _EstimationFormDialogState();
}

class _EstimationFormDialogState extends State<EstimationFormDialog> {

  // Form State
  DateTime estimationDate = DateTime.now();
  String? selectedCustomer;
  String? customerId;
  String person = '';
  String designation = '';
  String? selectedService;
  String? serviceId;
  String estimateId = '';
  String taxMode = 'withoutTax';

  // Item Entry State
  String? selectedItem;
  String? itemRateId;
  String description = '';
  
  final _qtyCtrl = TextEditingController();
  final _purPriceCtrl = TextEditingController();
  final _salePriceCtrl = TextEditingController();
  final _salePriceWithTaxCtrl = TextEditingController();
  final _discountPercentCtrl = TextEditingController();

  // Read-only calculation results (as strings)
  String _purchaseTotal = '0.00';
  String _saleTotal = '0.00';
  String _saleTotalWithTax = '0.00';
  String _discountAmount = '0.00';
  String _finalPrice = '0.00';
  String _finalTotal = '0.00';

  List<Map<String, dynamic>> _rows = [];
  String _editingRowId = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final sp = Provider.of<StockProvider>(context, listen: false);
    
    _loadInitialData(sp);

    // Add listeners for real-time calculations
    _qtyCtrl.addListener(_calculateValues);
    _purPriceCtrl.addListener(_calculateValues);
    _salePriceCtrl.addListener(_calculateValues);
    _salePriceWithTaxCtrl.addListener(_calculateValues);
    _discountPercentCtrl.addListener(_calculateValues);
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _purPriceCtrl.dispose();
    _salePriceCtrl.dispose();
    _salePriceWithTaxCtrl.dispose();
    _discountPercentCtrl.dispose();
    super.dispose();
  }

  void _loadInitialData(StockProvider sp) async {
    EstimationData? est = widget.estimation;
    
    if (est != null && est.id != null) {
      // Fetch full details if items are missing or just to be sure (Parity with React)
      final fullEst = await sp.fetchEstimationById(est.id!);
      if (fullEst != null) est = fullEst;
    }

    if (est != null) {
      estimateId = est.estimateId ?? '';
      if (est.estimateDate != null) {
        estimationDate = DateTime.tryParse(est.estimateDate!) ?? DateTime.now();
      }
      selectedCustomer = est.customerName;
      customerId = est.customerId;
      person = est.person ?? '';
      designation = est.designation ?? '';
      selectedService = est.serviceName;
      serviceId = est.serviceId;
      taxMode = est.taxMode ?? 'withoutTax';

      if (est.items != null && est.items is List) {
        _rows = (est.items as List).map((it) => {
          'id': it['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'itemRateId': it['item_rate_id']?.toString() ?? it['itemRateId']?.toString(),
          'item': it['item_name']?.toString() ?? it['itemName']?.toString() ?? it['item']?.toString(),
          'qty': it['qty']?.toString(),
          'description': it['description']?.toString(),
          'purchasePrice': it['purchase_price']?.toString() ?? it['purchasePrice']?.toString(),
          'purchaseTotal': it['purchase_total']?.toString() ?? it['purchaseTotal']?.toString(),
          'salePrice': it['sale_price']?.toString() ?? it['salePrice']?.toString(),
          'saleTotal': it['sale_total']?.toString() ?? it['saleTotal']?.toString(),
          'salePriceWithTax': it['sale_price_with_tax']?.toString() ?? it['salePriceWithTax']?.toString(),
          'saleTotalWithTax': it['sale_total_with_tax']?.toString() ?? it['saleTotalWithTax']?.toString(),
          'discountPercentage': it['discount_percent']?.toString() ?? it['discountPercent']?.toString() ?? it['discountPercentage']?.toString(),
          'discountAmount': it['discount_amount']?.toString() ?? it['discountAmount']?.toString(),
          'finalPrice': it['final_price']?.toString() ?? it['finalPrice']?.toString(),
          'finalTotal': it['final_total']?.toString() ?? it['finalTotal']?.toString(),
        }).toList();
      }
    } else {
      // New Estimation
      estimateId = sp.generateNextEstimationId();
    }
    if (mounted) setState(() {});
  }

  void _calculateValues() {
    final qty = double.tryParse(_qtyCtrl.text) ?? 0;
    final purPrice = double.tryParse(_purPriceCtrl.text) ?? 0;
    final salePrice = double.tryParse(_salePriceCtrl.text) ?? 0;
    final salePriceWithTax = double.tryParse(_salePriceWithTaxCtrl.text) ?? 0;
    final discPercent = double.tryParse(_discountPercentCtrl.text) ?? 0;

    final purTotal = qty * purPrice;
    final saleTotal = qty * salePrice;
    final saleTotalWithTax = qty * salePriceWithTax;
    final basePrice = taxMode == 'withTax' ? salePriceWithTax : salePrice;
    final discPerUnit = (basePrice * discPercent) / 100;
    final discAmt = discPerUnit * qty;
    final finalPrice = (basePrice - discPerUnit).clamp(0.0, double.infinity);
    final finalTotal = finalPrice * qty;

    setState(() {
      _purchaseTotal = purTotal.toStringAsFixed(2);
      _saleTotal = saleTotal.toStringAsFixed(2);
      _saleTotalWithTax = saleTotalWithTax.toStringAsFixed(2);
      _discountAmount = discAmt.toStringAsFixed(2);
      _finalPrice = finalPrice.toStringAsFixed(2);
      _finalTotal = finalTotal.toStringAsFixed(2);
    });
  }

  Future<void> _onCustomerChanged(String company, StockProvider sp) async {
    try {
      final searchName = company.trim().toLowerCase();
      final found = sp.customers.cast<CustomerData?>().firstWhere(
        (c) => (c?.company?.trim().toLowerCase() ?? c?.name?.trim().toLowerCase()) == searchName,
        orElse: () => null,
      );
      
      if (found == null) {
        setState(() {
          selectedCustomer = company;
          customerId = null;
          person = '';
          designation = '';
        });
        return;
      }
      
      setState(() {
        selectedCustomer = company;
        customerId = found.id;
        person = found.person ?? '';
        designation = found.designation ?? '';
      });
      
      if (found.id != null) {
        final fullCustomer = await sp.fetchCustomerById(found.id!);
        if (fullCustomer != null && mounted) {
          setState(() {
            person = fullCustomer.person ?? person;
            designation = fullCustomer.designation ?? designation;
          });
        }
      }
    } catch (_) {
      setState(() {
        selectedCustomer = company;
      });
    }
  }

  void _onServiceChanged(String serviceName, StockProvider sp) {
    try {
      final found = sp.services.firstWhere((s) => s.serviceName == serviceName);
      setState(() {
        selectedService = serviceName;
        serviceId = found.id;
      });
    } catch (_) {
      setState(() {
        selectedService = serviceName;
      });
    }
  }

  void _onItemChanged(String itemName, StockProvider sp) {
    try {
      final found = sp.itemRates.firstWhere((r) => r.item == itemName);
      setState(() {
        selectedItem = itemName;
        itemRateId = found.id;
        description = found.itemSpecification ?? '';
        _purPriceCtrl.text = found.reseller ?? '';
        _salePriceCtrl.text = found.salePrice ?? '';
        _salePriceWithTaxCtrl.text = found.sale ?? '';
      });
    } catch (_) {
      setState(() {
        selectedItem = itemName;
      });
    }
    _calculateValues();
  }

  void _addOrUpdateItem() {
    if (selectedItem == null) return;
    if ((double.tryParse(_qtyCtrl.text) ?? 0) <= 0) return;

    final row = {
      'id': _editingRowId.isNotEmpty ? _editingRowId : DateTime.now().millisecondsSinceEpoch.toString(),
      'itemRateId': itemRateId,
      'item': selectedItem,
      'qty': _qtyCtrl.text,
      'description': description,
      'purchasePrice': _purPriceCtrl.text,
      'purchaseTotal': _purchaseTotal,
      'salePrice': _salePriceCtrl.text,
      'saleTotal': _saleTotal,
      'salePriceWithTax': _salePriceWithTaxCtrl.text,
      'saleTotalWithTax': _saleTotalWithTax,
      'discountPercentage': _discountPercentCtrl.text,
      'discountAmount': _discountAmount,
      'finalPrice': _finalPrice,
      'finalTotal': _finalTotal,
    };

    setState(() {
      if (_editingRowId.isNotEmpty) {
        final idx = _rows.indexWhere((r) => r['id'] == _editingRowId);
        if (idx != -1) _rows[idx] = row;
        _editingRowId = '';
      } else {
        _rows.insert(0, row);
      }

      // Reset entry fields
      selectedItem = null;
      itemRateId = null;
      description = '';
      _qtyCtrl.clear();
      _purPriceCtrl.clear();
      _salePriceCtrl.clear();
      _salePriceWithTaxCtrl.clear();
      _discountPercentCtrl.clear();
    });
  }

  void _editRow(Map<String, dynamic> row) {
    setState(() {
      _editingRowId = row['id'];
      selectedItem = row['item'];
      itemRateId = row['itemRateId'];
      description = row['description'] ?? '';
      _qtyCtrl.text = row['qty'].toString();
      _purPriceCtrl.text = row['purchasePrice'].toString();
      _salePriceCtrl.text = row['salePrice'].toString();
      _salePriceWithTaxCtrl.text = row['salePriceWithTax'].toString();
      _discountPercentCtrl.text = row['discountPercentage'].toString();
    });
    _calculateValues();
  }

  Future<void> _handleSave(StockProvider sp) async {
    if (_rows.isEmpty && selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one item')));
      return;
    }

    // If there's an active entry not added yet, add it? 
    // React logic: const rowsToSave = rows.length ? rows : hasCurrentFormEntry ? [...] : [];
    List<Map<String, dynamic>> finalRows = List.from(_rows);
    if (finalRows.isEmpty && selectedItem != null && (double.tryParse(_qtyCtrl.text) ?? 0) > 0) {
      finalRows.add({
        'itemRateId': itemRateId,
        'qty': _qtyCtrl.text,
        'description': description,
        'discountPercentage': _discountPercentCtrl.text,
      });
    }

    setState(() => _isSaving = true);
    
    final payload = {
      'estimate_date': '${estimationDate.year}-${estimationDate.month.toString().padLeft(2, '0')}-${estimationDate.day.toString().padLeft(2, '0')}',
      'customer_id': customerId != null ? int.tryParse(customerId!) : null,
      'service_id': serviceId != null ? int.tryParse(serviceId!) : null,
      'tax_mode': taxMode,
      'status': 'active',
      'items': finalRows.map((r) => {
        'item_rate_id': int.tryParse(r['itemRateId']?.toString() ?? ''),
        'item_name': r['item'] ?? '',
        'qty': double.tryParse(r['qty']?.toString() ?? '0'),
        'purchase_price': double.tryParse(r['purchasePrice']?.toString() ?? '0'),
        'sale_price': double.tryParse(r['salePrice']?.toString() ?? '0'),
        'sale_price_with_tax': double.tryParse(r['salePriceWithTax']?.toString() ?? '0'),
        'discount_percent': double.tryParse(r['discountPercentage']?.toString() ?? '0'),
        'description': r['description'] ?? '',
      }).toList(),
    };

    final success = await sp.saveEstimation(data: payload, id: widget.estimation?.id);
    setState(() => _isSaving = false);

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleDelete(StockProvider sp) async {
    final confirmed = await AppTheme.showAnimatedDialog<bool>(
      context: context,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Estimation'),
        content: const Text('Are you sure you want to delete this estimation? This action cannot be undone.'),
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
      final success = await sp.deleteEstimation(widget.estimation!.id!);
      if (!mounted) return;
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete estimation')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sp = Provider.of<StockProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionBg = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50]!;
    final borderColor = isDark ? Colors.white10 : Colors.grey[200]!;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 900),
        child: Container(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          child: Column(
            children: [
            // Header
            _buildHeader(),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Section 1: Estimation Details
                    _buildEstimationDetailsSection(sp, sectionBg, borderColor),
                    const SizedBox(height: 20),

                    // Section 2: Item Entry
                    _buildItemEntrySection(sp, sectionBg, borderColor),
                    const SizedBox(height: 20),

                    // Section 3: Queued Items
                    if (_rows.isNotEmpty) _buildQueuedItemsSection(sectionBg, borderColor),
                  ],
                ),
              ),
            ),

            // Footer
            _buildFooter(sp),
          ],
        ),
      ),
    ));
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
        border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Iconsax.document_text, color: AppTheme.primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.estimation == null ? 'NEW ESTIMATION' : 'EDIT ESTIMATION',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                Text(
                  widget.estimation == null ? 'Generate a new cost estimate' : 'Update existing estimation details',
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.grey[600]),
                ),
              ],
            ),
          ),
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
    );
  }

  Widget _buildEstimationDetailsSection(StockProvider sp, Color sectionBg, Color borderColor) {
    return _sectionCard(
      sectionBg: sectionBg,
      borderColor: borderColor,
      icon: Iconsax.setting_4,
      title: 'ESTIMATION SETUP',
      subtitle: 'Date, customer, and department details.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _readOnlyField('Estimate ID', estimateId)),
              const SizedBox(width: 12),
              Expanded(child: _datePicker()),
            ],
          ),
          const SizedBox(height: 14),
          _labeledDropdown(
            label: 'Customer',
            value: selectedCustomer,
            options: sp.customers.map((c) => c.company ?? c.name ?? '').where((s) => s.isNotEmpty).toList(),
            onChanged: (v) => _onCustomerChanged(v ?? '', sp),
            isRequired: true,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _readOnlyField('Person', person, hint: 'Auto-filled')),
              const SizedBox(width: 12),
              Expanded(child: _readOnlyField('Designation', designation, hint: 'Auto-filled')),
            ],
          ),
          const SizedBox(height: 14),
          _labeledDropdown(
            label: 'Department / Product',
            value: selectedService,
            options: sp.services.map((s) => s.serviceName ?? '').where((e) => e.isNotEmpty).toList(),
            onChanged: (v) => _onServiceChanged(v ?? '', sp),
          ),
          const SizedBox(height: 14),
          _buildTaxModeRow(),
        ],
      ),
    );
  }

  Widget _buildTaxModeRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Tax Mode', isRequired: true),
        Row(
          children: [
            const SizedBox(width: 8),
            _radio('Without Tax', 'withoutTax'),
            const SizedBox(width: 20),
            _radio('With Tax', 'withTax'),
          ],
        ),
      ],
    );
  }

  Widget _radio(String label, String value) {
    return GestureDetector(
      onTap: () {
        setState(() => taxMode = value);
        _calculateValues();
      },
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: taxMode,
            activeColor: AppTheme.primaryColor,
            onChanged: (v) {
              setState(() => taxMode = v!);
              _calculateValues();
            },
          ),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildItemEntrySection(StockProvider sp, Color sectionBg, Color borderColor) {
    return _sectionCard(
      sectionBg: sectionBg,
      borderColor: borderColor,
      icon: Iconsax.box,
      title: 'ITEM DETAILS',
      subtitle: 'Select item, enter qty and discount.',
      child: Column(
        children: [
          _labeledDropdown(
            label: 'Item',
            value: selectedItem,
            options: sp.itemRates.map((e) => e.item ?? "").where((s) => s.isNotEmpty).toList(),
            onChanged: (v) => _onItemChanged(v ?? '', sp),
            isRequired: true,
          ),
          const SizedBox(height: 14),
          _labeledTextField(
            label: 'Description / Specification',
            initialValue: description,
            onChanged: (v) => description = v,
            hint: 'Auto-filled from item definition',
            maxLines: 2,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _labeledTextField(
                  label: 'Qty',
                  controller: _qtyCtrl,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _labeledTextField(
                  label: 'Discount %',
                  controller: _discountPercentCtrl,
                  hint: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Pricing Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.black26 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                _pricingRow('Pur. Price', _purPriceCtrl, 'Pur. Total', _purchaseTotal),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
                _pricingRow('Sale Price', _salePriceCtrl, 'Sale Total', _saleTotal),
                if (taxMode == 'withTax') ...[
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
                  _pricingRow('Sale Price (Tax)', _salePriceWithTaxCtrl, 'Sale Total (Tax)', _saleTotalWithTax),
                ],
                const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
                _summaryRow('Discount Amount', _discountAmount, isNegative: true),
                _summaryRow('Final Price', _finalPrice, isBold: true, color: AppTheme.primaryColor),
                _summaryRow('Final Total', _finalTotal, isBold: true, color: AppTheme.primaryColor, isLarge: true),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _addOrUpdateItem,
              icon: Icon(_editingRowId.isNotEmpty ? Icons.check : Icons.add),
              label: Text(_editingRowId.isNotEmpty ? 'Update Item' : 'Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueuedItemsSection(Color sectionBg, Color borderColor) {
    return _sectionCard(
      sectionBg: sectionBg,
      borderColor: borderColor,
      icon: Iconsax.task_square,
      title: 'QUEUED ITEMS',
      subtitle: '${_rows.length} item(s) to be saved.',
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _rows.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final row = _rows[index];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.black26 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(row['item'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        'Qty: ${row['qty']} | Price: ${row['finalPrice']} | Total: ${row['finalTotal']}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _iconBtn(Iconsax.edit, () => _editRow(row), Colors.blue),
                const SizedBox(width: 8),
                _iconBtn(Iconsax.trash, () => setState(() => _rows.removeAt(index)), Colors.red),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter(StockProvider sp) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          if (widget.estimation != null)
            IconButton(
              onPressed: _isSaving ? null : () => _handleDelete(sp),
              icon: const Icon(Iconsax.trash, color: Colors.red, size: 20),
              tooltip: 'Delete Estimation',
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
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _isSaving ? null : () => _handleSave(sp),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(160, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(widget.estimation == null ? 'Create Estimation' : 'Save Changes', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _sectionCard({
    required Color sectionBg,
    required Color borderColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: sectionBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                      Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.blueGrey[400])),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey[200]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _pricingRow(String label1, TextEditingController ctrl1, String label2, String value2) {
    return Row(
      children: [
        Expanded(
          child: _labeledTextField(
            label: label1,
            controller: ctrl1,
            hint: '0.00',
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _readOnlyField(label2, value2)),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false, Color? color, bool isNegative = false, bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isLarge ? 14 : 12, color: Colors.grey[600])),
          Text(
            '${isNegative ? "- " : ""}PKR $value',
            style: TextStyle(
              fontSize: isLarge ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? (isNegative ? Colors.red : null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyField(String label, String value, {String? hint}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        Container(
          height: 48,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? Colors.black26 : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white12 : Colors.grey[300]!),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            value.isNotEmpty ? value : (hint ?? ''),
            style: TextStyle(
              fontSize: 14,
              color: value.isNotEmpty ? (isDark ? Colors.white : Colors.black87) : Colors.grey[400],
            ),
          ),
        ),
      ],
    );
  }

  Widget _datePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Date', isRequired: true),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: estimationDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) setState(() => estimationDate = picked);
          },
          child: Container(
            height: 48,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white12 : Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${estimationDate.year}-${estimationDate.month.toString().padLeft(2, '0')}-${estimationDate.day.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                  ),
                ),
                Icon(Iconsax.calendar_1, size: 18, color: isDark ? Colors.white54 : Colors.grey[500]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _labeledTextField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    ValueChanged<String>? onChanged,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, isRequired: isRequired),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
            filled: true,
            fillColor: isDark ? Colors.black26 : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _labeledDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, isRequired: isRequired),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? Colors.black26 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white12 : Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : null,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              hint: Text('Select', style: TextStyle(color: Colors.grey[400])),
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label, {bool isRequired = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: RichText(
        text: TextSpan(
          text: label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: isDark ? Colors.white54 : Colors.grey[600],
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onPressed, Color color) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
