import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinity/Provider/auth/access_control_provider.dart';
import 'package:provider/provider.dart';
import '../../../Provider/stock/StockProvider.dart';
import '../../../compoents/app_theme.dart';
import '../../../model/stock/service_model.dart';
import '../../compoents/app_button.dart';
import '../../compoents/app_text_field.dart';
import '../../../constants/permission_keys.dart';
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
    final bool canDelete = acp.canDelete(resource);

    if (!canRead) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.shield_cross, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text("Access Denied", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("You don't have permission to view services.", style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    final provider = Provider.of<StockProvider>(context);

    return Column(
      children: [
        // Search Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: AppTextField(
            controller: _searchController,
            label: 'Search services...',
            icon: Iconsax.search_normal,
            onChanged: (v) => provider.fetchServices(search: v),
          ),
        ),
        
        // List
        Expanded(
          child: provider.isLoading && provider.services.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => provider.fetchServices(search: _searchController.text),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: provider.services.length,
                    itemBuilder: (context, index) {
                      final service = provider.services[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: StockCard(
                          title: service.serviceName ?? 'N/A',
                          subtitle: "Duration: ${service.durationTime ?? '0'} min",
                          trailing: "Rs ${service.rate ?? '0'}",
                          icon: Iconsax.box,
                          onTap: canUpdate ? () => _openServiceDialog(service) : null,
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _openServiceDialog(ServiceData? service) {
    showDialog(
      context: context,
      builder: (context) => _ServiceFormDialog(service: service),
    );
  }

  void _confirmDelete(ServiceData service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.serviceName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final provider = Provider.of<StockProvider>(context, listen: false);
              await provider.deleteService(service.id!);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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

    final bool isEdit = widget.service != null;
    final bool hasPermission = isEdit ? canUpdate : canCreate;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.service == null ? 'Add Service' : 'Edit Service',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: nameController,
                label: 'Service Name',
                icon: Iconsax.box,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: durationController,
                      label: 'Duration (min)',
                      icon: Iconsax.timer,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: rateController,
                      label: 'Rate (Rs)',
                      icon: Iconsax.money_send,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                initialValue: selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                ],
                onChanged: (v) => setState(() => selectedStatus = v!),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      press: hasPermission ? () async {
                        if (!_formKey.currentState!.validate()) return;
                        final success = await provider.saveService(
                          id: widget.service?.id,
                          data: {
                            'serviceName': nameController.text.trim(),
                            'durationTime': durationController.text.trim(),
                            'rate': rateController.text.trim(),
                            'status': selectedStatus,
                          },
                        );
                        if (success) {
                          if (mounted) Navigator.pop(context);
                        }
                      } : null,
                      title: !hasPermission ? 'No Permission' : (provider.isLoading ? 'Saving...' : 'Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
