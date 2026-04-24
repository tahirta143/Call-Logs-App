import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../Provider/stock/StockProvider.dart';
import '../../../compoents/app_theme.dart';
import '../../../compoents/searchable_select.dart';
import '../../../model/stock/stock_models.dart';
import '../../../model/stock/service_model.dart';
import '../../../Provider/auth/access_control_provider.dart';
import '../../../constants/permission_keys.dart';

// ─────────────────────────────────────────────
// Row model for items added inside the dialog
// ─────────────────────────────────────────────
class _QuotationRow {
  final String id;
  String item;
  String? itemRateId;
  String price;
  String qty;
  String description;

  _QuotationRow({
    required this.id,
    required this.item,
    this.itemRateId,
    this.price = '',
    this.qty = '',
    this.description = '',
  });

  double get priceNum => double.tryParse(price) ?? 0;
  double get qtyNum => double.tryParse(qty) ?? 0;
  double get total => priceNum * qtyNum;
  double get gst => (priceNum * 18) / 100;
  double get rateWithGst => priceNum + gst;
  double get totalWithGst => rateWithGst * qtyNum;
}

// ─────────────────────────────────────────────
// Entry point: show the quotation dialog
// ─────────────────────────────────────────────
Future<void> showQuotationFormDialog(
  BuildContext context, {
  QuotationData? quotation,
}) {
  return AppTheme.showAnimatedDialog(
    context: context,
    barrierDismissible: false,
    child: QuotationFormDialog(quotation: quotation),
  );
}

// ─────────────────────────────────────────────
// Main Dialog Widget
// ─────────────────────────────────────────────
class QuotationFormDialog extends StatefulWidget {
  final QuotationData? quotation;
  const QuotationFormDialog({super.key, this.quotation});

  @override
  State<QuotationFormDialog> createState() => _QuotationFormDialogState();
}

class _QuotationFormDialogState extends State<QuotationFormDialog> {
  bool _isInit = false;
  bool _isSaving = false;

  // Setup section state
  String quotationNo = '';
  DateTime quotationDate = DateTime.now();
  String revisionId = '';
  String? estimationId;
  String? selectedCompany;
  String? selectedCustomerId;
  String personReadOnly = '';
  String designationReadOnly = '';
  String departmentReadOnly = '';
  String? selectedProduct;
  String? selectedServiceId;
  String? selectedLetterType = 'Quotation';
  String taxMode = 'withoutTax';
  String createdBy = '';

  // Edit mode
  bool _isEditMode = false;
  bool _isRevisionMode = false;
  String? _editingId;

  // Item entry state
  String? selectedItem;
  String? _selectedItemRateId;
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _qtyCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  String _editingRowId = '';

  final List<_QuotationRow> _rows = [];

  static const _letterTypes = ['Letter', 'Quotation', 'Bill', 'Invoice'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final sp = Provider.of<StockProvider>(context, listen: false);
      await sp.loadSetupOptions();
      await sp.fetchEstimations();

      final nextNo = await sp.getNextQuotationNo(_letterType);
      final nextRev = await sp.getNextRevisionId();

      if (!mounted) return;
      setState(() {
        quotationNo = nextNo['quotationNo']?.toString() ?? quotationNo;
        revisionId = nextRev['revisionId']?.toString() ?? revisionId;
        _isInit = true;
      });

      if (widget.quotation != null) {
        _loadFromQuotation(widget.quotation!, sp);
      }
    });
  }

  String get _letterType => selectedLetterType ?? 'Quotation';

  void _loadFromQuotation(QuotationData q, StockProvider sp) {
    setState(() {
      _isEditMode = true;
      _editingId = q.id;
      quotationNo = q.quotationNo ?? '';
      selectedCompany = q.company;
      selectedCustomerId = q.customerId;
      personReadOnly = q.person ?? '';
      designationReadOnly = q.designation ?? '';
      departmentReadOnly = q.department ?? '';
      taxMode = q.taxMode ?? 'withoutTax';
      selectedLetterType = q.letterType ?? 'Quotation';
      selectedProduct = q.forProduct;
      selectedServiceId = q.serviceId;
      estimationId = q.estimationId;
      revisionId = q.revisionId ?? '';
      createdBy = q.createdBy ?? '';

      // Load items
      _rows.clear();
      for (final item in (q.items ?? [])) {
        _rows.add(_QuotationRow(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          item: item['item_name'] ?? item['itemName'] ?? item['item'] ?? '',
          itemRateId: item['item_rate_id']?.toString() ?? item['itemRateId']?.toString(),
          price: (item['rate'] ?? item['price'] ?? '').toString(),
          qty: (item['qty'] ?? '').toString(),
          description: item['description'] ?? '',
        ));
      }
    });
  }

  // ── Auto-calc total
  String get _currentTotal {
    final p = double.tryParse(_priceCtrl.text) ?? 0;
    final q = double.tryParse(_qtyCtrl.text) ?? 0;
    final t = p * q;
    return t == 0 ? '' : t.toStringAsFixed(2);
  }

  // ── Totals
  double get _totalQty => _rows.fold(0, (s, r) => s + r.qtyNum);
  double get _totalAmount => _rows.fold(
      0,
      (s, r) => s + (taxMode == 'withTax' ? r.totalWithGst : r.total));

  // ── Letter Type changed: auto-fetch next Quotation No
  Future<void> _onLetterTypeChanged(String type, StockProvider sp) async {
    setState(() {
      selectedLetterType = type;
      // Optionally show a loading placeholder in the number field if needed
    });
    
    final nextNo = await sp.getNextQuotationNo(type);
    if (!mounted) return;
    
    setState(() {
      quotationNo = nextNo['quotationNo']?.toString() ?? quotationNo;
    });
  }

  // ── Customer selected: auto-fill Person, Designation, Department
  Future<void> _onCompanyChanged(String company, StockProvider sp) async {
    final searchName = company.trim().toLowerCase();
    final customer = sp.customers.cast<CustomerData?>().firstWhere(
      (c) => (c?.company?.trim().toLowerCase() ?? c?.name?.trim().toLowerCase()) == searchName,
      orElse: () => null,
    );
    if (customer == null) return;

    setState(() {
      selectedCompany = company;
      selectedCustomerId = customer.id;
      // Preliminary fill from list
      personReadOnly = customer.person ?? '';
      designationReadOnly = customer.designation ?? '';
      departmentReadOnly = customer.department ?? '';
    });

    // Fetch full details if possible, matching React's customerService.get(id)
    if (customer.id != null) {
      final fullCustomer = await sp.fetchCustomerById(customer.id!);
      if (fullCustomer != null && mounted) {
        setState(() {
          personReadOnly = fullCustomer.person ?? personReadOnly;
          designationReadOnly = fullCustomer.designation ?? designationReadOnly;
          departmentReadOnly = fullCustomer.department ?? departmentReadOnly;
        });
      }
    }
  }

  // ── Item selected: auto-fill price and description
  void _onItemChanged(String itemName, StockProvider sp) {
    final searchItem = itemName.trim().toLowerCase();
    final rate = sp.itemRates.cast<ItemRateData?>().firstWhere(
      (r) => r?.item?.trim().toLowerCase() == searchItem,
      orElse: () => null,
    );
    setState(() {
      selectedItem = itemName;
      _selectedItemRateId = rate?.id;
      
      // Strict React parity: Update price and description if available in item rate
      if (rate != null) {
        if (rate.salePrice != null || rate.sale != null || rate.reseller != null) {
          _priceCtrl.text = rate.salePrice ?? rate.sale ?? rate.reseller ?? _priceCtrl.text;
        }
        if (rate.itemSpecification != null || rate.specification != null || rate.description != null) {
          _descCtrl.text = rate.itemSpecification ?? rate.specification ?? rate.description ?? _descCtrl.text;
        }
      }
    });
  }

  // ── Estimation selected: auto-fill rows + fields
  Future<void> _onEstimationChanged(String estId, StockProvider sp) async {
    final normalizedId = estId.trim();
    final est = sp.estimations.cast<EstimationData?>().firstWhere(
      (e) => e?.estimateId?.trim() == normalizedId,
      orElse: () => null,
    );
    if (est == null) {
      setState(() => estimationId = estId);
      return;
    }

    try {
      // Logic from React Quotation.jsx: handleEstimationChange
      setState(() {
        estimationId = estId;
        selectedCompany = est.customerName ?? est.company;
        selectedCustomerId = est.customerId;
        selectedProduct = est.serviceName;
        selectedServiceId = est.serviceId;
        
        personReadOnly = est.person ?? '';
        designationReadOnly = est.designation ?? '';
        departmentReadOnly = est.department ?? '';
        
        if (taxMode.isEmpty) taxMode = 'withoutTax';

        _rows.clear();
        for (final item in (est.items ?? [])) {
          final rate = (item['salePrice'] ?? item['sale_price'] ?? item['price'] ?? 0).toDouble();
          final qty = (item['qty'] ?? 0).toDouble();
          
          _rows.add(_QuotationRow(
            id: DateTime.now().microsecondsSinceEpoch.toString() + _rows.length.toString(),
            item: (item['itemName'] ?? item['item_name'] ?? item['item'] ?? item['service'] ?? '').toString(),
            itemRateId: (item['itemRateId'] ?? item['item_rate_id'] ?? item['id'])?.toString(),
            price: rate == 0 ? '' : rate.toString(),
            qty: qty == 0 ? '' : qty.toString(),
            description: (item['description'] ?? item['item_specification'] ?? item['specification'] ?? '').toString(),
          ));
        }
      });
    } catch (e) {
      if (kDebugMode) print("Error loading estimation: $e");
    }
  }

  // ── Service selected
  void _onServiceChanged(String serviceName, StockProvider sp) {
    final service = sp.services.cast<ServiceData?>().firstWhere(
      (s) => s?.serviceName == serviceName,
      orElse: () => null,
    );
    setState(() {
      selectedProduct = serviceName;
      selectedServiceId = service?.id;
    });
  }


  // ── Revision search: load existing quotation as revision source
  Future<void> _onRevisionBlur(StockProvider sp) async {
    if (revisionId.isEmpty) return;
    final existing = sp.quotations.any((q) => q.revisionId == revisionId);
    if (!existing) return;

    final q = await sp.fetchQuotationByRevision(revisionId);
    if (q == null || !mounted) return;

    setState(() {
      _isRevisionMode = true;
      _editingId = q.id;
    });
    _loadFromQuotation(q, sp);
  }

  // ── Add / update row
  void _addOrUpdateItem() {
    if (selectedItem == null || selectedItem!.isEmpty) {
      _showSnack("Please select an item.");
      return;
    }
    if ((double.tryParse(_qtyCtrl.text) ?? 0) <= 0) {
      _showSnack("Please enter a valid quantity.");
      return;
    }
    setState(() {
      if (_editingRowId.isNotEmpty) {
        final idx = _rows.indexWhere((r) => r.id == _editingRowId);
        if (idx != -1) {
          _rows[idx]
            ..item = selectedItem!
            ..itemRateId = _selectedItemRateId
            ..price = _priceCtrl.text
            ..qty = _qtyCtrl.text
            ..description = _descCtrl.text;
        }
        _editingRowId = '';
      } else {
        _rows.add(_QuotationRow(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          item: selectedItem!,
          itemRateId: _selectedItemRateId,
          price: _priceCtrl.text,
          qty: _qtyCtrl.text,
          description: _descCtrl.text,
        ));
      }
      selectedItem = null;
      _selectedItemRateId = null;
      _priceCtrl.clear();
      _qtyCtrl.clear();
      _descCtrl.clear();
    });
  }

  void _editRow(_QuotationRow row) {
    setState(() {
      _editingRowId = row.id;
      selectedItem = row.item;
      _selectedItemRateId = row.itemRateId;
      _priceCtrl.text = row.price;
      _qtyCtrl.text = row.qty;
      _descCtrl.text = row.description;
    });
  }

  void _deleteRow(String id) {
    setState(() {
      _rows.removeWhere((r) => r.id == id);
      if (_editingRowId == id) _editingRowId = '';
    });
  }

  // ── Validate & Save
  Future<void> _save(StockProvider sp) async {
    if (selectedCustomerId == null || selectedCustomerId!.isEmpty) {
      _showSnack("Customer is required.");
      return;
    }
    if (selectedLetterType == null || selectedLetterType!.isEmpty) {
      _showSnack("Letter type is required.");
      return;
    }
    if (taxMode.isEmpty) {
      _showSnack("Tax mode is required.");
      return;
    }
    if (_rows.isEmpty) {
      _showSnack("Please add at least one item.");
      return;
    }

    setState(() => _isSaving = true);

    final payload = {
      'quotationDate': quotationDate.toIso8601String().split('T').first,
      'customerId': selectedCustomerId,
      'estimationId': estimationId,
      'serviceId': selectedServiceId,
      'letterType': selectedLetterType,
      'taxMode': taxMode,
      'status': 'active',
      'items': _rows.map((r) => {
        'itemRateId': r.itemRateId,
        'itemName': r.item,
        'rate': r.priceNum,
        'qty': r.qtyNum,
        'description': r.description,
      }).toList(),
    };

    bool success;
    if (_isRevisionMode && _editingId != null) {
      success = await sp.reviseQuotation(_editingId!, payload);
    } else if (_isEditMode && _editingId != null) {
      success = await sp.saveQuotation(data: payload, id: _editingId);
    } else {
      success = await sp.saveQuotation(data: payload);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      _showSnack(
        _isRevisionMode ? "Revision saved!" : _isEditMode ? "Quotation updated!" : "Quotation saved!",
        isSuccess: true,
      );
      Navigator.of(context).pop();
    } else {
      _showSnack(sp.message.isNotEmpty ? sp.message : "Failed to save. Check your connection.");
    }
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isSuccess ? AppTheme.primaryColor : Colors.red[700],
    ));
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sp = Provider.of<StockProvider>(context);
    final acp = Provider.of<AccessControlProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final canDelete = acp.canDelete(PermissionKeys.quotation);
    final canUpdate = acp.canUpdate(PermissionKeys.quotation);
    final canCreate = acp.canCreate(PermissionKeys.quotation);

    final bool isEdit = _isEditMode || _isRevisionMode;
    final bool hasPermission = isEdit ? canUpdate : canCreate;

    final bg = isDark ? const Color(0xFF121212) : Colors.white;
    final sectionBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FB);
    final borderColor = isDark ? Colors.grey[800]! : const Color(0xFFE2E8F0);

    final itemOptions = sp.itemRates.map((r) => r.item ?? '').where((s) => s.isNotEmpty).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 800,
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(isDark),
            if (!_isInit)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildSetupSection(sp, sectionBg, borderColor),
                      const SizedBox(height: 16),
                      _buildItemSection(sp, sectionBg, borderColor, itemOptions),
                      if (_rows.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildQueuedItemsSection(sectionBg, borderColor),
                      ],
                    ],
                  ),
                ),
              ),
            _buildFooter(sp, borderColor, canDelete, hasPermission),
          ],
        ),
      ),
    );
  }

  // ── Header
  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF252525), Color(0xFF1A1A1A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : AppTheme.primaryGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Iconsax.document_text, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isRevisionMode
                      ? 'Save Revision'
                      : _isEditMode
                          ? 'Edit Quotation'
                          : 'New Quotation',
                  style: const TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Fill in all required fields and add items before saving.',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Setup Section
  Widget _buildSetupSection(StockProvider sp, Color sectionBg, Color borderColor) {
    final companyOptions = sp.customers.map((c) => (c.company ?? c.name ?? '').trim()).where((s) => s.isNotEmpty).toSet().toList();
    final productOptions = sp.services.map((s) => (s.serviceName ?? '').trim()).where((s) => s.isNotEmpty).toSet().toList();
    final estimationOptions = sp.estimations.map((e) => (e.estimateId ?? '').trim()).where((s) => s.isNotEmpty).toSet().toList();
    // These are used in SearchableSelect and other widgets below

    return _sectionCard(
      sectionBg: sectionBg,
      borderColor: borderColor,
      icon: Iconsax.document_text,
      title: 'QUOTATION SETUP',
      subtitle: 'Quotation no, date, customer, revision, letter type, and product.',
      child: Column(
        children: [
          // Row 1: Quotation No + Date
          Row(
            children: [
              Expanded(child: _readOnlyField('Quotation No', quotationNo)),
              const SizedBox(width: 12),
              Expanded(child: _datePicker()),
            ],
          ),
          const SizedBox(height: 14),
          // Row 2: Revision ID + Estimation ID
          Row(
            children: [
              Expanded(
                child: _labeledTextField(
                  label: 'Revision ID',
                  initialValue: revisionId,
                  onChanged: (v) => revisionId = v,
                  onEditingComplete: () => _onRevisionBlur(sp),
                  hint: 'Enter revision ID',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _labeledDropdown(
                  label: 'Estimation ID',
                  value: estimationId?.trim(),
                  options: estimationOptions,
                  onChanged: (v) => _onEstimationChanged(v ?? '', sp),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _labeledDropdown(
            label: 'Customer',
            value: selectedCompany,
            options: companyOptions,
            onChanged: (v) => _onCompanyChanged(v ?? '', sp),
            isRequired: true,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _readOnlyField('Person', personReadOnly, hint: 'Auto-filled from customer')),
              const SizedBox(width: 12),
              Expanded(child: _readOnlyField('Designation', designationReadOnly, hint: 'Auto-filled')),
            ],
          ),
          const SizedBox(height: 14),
          // Row 5: Department + Letter Type
          Row(
            children: [
              Expanded(child: _readOnlyField('Department', departmentReadOnly, hint: 'Auto-filled')),
              const SizedBox(width: 12),
              Expanded(
                child: _labeledDropdown(
                  label: 'Letter Type',
                  value: selectedLetterType,
                  options: _letterTypes,
                  onChanged: (v) => _onLetterTypeChanged(v ?? '', sp),
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Row 6: For Product
          _labeledDropdown(
            label: 'For Product',
            value: selectedProduct,
            options: productOptions,
            onChanged: (v) => _onServiceChanged(v ?? '', sp),
          ),
          const SizedBox(height: 14),
          // Row 7: Tax Mode Radios
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
      onTap: () => setState(() => taxMode = value),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: taxMode,
            activeColor: AppTheme.primaryColor,
            onChanged: (v) => setState(() => taxMode = v!),
          ),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Item Entry Section
  Widget _buildItemSection(StockProvider sp, Color sectionBg, Color borderColor, List<String> itemOptions) {
    return _sectionCard(
      sectionBg: sectionBg,
      borderColor: borderColor,
      icon: Iconsax.box,
      title: 'ITEM DETAILS',
      subtitle: 'Select item, enter price, qty, and description then tap Add.',
      child: Column(
        children: [
          _labeledDropdown(
            label: 'Item',
            value: selectedItem,
            options: itemOptions,
            onChanged: (v) => _onItemChanged(v ?? '', sp),
            isRequired: true,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _labeledTextField(
                  label: 'Price',
                  controller: _priceCtrl,
                  hint: '0.00',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _labeledTextField(
                  label: 'Qty',
                  controller: _qtyCtrl,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _readOnlyField('Total', _currentTotal, hint: 'Auto')),
            ],
          ),
          const SizedBox(height: 14),
          _labeledTextField(
            label: 'Description',
            controller: _descCtrl,
            hint: 'Item description (optional)',
            maxLines: 2,
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

  // ── Queued Items Table
  Widget _buildQueuedItemsSection(Color sectionBg, Color borderColor) {
    return _sectionCard(
      sectionBg: sectionBg,
      borderColor: borderColor,
      icon: Iconsax.task_square,
      title: 'QUEUED ITEMS',
      subtitle: '${_rows.length} item(s) — review before saving.',
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const SizedBox(width: 28),
                _th('Item', flex: 3),
                _th('Rate'),
                _th('Qty'),
                if (taxMode == 'withTax') ...[
                  _th('18% GST'),
                  _th('W/ GST'),
                ],
                _th('Total', flex: 2, align: TextAlign.right),
                const SizedBox(width: 72),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Rows
          ...List.generate(_rows.length, (i) {
            final row = _rows[i];
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: i.isEven ? (isDark ? Colors.white.withOpacity(0.03) : Colors.white) : sectionBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text('${i + 1}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ),
                  _td(row.item, flex: 3),
                  _td(row.price.isEmpty ? '-' : row.price),
                  _td(row.qty.isEmpty ? '-' : row.qty),
                  if (taxMode == 'withTax') ...[
                    _td(row.gst.toStringAsFixed(2)),
                    _td(row.rateWithGst.toStringAsFixed(2)),
                  ],
                  _td(
                    taxMode == 'withTax'
                        ? row.totalWithGst.toStringAsFixed(2)
                        : row.total.toStringAsFixed(2),
                    flex: 2,
                    align: TextAlign.right,
                    bold: true,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(
                    width: 72,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _iconBtn(Icons.edit_outlined, () => _editRow(row), Colors.blue[600]!),
                        const SizedBox(width: 4),
                        _iconBtn(Icons.delete_outline, () => _deleteRow(row.id), Colors.red[400]!),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          // Totals footer
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text('Total Qty: ${_totalQty.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  'Grand Total: ${_totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Footer
  Widget _buildFooter(StockProvider sp, Color borderColor, bool canDelete, bool hasPermission) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_isEditMode && _editingId != null && canDelete)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text('Are you sure you want to delete this quotation?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () async {
                          final success = await sp.deleteQuotation(_editingId!);
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Flexible(
            child: ElevatedButton.icon(
              onPressed: (_isSaving || !hasPermission) ? null : () => _save(sp),
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Iconsax.document_download, size: 18),
              label: Text(
                _isSaving
                    ? 'Saving...'
                    : !hasPermission
                        ? 'No Permission'
                        : _isRevisionMode
                            ? 'Save Revision'
                            : _isEditMode
                                ? 'Update'
                                : 'Save',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 28, 
                  vertical: 14
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HELPER WIDGETS
  // ─────────────────────────────────────────────
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
      decoration: AppTheme.premiumCardDecoration(context, color: sectionBg),
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
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                            fontSize: 11, 
                            fontWeight: FontWeight.w800, 
                            letterSpacing: 1.2,
                            color: isDark ? Theme.of(context).colorScheme.secondary : AppTheme.accentColor,
                          )),
                      Text(subtitle, 
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.blueGrey[400])),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? Colors.white10 : AppTheme.primaryColor.withOpacity(0.05)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
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
              color: value.isNotEmpty 
                ? (isDark ? Colors.white : Colors.black87) 
                : Colors.grey[400],
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
              initialDate: quotationDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) setState(() => quotationDate = picked);
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
                    '${quotationDate.year}-${quotationDate.month.toString().padLeft(2, '0')}-${quotationDate.day.toString().padLeft(2, '0')}',
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
    VoidCallback? onEditingComplete,
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
          onEditingComplete: onEditingComplete,
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
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
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

  // Table helpers
  Widget _th(String text, {int flex = 1, TextAlign align = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8),
      ),
    );
  }

  Widget _td(String text, {int flex = 1, TextAlign align = TextAlign.left, bool bold = false, Color? color}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
        overflow: TextOverflow.ellipsis,
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
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
