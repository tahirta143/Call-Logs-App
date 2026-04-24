import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../Provider/stock/StockProvider.dart';
import '../../../compoents/app_theme.dart';
import '../../../compoents/responsive_helper.dart';
import '../../../model/stock/service_model.dart';
import '../../compoents/app_button.dart';
import '../../compoents/app_text_field.dart';
import '../../../constants/permission_keys.dart';
import 'package:infinity/Provider/auth/access_control_provider.dart';
import 'components/stock_card.dart';

class ServicesProductsScreen extends StatefulWidget {
  const ServicesProductsScreen({super.key});

  @override
  State<ServicesProductsScreen> createState() => _ServicesProductsScreenState();
}

class _ServicesProductsScreenState extends State<ServicesProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StockProvider>(context, listen: false).fetchServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final acp = Provider.of<AccessControlProvider>(context);

    if (acp.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final String resource = PermissionKeys.service;
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
                const Text("You don't have permission to view services.", style: TextStyle(color: Colors.grey)),
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
                  label: 'Search services...',
                  prefixIcon: Iconsax.search_normal,
                  onChanged: (v) => provider.fetchServices(search: v),
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
          child: provider.isLoading && provider.services.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : AnimationLimiter(
                  child: RefreshIndicator(
                    onRefresh: () => provider.fetchServices(search: _searchController.text),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: provider.services.length,
                      itemBuilder: (context, index) {
                        final service = provider.services[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: StockCard(
                                  title: service.serviceName ?? 'N/A',
                                  subtitle: "Duration: ${service.durationTime ?? '0'} min",
                                  trailing: "Rs ${service.rate ?? '0'}",
                                  icon: Iconsax.box,
                                  onTap: canUpdate ? () => _openServiceDialog(service) : null,
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
        onPressed: () => _openServiceDialog(null),
        icon: const Icon(Iconsax.add, color: Colors.white),
        tooltip: 'Add Service',
      ),
    );
  }

  void _openServiceDialog(ServiceData? service) {
    AppTheme.showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      child: _ServiceFormDialog(service: service),
    );
  }
}

class _ServiceFormDialog extends StatefulWidget {
  final ServiceData? service;
  const _ServiceFormDialog({this.service});

  @override
  State<_ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<_ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController durationController;
  late TextEditingController rateController;
  String selectedStatus = 'active';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.service?.serviceName ?? '');
    durationController = TextEditingController(text: widget.service?.durationTime ?? '');
    rateController = TextEditingController(text: widget.service?.rate ?? '');
    selectedStatus = widget.service?.status ?? 'active';
  }

  @override
  void dispose() {
    nameController.dispose();
    durationController.dispose();
    rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);
    final acp = Provider.of<AccessControlProvider>(context);
    final canUpdate = acp.canUpdate(PermissionKeys.service);
    final canCreate = acp.canCreate(PermissionKeys.service);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool isEdit = widget.service != null;
    final bool hasPermission = isEdit ? canUpdate : canCreate;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
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
                      child: Icon(isEdit ? Iconsax.edit : Iconsax.add_square, color: AppTheme.primaryColor, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(isEdit ? 'Edit Service' : 'Add Service', 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
              AppTextField(
                controller: nameController,
                label: 'Service Name',
                prefixIcon: Iconsax.box,
                isRequired: true,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: durationController,
                      label: 'Duration (min)',
                      prefixIcon: Iconsax.timer,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: rateController,
                      label: 'Rate (Rs)',
                      prefixIcon: Iconsax.money_send,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDropdown('Status', ['active', 'inactive'], selectedStatus, (v) => setState(() => selectedStatus = v!)),
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
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: hasPermission && !_isSaving ? () async {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() => _isSaving = true);
                          final success = await provider.saveService(
                            id: widget.service?.id,
                            data: {
                              'serviceName': nameController.text.trim(),
                              'durationTime': durationController.text.trim(),
                              'rate': rateController.text.trim(),
                              'status': selectedStatus,
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
                          : Text(isEdit ? 'Update Service' : 'Save Service', style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildDropdown(String label, List<String> options, String value, ValueChanged<String?> onChanged) {
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
              dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              items: options.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase(), style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
