import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../Provider/stock/StockProvider.dart';
import '../../Provider/auth/access_control_provider.dart';
import '../../compoents/premium_card.dart';
import '../../compoents/app_theme.dart';
import '../../compoents/app_text_field.dart';
import '../../compoents/app_button.dart';
import '../../compoents/responsive_helper.dart';
import '../../constants/permission_keys.dart';
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

    final String resource = PermissionKeys.openingStock;
    final bool canRead = acp.canRead(resource);
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
                const Text("You don't have permission to view opening stock.", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Filters
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimationConfiguration.synchronized(
            child: FadeInAnimation(
              child: PremiumCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Search Item',
                      controller: _searchController,
                      prefixIcon: Iconsax.search_normal,
                      onChanged: (v) => _onFilter(),
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 400;
                        return isMobile 
                          ? Column(
                              children: [
                                _buildDropdown('Type', selectedType, Provider.of<StockProvider>(context).itemTypes.map((e) => e['name']!).toList(), (v) { setState(() => selectedType = v); _onFilter(); }),
                                const SizedBox(height: 12),
                                _buildDropdown('Category', selectedCategory, Provider.of<StockProvider>(context).categories.map((e) => e['name']!).toList(), (v) { setState(() => selectedCategory = v); _onFilter(); }),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(child: _buildDropdown('Type', selectedType, Provider.of<StockProvider>(context).itemTypes.map((e) => e['name']!).toList(), (v) { setState(() => selectedType = v); _onFilter(); })),
                                const SizedBox(width: 12),
                                Expanded(child: _buildDropdown('Category', selectedCategory, Provider.of<StockProvider>(context).categories.map((e) => e['name']!).toList(), (v) { setState(() => selectedCategory = v); _onFilter(); })),
                              ],
                            );
                      },
                    ),
                  ],
                ),
              ),
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
                return _buildEmptyState();
              }
              return AnimationLimiter(
                child: RefreshIndicator(
                  onRefresh: () => provider.fetchOpeningStock(search: _searchController.text),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: provider.openingStock.length,
                    itemBuilder: (context, index) {
                      final item = provider.openingStock[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: OpeningStockCard(item: item, canUpdate: canUpdate),
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

  Widget _buildDropdown(String label, String? value, List<String> options, ValueChanged<String?> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: const Text('All', style: TextStyle(fontSize: 13)),
              dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              items: [
                const DropdownMenuItem(value: null, child: Text('All', style: TextStyle(fontSize: 13))),
                ...options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.box, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text("No Stock Items Found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text("Try adjusting your search or filters.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class OpeningStockCard extends StatelessWidget {
  final OpeningStockData item;
  final bool canUpdate;
  const OpeningStockCard({super.key, required this.item, this.canUpdate = true});

  void _openEditDialog(BuildContext context) {
    AppTheme.showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      child: OpeningStockFormDialog(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PremiumCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      onTap: canUpdate ? () => _openEditDialog(context) : null,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: item.imageName != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(ApiConfig.getImageUrl(item.imageName!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Iconsax.box, color: AppTheme.primaryColor)),
                  )
                : const Icon(Iconsax.box, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.itemName ?? 'Unnamed Item', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text('${item.category} > ${item.subCategory}', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade500, fontSize: 11)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _smallInfo('Pur: ${item.purchasePrice}', Colors.blue),
                      const SizedBox(width: 8),
                      _smallInfo('Sale: ${item.salePrice}', Colors.green),
                      const SizedBox(width: 8),
                      _smallInfo('Stock: ${item.stock}', Colors.orange),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (canUpdate)
            Icon(Iconsax.edit_2, color: AppTheme.primaryColor.withValues(alpha: 0.5), size: 18),
        ],
      ),
    );
  }

  Widget _smallInfo(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class OpeningStockFormDialog extends StatefulWidget {
  final OpeningStockData item;
  const OpeningStockFormDialog({super.key, required this.item});

  @override
  State<OpeningStockFormDialog> createState() => _OpeningStockFormDialogState();
}

class _OpeningStockFormDialogState extends State<OpeningStockFormDialog> {
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
      'stock': _stockController.text,
    });
    setState(() => isSaving = false);
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock updated successfully'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final acp = Provider.of<AccessControlProvider>(context);
    final canUpdate = acp.canUpdate(PermissionKeys.openingStock);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Container(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                      child: const Icon(Iconsax.edit, color: AppTheme.primaryColor, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text('Edit Stock: ${widget.item.itemName}', 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        overflow: TextOverflow.ellipsis),
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
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(label: 'Purchase Price', controller: _purchaseController, prefixIcon: Iconsax.money_recive, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    AppTextField(label: 'Sale Price', controller: _saleController, prefixIcon: Iconsax.money_send, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    AppTextField(label: 'Unit Quantity', controller: _stockController, prefixIcon: Iconsax.box, keyboardType: TextInputType.number),
                  ],
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
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: (isSaving || !canUpdate) ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: isSaving 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                          : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
